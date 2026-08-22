-- =============================================================================
-- Migration 00004: Ticket Types, Passes, Wallets, Wallet Transactions
-- Purpose: Ticketing system with wallet-based payment. Passes are purchased
--          via the purchase_pass() RPC (migration 00006) which atomically
--          deducts the wallet and creates the pass record.
-- =============================================================================

-- ── ticket_types ──────────────────────────────────────────────────────────────
-- Reference data — managed by admins.
CREATE TABLE public.ticket_types (
  id            uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text          NOT NULL UNIQUE,
  price         numeric(10,2) NOT NULL CHECK (price > 0),
  duration_days int           NOT NULL CHECK (duration_days > 0),
  description   text,
  is_active     boolean       NOT NULL DEFAULT true,
  created_at    timestamptz   NOT NULL DEFAULT now()
);

-- Seed default pass types
INSERT INTO public.ticket_types (name, price, duration_days, description) VALUES
  ('Daily Pass',   5.00,  1,  'Single day unlimited rides'),
  ('Weekly Pass',  25.00, 7,  'Seven day unlimited rides'),
  ('Monthly Pass', 80.00, 30, 'Thirty day unlimited rides'),
  ('Student Pass', 40.00, 30, 'Monthly pass for verified students');

-- ── passes ────────────────────────────────────────────────────────────────────
-- A passenger's purchased pass. qr_token is what the driver scans.
CREATE TABLE public.passes (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  ticket_type_id  uuid        NOT NULL REFERENCES public.ticket_types(id),
  -- NULL means the pass is valid on all routes
  route_id        uuid        REFERENCES public.routes(id) ON DELETE SET NULL,
  valid_from      date        NOT NULL DEFAULT CURRENT_DATE,
  valid_until     date        NOT NULL,
  status          text        NOT NULL DEFAULT 'active'
                              CONSTRAINT passes_status_check
                              CHECK (status IN ('active', 'expired', 'revoked')),
  -- 32-byte hex token — unique per pass, used as the QR code payload
  qr_token        text        NOT NULL UNIQUE
                              DEFAULT encode(gen_random_bytes(32), 'hex'),
  purchased_at    timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT passes_valid_dates CHECK (valid_until >= valid_from)
);

-- Enable Realtime so the passenger app updates immediately after purchase
ALTER TABLE public.passes REPLICA IDENTITY FULL;

CREATE INDEX idx_passes_user_id    ON public.passes(user_id);
CREATE INDEX idx_passes_status     ON public.passes(status);
CREATE INDEX idx_passes_qr_token   ON public.passes(qr_token);
CREATE INDEX idx_passes_valid_until ON public.passes(valid_until);

-- ── wallets ───────────────────────────────────────────────────────────────────
-- One wallet per passenger. Balance can never go below 0 (enforced in RPC too).
CREATE TABLE public.wallets (
  id          uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid          NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  balance     numeric(12,2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
  updated_at  timestamptz   NOT NULL DEFAULT now()
);

CREATE TRIGGER wallets_updated_at
  BEFORE UPDATE ON public.wallets
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ── wallet_transactions ───────────────────────────────────────────────────────
CREATE TABLE public.wallet_transactions (
  id            uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid          NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type          text          NOT NULL
                              CONSTRAINT wallet_tx_type_check
                              CHECK (type IN ('top_up', 'ticket_purchase', 'refund')),
  amount        numeric(10,2) NOT NULL CHECK (amount > 0),
  description   text          NOT NULL DEFAULT '',
  -- Nullable reference to whatever triggered this transaction (e.g. pass id)
  reference_id  uuid,
  created_at    timestamptz   NOT NULL DEFAULT now()
);

CREATE INDEX idx_wallet_tx_user_id ON public.wallet_transactions(user_id);
CREATE INDEX idx_wallet_tx_created ON public.wallet_transactions(created_at DESC);

-- ── Auto-create wallet when a passenger profile is first inserted ─────────────
CREATE OR REPLACE FUNCTION public.handle_new_passenger_wallet()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.role = 'passenger' THEN
    INSERT INTO public.wallets (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_passenger_profile_created
  AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_passenger_wallet();
