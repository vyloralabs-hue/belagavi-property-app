-- =============================================================================
-- BELAGAVI PROPERTY PLATFORM — MIGRATION 00027: CANONICAL GEOGRAPHY FOUNDATION (FAMILY A)
-- Architecture: Clean Hierarchical Taxonomy matching Production Application Models
-- Level 1: countries
-- Level 2: states
-- Level 3: districts
-- Level 4: taluks
-- Level 5: cities
-- Level 6: localities
-- Level 7: areas
-- Support: location_aliases (with robust partial unique indexes)
-- Extension: properties (additive nullable foreign keys)
-- Status: PREPARED ADDITIVE FOUNDATION — DO NOT DEPLOY AUTOMATICALLY
-- =============================================================================

-- 1. Master Countries Table
-- Hardened: Neutral defaults (empty strings) rather than India-specific defaults
-- ensuring worldwide extensibility without accidental currency/dial pollution.
CREATE TABLE IF NOT EXISTS public.countries (
    code VARCHAR(5) PRIMARY KEY, -- ISO 3166-1 alpha-2 e.g. 'IN', 'US', 'GB'
    name VARCHAR(100) NOT NULL,
    normalized_name VARCHAR(100) NOT NULL,
    dial_code VARCHAR(10) NOT NULL DEFAULT '',
    currency_code VARCHAR(10) NOT NULL DEFAULT '',
    currency_symbol VARCHAR(10) NOT NULL DEFAULT '',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_countries_normalized_name UNIQUE (normalized_name)
);

-- 2. States / Provinces Table
-- Hardened: Scoped code uniqueness (country_code, code) added alongside normalized_name.
CREATE TABLE IF NOT EXISTS public.states (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code VARCHAR(5) NOT NULL REFERENCES public.countries(code) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    normalized_name VARCHAR(150) NOT NULL,
    code VARCHAR(10) NOT NULL, -- e.g. 'KA', 'MH', 'GA'
    is_union_territory BOOLEAN NOT NULL DEFAULT FALSE,
    translations JSONB DEFAULT '{}'::jsonb, -- e.g. {'kn': 'ಕರ್ನಾಟಕ', 'hi': 'कर्नाटक'}
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_states_country_code_name UNIQUE (country_code, normalized_name),
    CONSTRAINT uq_states_country_code_code UNIQUE (country_code, code)
);

-- 3. Districts / Counties Table
CREATE TABLE IF NOT EXISTS public.districts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    state_id UUID NOT NULL REFERENCES public.states(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    normalized_name VARCHAR(150) NOT NULL,
    state_code VARCHAR(10) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_districts_state_id_name UNIQUE (state_id, normalized_name)
);

-- 4. Taluks / Tehsils / Sub-Districts Table
-- Composite UNIQUE on (id, district_id) enables cross-hierarchy FK consistency for cities.
CREATE TABLE IF NOT EXISTS public.taluks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    district_id UUID NOT NULL REFERENCES public.districts(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    normalized_name VARCHAR(150) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_taluks_district_id_name UNIQUE (district_id, normalized_name),
    CONSTRAINT uq_taluks_composite_district UNIQUE (id, district_id)
);

-- 5. Cities / Towns Table
-- Hardened Rules:
-- 1. district_id NOT NULL prevents orphan cities.
-- 2. taluk_id is nullable (covers cities directly identified at district level).
-- 3. Composite FK (taluk_id, district_id) enforces cross-hierarchy consistency:
--    A city cannot point to a taluk that belongs to another district!
-- 4. Scoped uniqueness prevents duplicate cities within the same district.
CREATE TABLE IF NOT EXISTS public.cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    district_id UUID NOT NULL REFERENCES public.districts(id) ON DELETE CASCADE,
    taluk_id UUID,
    name VARCHAR(150) NOT NULL,
    normalized_name VARCHAR(150) NOT NULL,
    is_tier1 BOOLEAN NOT NULL DEFAULT FALSE,
    is_tier2 BOOLEAN NOT NULL DEFAULT TRUE,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_cities_district_id_name UNIQUE (district_id, normalized_name),
    CONSTRAINT fk_cities_taluk_district_consistency FOREIGN KEY (taluk_id, district_id)
        REFERENCES public.taluks(id, district_id) ON DELETE SET NULL
);

-- 6. Localities / Neighborhoods Table
CREATE TABLE IF NOT EXISTS public.localities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    city_id UUID NOT NULL REFERENCES public.cities(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    normalized_name VARCHAR(200) NOT NULL,
    pincode VARCHAR(20) NOT NULL DEFAULT '',
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_localities_city_id_name UNIQUE (city_id, normalized_name)
);

-- 7. Areas / Micro-Localities / Zones Table
CREATE TABLE IF NOT EXISTS public.areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    locality_id UUID NOT NULL REFERENCES public.localities(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    normalized_name VARCHAR(200) NOT NULL,
    area_code VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_areas_locality_id_name UNIQUE (locality_id, normalized_name)
);

-- 8. Master Location Aliases Table
-- Hardened Rules:
-- 1. entity_type is strictly constrained to ('city', 'locality', 'state').
-- 2. EXACT-ONE-TARGET CHECK guarantees only the corresponding target FK is populated.
-- 3. In PostgreSQL, composite UNIQUE constraints treat NULLs as distinct, allowing duplicate rows.
--    We replace the flawed composite constraint with robust PARTIAL UNIQUE INDEXES:
--    - uq_alias_city: (normalized_alias, city_id) for entity_type='city'
--    - uq_alias_locality: (normalized_alias, locality_id, parent_city_id) for entity_type='locality'
--    - uq_alias_state: (normalized_alias, state_id) for entity_type='state'
CREATE TABLE IF NOT EXISTS public.location_aliases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(20) NOT NULL,
    alias VARCHAR(150) NOT NULL,
    normalized_alias VARCHAR(150) NOT NULL,
    city_id UUID REFERENCES public.cities(id) ON DELETE CASCADE,
    locality_id UUID REFERENCES public.localities(id) ON DELETE CASCADE,
    state_id UUID REFERENCES public.states(id) ON DELETE CASCADE,
    parent_city_id UUID REFERENCES public.cities(id) ON DELETE SET NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_location_aliases_entity_type CHECK (
        entity_type IN ('city', 'locality', 'state')
    ),
    CONSTRAINT chk_location_aliases_exact_target CHECK (
        (entity_type = 'city' AND city_id IS NOT NULL AND locality_id IS NULL AND state_id IS NULL) OR
        (entity_type = 'locality' AND locality_id IS NOT NULL AND city_id IS NULL AND state_id IS NULL) OR
        (entity_type = 'state' AND state_id IS NOT NULL AND city_id IS NULL AND locality_id IS NULL)
    )
);

-- Partial Unique Indexes for True Null-Safe Idempotency
CREATE UNIQUE INDEX IF NOT EXISTS uq_alias_city_target
    ON public.location_aliases (normalized_alias, city_id)
    WHERE entity_type = 'city';

CREATE UNIQUE INDEX IF NOT EXISTS uq_alias_locality_target
    ON public.location_aliases (normalized_alias, locality_id, parent_city_id)
    WHERE entity_type = 'locality';

CREATE UNIQUE INDEX IF NOT EXISTS uq_alias_state_target
    ON public.location_aliases (normalized_alias, state_id)
    WHERE entity_type = 'state';

-- 9. Additive Foreign Key Columns on Properties Table (Non-destructive, Nullable)
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS country_code VARCHAR(5) REFERENCES public.countries(code) ON DELETE SET NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS state_id UUID REFERENCES public.states(id) ON DELETE SET NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS district_id UUID REFERENCES public.districts(id) ON DELETE SET NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS taluk_id UUID REFERENCES public.taluks(id) ON DELETE SET NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS city_id UUID REFERENCES public.cities(id) ON DELETE SET NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS locality_id UUID REFERENCES public.localities(id) ON DELETE SET NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS area_id UUID REFERENCES public.areas(id) ON DELETE SET NULL;

-- 10. Indexes for High-Performance Queries
CREATE INDEX IF NOT EXISTS idx_states_country_code ON public.states(country_code);
CREATE INDEX IF NOT EXISTS idx_states_norm_name ON public.states(normalized_name);
CREATE INDEX IF NOT EXISTS idx_districts_state_id ON public.districts(state_id);
CREATE INDEX IF NOT EXISTS idx_districts_norm_name ON public.districts(normalized_name);
CREATE INDEX IF NOT EXISTS idx_taluks_district_id ON public.taluks(district_id);
CREATE INDEX IF NOT EXISTS idx_taluks_norm_name ON public.taluks(normalized_name);
CREATE INDEX IF NOT EXISTS idx_cities_taluk_id ON public.cities(taluk_id);
CREATE INDEX IF NOT EXISTS idx_cities_district_id ON public.cities(district_id);
CREATE INDEX IF NOT EXISTS idx_cities_norm_name ON public.cities(normalized_name);
CREATE INDEX IF NOT EXISTS idx_localities_city_id ON public.localities(city_id);
CREATE INDEX IF NOT EXISTS idx_localities_norm_name ON public.localities(normalized_name);
CREATE INDEX IF NOT EXISTS idx_localities_pincode ON public.localities(pincode);
CREATE INDEX IF NOT EXISTS idx_areas_locality_id ON public.areas(locality_id);
CREATE INDEX IF NOT EXISTS idx_areas_norm_name ON public.areas(normalized_name);
CREATE INDEX IF NOT EXISTS idx_location_aliases_norm ON public.location_aliases(normalized_alias);
CREATE INDEX IF NOT EXISTS idx_location_aliases_parent ON public.location_aliases(parent_city_id);
CREATE INDEX IF NOT EXISTS idx_properties_city_id ON public.properties(city_id);
CREATE INDEX IF NOT EXISTS idx_properties_locality_id ON public.properties(locality_id);

-- 11. Row Level Security (RLS) Configuration
ALTER TABLE public.countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.states ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.districts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taluks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.localities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_aliases ENABLE ROW LEVEL SECURITY;

-- Public Read-Only Policies (Anyone can browse reference geography)
DO 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'countries' AND policyname = 'Public countries read access') THEN
        CREATE POLICY "Public countries read access" ON public.countries FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'states' AND policyname = 'Public states read access') THEN
        CREATE POLICY "Public states read access" ON public.states FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'districts' AND policyname = 'Public districts read access') THEN
        CREATE POLICY "Public districts read access" ON public.districts FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'taluks' AND policyname = 'Public taluks read access') THEN
        CREATE POLICY "Public taluks read access" ON public.taluks FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'cities' AND policyname = 'Public cities read access') THEN
        CREATE POLICY "Public cities read access" ON public.cities FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'localities' AND policyname = 'Public localities read access') THEN
        CREATE POLICY "Public localities read access" ON public.localities FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'areas' AND policyname = 'Public areas read access') THEN
        CREATE POLICY "Public areas read access" ON public.areas FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'location_aliases' AND policyname = 'Public location aliases read access') THEN
        CREATE POLICY "Public location aliases read access" ON public.location_aliases FOR SELECT USING (true);
    END IF;
END ;
