-- Migration: 00011_create_saved_property_searches_and_price_history.sql
-- Description: Create saved_property_searches table with RLS and property_price_history audit table

-- 1. Create Saved Property Searches Table
CREATE TABLE IF NOT EXISTS public.saved_property_searches (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    category TEXT,
    purpose TEXT,
    city TEXT DEFAULT 'Belagavi',
    locality TEXT,
    min_price DOUBLE PRECISION,
    max_price DOUBLE PRECISION,
    min_area DOUBLE PRECISION,
    max_area DOUBLE PRECISION,
    min_bedrooms INTEGER,
    max_bedrooms INTEGER,
    property_type TEXT,
    query_json JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indices for rapid matching queries
CREATE INDEX IF NOT EXISTS idx_saved_searches_user_id ON public.saved_property_searches(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_searches_is_active ON public.saved_property_searches(is_active);
CREATE INDEX IF NOT EXISTS idx_saved_searches_category ON public.saved_property_searches(category) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_saved_searches_city ON public.saved_property_searches(city) WHERE is_active = true;

-- Enable RLS
ALTER TABLE public.saved_property_searches ENABLE ROW LEVEL SECURITY;

-- Customer Private Access Policy
CREATE POLICY "Saved searches select policy"
ON public.saved_property_searches
FOR SELECT
TO authenticated
USING (
    user_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

CREATE POLICY "Saved searches insert policy"
ON public.saved_property_searches
FOR INSERT
TO authenticated
WITH CHECK (
    user_id = (SELECT auth.uid())::text
);

CREATE POLICY "Saved searches update policy"
ON public.saved_property_searches
FOR UPDATE
TO authenticated
USING (
    user_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
)
WITH CHECK (
    user_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

CREATE POLICY "Saved searches delete policy"
ON public.saved_property_searches
FOR DELETE
TO authenticated
USING (
    user_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

-- 2. Create Property Price History Table
CREATE TABLE IF NOT EXISTS public.property_price_history (
    id TEXT PRIMARY KEY,
    property_id TEXT NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    old_price DOUBLE PRECISION NOT NULL,
    new_price DOUBLE PRECISION NOT NULL,
    actor_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_price_history_property_id ON public.property_price_history(property_id);
CREATE INDEX IF NOT EXISTS idx_price_history_changed_at ON public.property_price_history(changed_at DESC);

ALTER TABLE public.property_price_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Price history select policy"
ON public.property_price_history
FOR SELECT
TO authenticated
USING (
    public.is_app_admin_or_founder()
    OR EXISTS (
        SELECT 1 FROM public.properties p 
        WHERE p.id = property_price_history.property_id 
        AND (p.status IN ('published', 'active', 'approved') OR p.owner_id::text = (SELECT auth.uid())::text)
    )
);

CREATE POLICY "Price history insert policy"
ON public.property_price_history
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_app_admin_or_founder()
    OR EXISTS (
        SELECT 1 FROM public.properties p 
        WHERE p.id = property_price_history.property_id 
        AND p.owner_id::text = (SELECT auth.uid())::text
    )
);
