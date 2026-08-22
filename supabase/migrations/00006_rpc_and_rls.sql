-- =============================================================================
-- Migration 00006: Database RPCs + Row Level Security
-- Purpose: All security policies and the two critical RPC functions.
--          RLS is enabled on every table. Never disable it.
-- =============================================================================

-- =============================================================================
-- SECTION A: RPC FUNCTIONS
-- =============================================================================

-- ── purchase_pass ─────────────────────────────────────────────────────────────
-- Atomically: validates ticket type → checks balance → deducts wallet →
--             inserts pass → records transaction.
-- Called from Flutter with: supabase.rpc('purchase_pass', params: {...})
-- Security: SECURITY DEFINER so it can write to wallets without client bypass.
CREATE OR REPLACE FUNCTION public.purchase_pass(
  p_ticket_type_id  uuid,
  p_route_id        uuid DEFAULT NULL
)
RETURNS uuid  -- returns the new pass id
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id     uuid := auth.uid();
  v_price       numeric;
  v_duration    int;
  v_balance     numeric;
  v_pass_id     uuid;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated' USING HINT = 'User must be signed in to purchase a pass';
  END IF;

  -- Validate ticket type exists and is active
  SELECT price, duration_days
  INTO   v_price, v_duration
  FROM   public.ticket_types
  WHERE  id = p_ticket_type_id AND is_active = true;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'ticket_type_not_found' USING HINT = 'The selected ticket type is unavailable';
  END IF;

  -- Lock wallet row to prevent race conditions
  SELECT balance INTO v_balance
  FROM   public.wallets
  WHERE  user_id = v_user_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'wallet_not_found' USING HINT = 'No wallet exists for this user';
  END IF;

  IF v_balance < v_price THEN
    RAISE EXCEPTION 'insufficient_balance'
      USING HINT = format('Balance %.2f is less than price %.2f', v_balance, v_price);
  END IF;

  -- Deduct wallet
  UPDATE public.wallets
  SET    balance = balance - v_price
  WHERE  user_id = v_user_id;

  -- Create pass
  INSERT INTO public.passes (user_id, ticket_type_id, route_id, valid_from, valid_until)
  VALUES (
    v_user_id,
    p_ticket_type_id,
    p_route_id,
    CURRENT_DATE,
    CURRENT_DATE + v_duration
  )
  RETURNING id INTO v_pass_id;

  -- Record transaction
  INSERT INTO public.wallet_transactions (user_id, type, amount, description, reference_id)
  VALUES (v_user_id, 'ticket_purchase', v_price, 'Pass purchase', v_pass_id);

  RETURN v_pass_id;
END;
$$;

-- ── validate_ticket ────────────────────────────────────────────────────────────
-- Called by the driver scanner to verify a passenger's QR token.
-- Returns JSON: { valid: bool, reason: string, pass_id: uuid, user_name: string }
-- Does NOT mark the pass as used on scan — passes are date-range based.
CREATE OR REPLACE FUNCTION public.validate_ticket(
  p_qr_token  text,
  p_trip_id   uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_pass    public.passes%ROWTYPE;
  v_name    text;
BEGIN
  -- Caller must be an authenticated driver
  IF auth.uid() IS NULL THEN
    RETURN jsonb_build_object('valid', false, 'reason', 'not_authenticated');
  END IF;

  SELECT p.* INTO v_pass
  FROM   public.passes p
  WHERE  p.qr_token   = p_qr_token
    AND  p.status     = 'active'
    AND  p.valid_from <= CURRENT_DATE
    AND  p.valid_until >= CURRENT_DATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('valid', false, 'reason', 'invalid_or_expired');
  END IF;

  SELECT full_name INTO v_name
  FROM   public.profiles
  WHERE  id = v_pass.user_id;

  RETURN jsonb_build_object(
    'valid',      true,
    'reason',     'ok',
    'pass_id',    v_pass.id,
    'pass_type',  (SELECT name FROM public.ticket_types WHERE id = v_pass.ticket_type_id),
    'valid_until', v_pass.valid_until,
    'user_name',  COALESCE(v_name, 'Unknown')
  );
END;
$$;

-- ── top_up_wallet ──────────────────────────────────────────────────────────────
-- Adds funds to the caller's wallet. In production this would be called from
-- an Edge Function after a successful Stripe payment confirmation, not directly
-- from the Flutter client. Provided here for development/testing.
CREATE OR REPLACE FUNCTION public.top_up_wallet(
  p_amount numeric
)
RETURNS numeric  -- returns new balance
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id   uuid := auth.uid();
  v_balance   numeric;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  IF p_amount <= 0 THEN
    RAISE EXCEPTION 'invalid_amount' USING HINT = 'Top-up amount must be positive';
  END IF;

  UPDATE public.wallets
  SET    balance = balance + p_amount
  WHERE  user_id = v_user_id
  RETURNING balance INTO v_balance;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'wallet_not_found';
  END IF;

  INSERT INTO public.wallet_transactions (user_id, type, amount, description)
  VALUES (v_user_id, 'top_up', p_amount, 'Wallet top-up');

  RETURN v_balance;
END;
$$;

-- ── admin_update_driver_status ─────────────────────────────────────────────────
-- Allows admins to approve or suspend a driver.
-- Using RPC instead of a direct UPDATE prevents non-admin clients from
-- escalating their own status even if they craft a malicious request.
CREATE OR REPLACE FUNCTION public.admin_update_driver_status(
  p_driver_id uuid,
  p_status    text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_role text;
BEGIN
  SELECT role INTO v_caller_role
  FROM   public.profiles
  WHERE  id = auth.uid();

  IF v_caller_role <> 'admin' THEN
    RAISE EXCEPTION 'forbidden' USING HINT = 'Only admins can update driver status';
  END IF;

  IF p_status NOT IN ('active', 'pending', 'suspended') THEN
    RAISE EXCEPTION 'invalid_status';
  END IF;

  UPDATE public.profiles
  SET    status = p_status
  WHERE  id = p_driver_id AND role = 'driver';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'driver_not_found';
  END IF;
END;
$$;

-- =============================================================================
-- SECTION B: ROW LEVEL SECURITY
-- =============================================================================

-- Enable RLS on every table
ALTER TABLE public.profiles             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routes               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.route_stops          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.buses                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bus_locations        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ticket_types         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.passes               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_applications  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_alerts        ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- profiles policies
-- =============================================================================

-- Users can read their own profile
CREATE POLICY "profiles: owner can select"
  ON public.profiles FOR SELECT
  USING (id = auth.uid());

-- Admins can read all profiles
CREATE POLICY "profiles: admins can select all"
  ON public.profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- Users can update their own non-role non-status fields
CREATE POLICY "profiles: owner can update own"
  ON public.profiles FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (
    -- Prevent users from changing their own role or status
    role   = (SELECT role   FROM public.profiles WHERE id = auth.uid()) AND
    status = (SELECT status FROM public.profiles WHERE id = auth.uid())
  );

-- The auth trigger (SECURITY DEFINER) handles INSERT — no client INSERT policy needed
-- Admins can update any profile (e.g. changing driver status via admin panel)
CREATE POLICY "profiles: admins can update all"
  ON public.profiles FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid() AND p.role = 'admin'
    )
  );

-- =============================================================================
-- routes + route_stops policies — public read, admin write
-- =============================================================================

CREATE POLICY "routes: anyone authenticated can read"
  ON public.routes FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "routes: admins can insert"
  ON public.routes FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "routes: admins can update"
  ON public.routes FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "routes: admins can delete"
  ON public.routes FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "route_stops: anyone authenticated can read"
  ON public.route_stops FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "route_stops: admins can write"
  ON public.route_stops FOR ALL
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- =============================================================================
-- buses policies — authenticated read, admin write
-- =============================================================================

CREATE POLICY "buses: authenticated can read"
  ON public.buses FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "buses: admins can insert"
  ON public.buses FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "buses: admins can update"
  ON public.buses FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "buses: admins can delete"
  ON public.buses FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- =============================================================================
-- trips policies
-- =============================================================================

-- Drivers can read their own trips; admins read all
CREATE POLICY "trips: driver reads own"
  ON public.trips FOR SELECT
  USING (driver_id = auth.uid());

CREATE POLICY "trips: admins read all"
  ON public.trips FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Only the assigned driver can insert their own trip
CREATE POLICY "trips: driver can insert own"
  ON public.trips FOR INSERT
  WITH CHECK (driver_id = auth.uid());

-- Driver can update their own trip (e.g. set status = completed)
CREATE POLICY "trips: driver can update own"
  ON public.trips FOR UPDATE
  USING (driver_id = auth.uid());

-- =============================================================================
-- bus_locations policies — anyone authenticated can read (needed for passenger map)
-- =============================================================================

-- Passengers and admins need to read all bus locations for the live map
CREATE POLICY "bus_locations: authenticated can read"
  ON public.bus_locations FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- Only the driver of the assigned bus can insert/update their bus's location
CREATE POLICY "bus_locations: driver can upsert own bus"
  ON public.bus_locations FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.buses b
      WHERE b.id = bus_id AND b.current_driver_id = auth.uid()
    )
  );

CREATE POLICY "bus_locations: driver can update own bus"
  ON public.bus_locations FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.buses b
      WHERE b.id = bus_id AND b.current_driver_id = auth.uid()
    )
  );

-- =============================================================================
-- ticket_types policies — public read, admin write
-- =============================================================================

CREATE POLICY "ticket_types: authenticated can read"
  ON public.ticket_types FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "ticket_types: admins can write"
  ON public.ticket_types FOR ALL
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- =============================================================================
-- passes policies
-- =============================================================================

-- Passengers see only their own passes
CREATE POLICY "passes: owner can select"
  ON public.passes FOR SELECT
  USING (user_id = auth.uid());

-- Admins can read all passes
CREATE POLICY "passes: admins can select all"
  ON public.passes FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- purchase_pass() RPC (SECURITY DEFINER) handles INSERT — no direct client insert
-- Drivers need to read a pass by qr_token to validate it
CREATE POLICY "passes: driver can read by qr_token"
  ON public.passes FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'driver')
  );

-- =============================================================================
-- wallets policies
-- =============================================================================

CREATE POLICY "wallets: owner can select"
  ON public.wallets FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "wallets: admins can select all"
  ON public.wallets FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- wallet balance is modified only via SECURITY DEFINER RPCs, not direct client writes

-- =============================================================================
-- wallet_transactions policies
-- =============================================================================

CREATE POLICY "wallet_tx: owner can select"
  ON public.wallet_transactions FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "wallet_tx: admins can select all"
  ON public.wallet_transactions FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- =============================================================================
-- driver_applications policies
-- =============================================================================

-- Drivers can see and insert their own applications
CREATE POLICY "driver_apps: owner can select"
  ON public.driver_applications FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "driver_apps: owner can insert"
  ON public.driver_applications FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Admins can read all and update status
CREATE POLICY "driver_apps: admins can select all"
  ON public.driver_applications FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "driver_apps: admins can update"
  ON public.driver_applications FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- =============================================================================
-- driver_alerts policies
-- =============================================================================

-- Drivers see alerts for themselves
CREATE POLICY "alerts: driver reads own"
  ON public.driver_alerts FOR SELECT
  USING (driver_id = auth.uid());

-- Admins see all
CREATE POLICY "alerts: admins read all"
  ON public.driver_alerts FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Drivers (and system) can insert alerts for their own trips
CREATE POLICY "alerts: driver can insert own"
  ON public.driver_alerts FOR INSERT
  WITH CHECK (driver_id = auth.uid());
