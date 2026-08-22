-- =============================================================================
-- Migration 00003: Trips + Real-Time Bus Locations
-- Purpose: Tracks active driver trips and live GPS positions.
--          bus_locations has Realtime enabled so Flutter clients receive
--          position updates without polling.
-- =============================================================================

-- ── trips ─────────────────────────────────────────────────────────────────────
CREATE TABLE public.trips (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id   uuid        NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  bus_id      uuid        NOT NULL REFERENCES public.buses(id)    ON DELETE RESTRICT,
  route_id    uuid        NOT NULL REFERENCES public.routes(id)   ON DELETE RESTRICT,
  status      text        NOT NULL DEFAULT 'active'
                          CONSTRAINT trips_status_check
                          CHECK (status IN ('active', 'completed', 'cancelled')),
  started_at  timestamptz NOT NULL DEFAULT now(),
  ended_at    timestamptz
);

-- Enforce one active trip per driver and per bus at the same time
CREATE UNIQUE INDEX idx_trips_active_driver
  ON public.trips(driver_id)
  WHERE status = 'active';

CREATE UNIQUE INDEX idx_trips_active_bus
  ON public.trips(bus_id)
  WHERE status = 'active';

CREATE INDEX idx_trips_driver_id ON public.trips(driver_id);
CREATE INDEX idx_trips_bus_id    ON public.trips(bus_id);
CREATE INDEX idx_trips_status    ON public.trips(status);

-- ── bus_locations ─────────────────────────────────────────────────────────────
-- One row per bus (upserted on each GPS update).
-- REPLICA IDENTITY FULL is required for Supabase Realtime to emit old/new rows.
CREATE TABLE public.bus_locations (
  id          uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
  bus_id      uuid          NOT NULL UNIQUE REFERENCES public.buses(id) ON DELETE CASCADE,
  trip_id     uuid          REFERENCES public.trips(id) ON DELETE SET NULL,
  latitude    numeric(10,7) NOT NULL,
  longitude   numeric(10,7) NOT NULL,
  speed_mph   numeric(5,2)  NOT NULL DEFAULT 0 CHECK (speed_mph >= 0),
  heading     numeric(5,2),
  updated_at  timestamptz   NOT NULL DEFAULT now()
);

-- Required for Supabase Realtime to broadcast full row data on changes
ALTER TABLE public.bus_locations REPLICA IDENTITY FULL;

CREATE INDEX idx_bus_locations_trip_id ON public.bus_locations(trip_id);
