-- ==============================================================================
-- BELAGAVI PROPERTY PLATFORM — PHASE 8: WORLDWIDE GEOGRAPHY SCHEMA
-- Data-driven worldwide location hierarchy: Country → State → District → City → Locality → Area
-- Design principles:
--   - All tables use UUID PKs
--   - All cascading via FK (no orphans)
--   - Public read (RLS: unauthenticated can read locations)
--   - Indexes on all FK columns (for fast cascading queries)
--   - No hardcoded country/city per application code — driven entirely by DB data
-- ==============================================================================

-- 1. Countries Table
CREATE TABLE IF NOT EXISTS public.countries (
    code        VARCHAR(5) PRIMARY KEY,    -- ISO 3166-1 alpha-2 e.g. 'IN', 'US', 'GB'
    name        VARCHAR(100) NOT NULL,
    dial_code   VARCHAR(10) DEFAULT '',
    currency_code    VARCHAR(10) DEFAULT '',
    currency_symbol  VARCHAR(10) DEFAULT '',
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Public read: anyone can browse countries
ALTER TABLE public.countries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Countries are publicly readable" ON public.countries FOR SELECT USING (TRUE);

-- 2. States / Provinces Table
CREATE TABLE IF NOT EXISTS public.states (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code    VARCHAR(5) NOT NULL REFERENCES public.countries(code) ON DELETE CASCADE,
    name            VARCHAR(150) NOT NULL,
    code            VARCHAR(10) NOT NULL,    -- e.g. 'KA', 'CA', 'ENG'
    is_union_territory BOOLEAN DEFAULT FALSE,
    translations    JSONB DEFAULT '{}',      -- {'kn': 'ಕರ್ನಾಟಕ', 'hi': 'कर्नाटक'}
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_states_country_code ON public.states(country_code);
CREATE INDEX IF NOT EXISTS idx_states_name ON public.states(name);

ALTER TABLE public.states ENABLE ROW LEVEL SECURITY;
CREATE POLICY "States are publicly readable" ON public.states FOR SELECT USING (TRUE);

-- 3. Districts / Counties Table
CREATE TABLE IF NOT EXISTS public.districts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    state_id        UUID NOT NULL REFERENCES public.states(id) ON DELETE CASCADE,
    name            VARCHAR(150) NOT NULL,
    state_code      VARCHAR(10) NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_districts_state_id ON public.districts(state_id);
CREATE INDEX IF NOT EXISTS idx_districts_name ON public.districts(name);

ALTER TABLE public.districts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Districts are publicly readable" ON public.districts FOR SELECT USING (TRUE);

-- 4. Taluks / Sub-districts Table
--    Used as a generic "region/county/sub-district" level for non-Indian geographies
CREATE TABLE IF NOT EXISTS public.taluks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    district_id     UUID NOT NULL REFERENCES public.districts(id) ON DELETE CASCADE,
    name            VARCHAR(150) NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_taluks_district_id ON public.taluks(district_id);

ALTER TABLE public.taluks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Taluks are publicly readable" ON public.taluks FOR SELECT USING (TRUE);

-- 5. Cities / Towns Table
CREATE TABLE IF NOT EXISTS public.cities (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    taluk_id        UUID NOT NULL REFERENCES public.taluks(id) ON DELETE CASCADE,
    name            VARCHAR(150) NOT NULL,
    is_tier1        BOOLEAN DEFAULT FALSE,
    is_tier2        BOOLEAN DEFAULT TRUE,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cities_taluk_id ON public.cities(taluk_id);
CREATE INDEX IF NOT EXISTS idx_cities_name ON public.cities(name);

ALTER TABLE public.cities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Cities are publicly readable" ON public.cities FOR SELECT USING (TRUE);

-- 6. Localities / Neighborhoods Table
CREATE TABLE IF NOT EXISTS public.localities (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    city_id         UUID NOT NULL REFERENCES public.cities(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    pincode         VARCHAR(20) NOT NULL DEFAULT '',
    latitude        DECIMAL(10, 7),
    longitude       DECIMAL(10, 7),
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_localities_city_id ON public.localities(city_id);
CREATE INDEX IF NOT EXISTS idx_localities_name ON public.localities(name);
CREATE INDEX IF NOT EXISTS idx_localities_pincode ON public.localities(pincode);

-- Full-text search index on locality names for fast autocomplete
CREATE INDEX IF NOT EXISTS idx_localities_name_trgm ON public.localities USING GIN (name gin_trgm_ops);

ALTER TABLE public.localities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Localities are publicly readable" ON public.localities FOR SELECT USING (TRUE);

-- 7. Areas / Micro-localities Table (6th level)
CREATE TABLE IF NOT EXISTS public.areas (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    locality_id     UUID NOT NULL REFERENCES public.localities(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    area_code       VARCHAR(50),
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_areas_locality_id ON public.areas(locality_id);
CREATE INDEX IF NOT EXISTS idx_areas_name ON public.areas(name);

ALTER TABLE public.areas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Areas are publicly readable" ON public.areas FOR SELECT USING (TRUE);

-- ==============================================================================
-- PHASE 8 SUPPLEMENTAL: Additional property index for area-level search
-- ==============================================================================

-- Add area column to properties if not present
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'properties' AND column_name = 'area'
    ) THEN
        ALTER TABLE public.properties ADD COLUMN area VARCHAR(200);
    END IF;
END $$;

-- Index for area-level search
CREATE INDEX IF NOT EXISTS idx_properties_area ON public.properties(area);

-- Composite index for full location hierarchy (extends Phase 6 index)
CREATE INDEX IF NOT EXISTS idx_properties_full_location
ON public.properties(country, state, district, city, locality, area)
WHERE status IN ('published', 'approved', 'active');

-- ==============================================================================
-- SEED DATA: Initial India/Belagavi entries (safe — uses ON CONFLICT DO NOTHING)
-- ==============================================================================

INSERT INTO public.countries (code, name, dial_code, currency_code, currency_symbol)
VALUES
    ('IN', 'India', '+91', 'INR', '₹'),
    ('US', 'United States', '+1', 'USD', '$'),
    ('GB', 'United Kingdom', '+44', 'GBP', '£'),
    ('AE', 'United Arab Emirates', '+971', 'AED', 'AED'),
    ('SG', 'Singapore', '+65', 'SGD', 'S$'),
    ('AU', 'Australia', '+61', 'AUD', 'A$')
ON CONFLICT (code) DO NOTHING;

-- ==============================================================================
-- NOTES FOR DBA:
-- 1. To add a new country: INSERT INTO countries
-- 2. To add a new state: INSERT INTO states with country_code
-- 3. No Flutter code changes needed — data-driven taxonomy
-- 4. The trigram index requires: CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- ==============================================================================
