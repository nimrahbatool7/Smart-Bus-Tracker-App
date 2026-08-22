-- =============================================================================
-- Migration 00001: Profiles table + auth trigger
-- Purpose: Extends auth.users with application-level profile data for all roles.
-- =============================================================================

-- ── Shared updated_at trigger function (used by all tables) ──────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- ── profiles ─────────────────────────────────────────────────────────────────
CREATE TABLE public.profiles (
  id          uuid        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   text        NOT NULL DEFAULT '',
  phone       text,
  role        text        NOT NULL DEFAULT 'passenger'
                          CONSTRAINT profiles_role_check
                          CHECK (role IN ('passenger', 'driver', 'admin')),
  status      text        NOT NULL DEFAULT 'active'
                          CONSTRAINT profiles_status_check
                          CHECK (status IN ('active', 'pending', 'suspended')),
  avatar_url  text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_profiles_role   ON public.profiles(role);
CREATE INDEX idx_profiles_status ON public.profiles(status);

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ── Auto-create profile row when a user signs up ──────────────────────────────
-- Role and full_name can be passed via raw_user_meta_data at signup time.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'role', 'passenger')
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
