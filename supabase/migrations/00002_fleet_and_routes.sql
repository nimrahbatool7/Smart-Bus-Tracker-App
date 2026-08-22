-- =============================================================================
-- Migration 00002: Buses, Routes, Route Stops
-- Purpose: Core fleet and route entities managed by admins.
-- =============================================================================

-- ── routes ───────────────────────────────────────────────────────────────────
CREATE TABLE public.routes (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  name         text        NOT NULL UNIQUE,
  total_stops  int         NOT NULL DEFAULT 0 CHECK (total_stops >= 0),
  distance_km  numeric(8,2),
  is_active    boolean     NOT NULL DEFAULT true,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_routes_active ON public.routes(is_active);

CREATE TRIGGER routes_updated_at
  BEFORE UPDATE ON public.routes
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ── route_stops ───────────────────────────────────────────────────────────────
-- Ordered stops along a route with GPS coordinates.
CREATE TABLE public.route_stops (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id    uuid        NOT NULL REFERENCES public.routes(id) ON DELETE CASCADE,
  stop_name   text        NOT NULL,
  stop_order  int         NOT NULL CHECK (stop_order >= 0),
  latitude    numeric(10,7) NOT NULL,
  longitude   numeric(10,7) NOT NULL,
  UNIQUE (route_id, stop_order)
);

CREATE INDEX idx_route_stops_route_id ON public.route_stops(route_id);

-- ── buses ─────────────────────────────────────────────────────────────────────
CREATE TABLE public.buses (
  id                 uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  plate_number       text        NOT NULL UNIQUE,
  model              text        NOT NULL,
  capacity           int         NOT NULL DEFAULT 50 CHECK (capacity > 0),
  has_ac             boolean     NOT NULL DEFAULT false,
  status             text        NOT NULL DEFAULT 'active'
                                 CONSTRAINT buses_status_check
                                 CHECK (status IN ('active', 'maintenance', 'retired')),
  -- Nullable: a bus may not always have an assigned driver
  current_driver_id  uuid        REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_buses_status    ON public.buses(status);
CREATE INDEX idx_buses_driver_id ON public.buses(current_driver_id);

CREATE TRIGGER buses_updated_at
  BEFORE UPDATE ON public.buses
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
