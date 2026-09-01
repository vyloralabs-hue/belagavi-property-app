-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 9 WORLDWIDE LOCATION & LANGUAGE SCHEMA
-- Target Schema Version: 1.9.0
-- Created: 2026-08-10
-- =============================================================================

-- High-Performance B-tree Indexes for Worldwide Geography & Scalable Property Counts (1,000,000+ Dataset Scale)
CREATE INDEX IF NOT EXISTS idx_properties_country_id ON public.properties(country_id);
CREATE INDEX IF NOT EXISTS idx_properties_state_id ON public.properties(state_id);
CREATE INDEX IF NOT EXISTS idx_properties_district_id ON public.properties(district_id);
CREATE INDEX IF NOT EXISTS idx_properties_city_id ON public.properties(city_id);
CREATE INDEX IF NOT EXISTS idx_properties_locality_id ON public.properties(locality_id);
CREATE INDEX IF NOT EXISTS idx_properties_area_id ON public.properties(area_id);

-- Composite Location + Status Index for Instant Search & Count Queries
CREATE INDEX IF NOT EXISTS idx_properties_city_status ON public.properties(city, status);
CREATE INDEX IF NOT EXISTS idx_properties_locality_status ON public.properties(locality, status);
CREATE INDEX IF NOT EXISTS idx_properties_district_status ON public.properties(district, status);

-- Verify RLS Policies on Geography Tables
ALTER TABLE public.countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.states ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.districts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.localities ENABLE ROW LEVEL SECURITY;

-- Public READ access policy for worldwide geography tables
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Geography public select policy' AND tablename = 'countries') THEN
        CREATE POLICY "Geography public select policy" ON public.countries FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Geography public select policy' AND tablename = 'states') THEN
        CREATE POLICY "Geography public select policy" ON public.states FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Geography public select policy' AND tablename = 'cities') THEN
        CREATE POLICY "Geography public select policy" ON public.cities FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Geography public select policy' AND tablename = 'localities') THEN
        CREATE POLICY "Geography public select policy" ON public.localities FOR SELECT USING (true);
    END IF;
END $$;
