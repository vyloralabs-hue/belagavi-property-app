-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 14 INDIA-WIDE LOCAL SHOP & BUSINESS DISCOVERY SCHEMA
-- Target Schema Version: 1.14.0
-- Created: 2026-08-10
-- =============================================================================

-- Enable pg_trgm extension for trigram fuzzy search if not exists
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 1. Business Categories & Subcategories
CREATE TABLE IF NOT EXISTS public.business_categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    icon_name TEXT DEFAULT 'store',
    display_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.business_subcategories (
    id TEXT PRIMARY KEY,
    category_id TEXT NOT NULL REFERENCES public.business_categories(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    display_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2. Local Businesses Table (6-Level Geography Integrated)
CREATE TABLE IF NOT EXISTS public.businesses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id TEXT NOT NULL,
    name TEXT NOT NULL,
    category_id TEXT NOT NULL REFERENCES public.business_categories(id),
    subcategory_id TEXT,
    country_code TEXT DEFAULT 'IN' NOT NULL,
    state_id TEXT NOT NULL,
    district_id TEXT NOT NULL,
    city_id TEXT NOT NULL,
    locality_id TEXT NOT NULL,
    area_id TEXT,
    address TEXT NOT NULL,
    phone TEXT NOT NULL,
    whatsapp TEXT,
    description TEXT NOT NULL,
    opening_hours TEXT NOT NULL,
    photos TEXT[] DEFAULT '{}',
    products_services TEXT[] DEFAULT '{}',
    status TEXT DEFAULT 'submitted' NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. Business Moderation Audit Logs
CREATE TABLE IF NOT EXISTS public.business_moderation_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id TEXT NOT NULL,
    actor_role TEXT NOT NULL,
    business_id UUID NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    reason TEXT NOT NULL,
    previous_status TEXT NOT NULL,
    new_status TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes for Fast Location & Category Business Discovery Queries
CREATE INDEX IF NOT EXISTS idx_businesses_location_cat 
ON public.businesses(country_code, state_id, city_id, locality_id, category_id, status);

CREATE INDEX IF NOT EXISTS idx_businesses_status_created 
ON public.businesses(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_businesses_owner 
ON public.businesses(owner_id);

-- Trigram Index for Fast Business Name Autocomplete
CREATE INDEX IF NOT EXISTS idx_businesses_name_trgm 
ON public.businesses USING gin (name gin_trgm_ops);

-- RLS Security Policies
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_moderation_audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read published businesses"
ON public.businesses FOR SELECT
USING (status IN ('published', 'approved', 'active'));

CREATE POLICY "Owner read write own business"
ON public.businesses FOR ALL
USING (owner_id = auth.uid()::text);

CREATE POLICY "Founder/Admin moderate businesses"
ON public.businesses FOR ALL
USING (auth.role() = 'authenticated');
