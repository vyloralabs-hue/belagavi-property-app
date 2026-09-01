-- =============================================================================
-- BELAGAVI PROPERTY: PHASE B CANONICAL GEOGRAPHY FOUNDATION (ADDITIVE MIGRATION)
-- Version: 1.25.0
-- Status: PREPARED ADDITIVE FOUNDATION (DO NOT APPLY AUTOMATICALLY)
-- =============================================================================

-- 1. Master Countries Table
CREATE TABLE IF NOT EXISTS public.geo_countries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    iso2 VARCHAR(2) UNIQUE NOT NULL,
    iso3 VARCHAR(3) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    dial_code VARCHAR(10) NOT NULL DEFAULT '+91',
    currency_code VARCHAR(10) NOT NULL DEFAULT 'INR',
    currency_symbol VARCHAR(10) NOT NULL DEFAULT '₹',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Admin Level 1 (States / Provinces / Regions / Emirates)
CREATE TABLE IF NOT EXISTS public.geo_admin_level_1 (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_id UUID NOT NULL REFERENCES public.geo_countries(id) ON DELETE CASCADE,
    code VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL,
    admin_type VARCHAR(50) NOT NULL DEFAULT 'State', -- State, Province, Region, Emirate
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Admin Level 2 (Districts / Counties)
CREATE TABLE IF NOT EXISTS public.geo_admin_level_2 (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_level_1_id UUID NOT NULL REFERENCES public.geo_admin_level_1(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    admin_type VARCHAR(50) NOT NULL DEFAULT 'District', -- District, County
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Master Cities Table
CREATE TABLE IF NOT EXISTS public.geo_cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_id UUID NOT NULL REFERENCES public.geo_countries(id) ON DELETE CASCADE,
    admin_level_1_id UUID NOT NULL REFERENCES public.geo_admin_level_1(id) ON DELETE CASCADE,
    admin_level_2_id UUID REFERENCES public.geo_admin_level_2(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_popular BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Master Localities Table
CREATE TABLE IF NOT EXISTS public.geo_localities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    city_id UUID NOT NULL REFERENCES public.geo_cities(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL,
    pincode VARCHAR(20),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Master Aliases Table (Disambiguation & Localization)
CREATE TABLE IF NOT EXISTS public.geo_aliases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(20) NOT NULL, -- 'city', 'locality', 'state'
    entity_id UUID NOT NULL,
    alias VARCHAR(100) NOT NULL,
    locale VARCHAR(10) DEFAULT 'en',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. Additive Foreign Key Columns on Properties Table (Non-destructive, Preserving Snapshots)
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS country_id UUID REFERENCES public.geo_countries(id) ON DELETE SET NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS admin_level_1_id UUID REFERENCES public.geo_admin_level_1(id) ON DELETE SET NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS admin_level_2_id UUID REFERENCES public.geo_admin_level_2(id) ON DELETE SET NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS city_id UUID REFERENCES public.geo_cities(id) ON DELETE SET NULL;
ALTER TABLE public.properties ADD COLUMN IF NOT EXISTS locality_id UUID REFERENCES public.geo_localities(id) ON DELETE SET NULL;

-- Indexes for Canonical Geography
CREATE INDEX IF NOT EXISTS idx_properties_city_id ON public.properties(city_id);
CREATE INDEX IF NOT EXISTS idx_properties_locality_id ON public.properties(locality_id);
CREATE INDEX IF NOT EXISTS idx_geo_cities_slug ON public.geo_cities(slug);
CREATE INDEX IF NOT EXISTS idx_geo_localities_slug ON public.geo_localities(slug);
CREATE INDEX IF NOT EXISTS idx_geo_aliases_lookup ON public.geo_aliases(alias);

-- Enable RLS
ALTER TABLE public.geo_countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.geo_admin_level_1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.geo_admin_level_2 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.geo_cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.geo_localities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.geo_aliases ENABLE ROW LEVEL SECURITY;

-- Public Read Policy
CREATE POLICY "Public geography read access" ON public.geo_countries FOR SELECT USING (true);
CREATE POLICY "Public geography read access" ON public.geo_admin_level_1 FOR SELECT USING (true);
CREATE POLICY "Public geography read access" ON public.geo_admin_level_2 FOR SELECT USING (true);
CREATE POLICY "Public geography read access" ON public.geo_cities FOR SELECT USING (true);
CREATE POLICY "Public geography read access" ON public.geo_localities FOR SELECT USING (true);
CREATE POLICY "Public geography read access" ON public.geo_aliases FOR SELECT USING (true);
