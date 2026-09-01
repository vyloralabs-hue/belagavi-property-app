-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 11 FAVORITES & SAVED SEARCHES SCHEMA
-- Target Schema Version: 1.11.0
-- Created: 2026-08-10
-- =============================================================================

-- 1. Property Favorites Table
CREATE TABLE IF NOT EXISTS public.property_favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    property_id TEXT NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_user_property_favorite UNIQUE(user_id, property_id)
);

-- Indexes for Fast User Favorites Lookup and Sorting
CREATE INDEX IF NOT EXISTS idx_favorites_user_created ON public.property_favorites(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_favorites_property_id ON public.property_favorites(property_id);

-- Enable RLS on property_favorites
ALTER TABLE public.property_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own favorites"
ON public.property_favorites FOR ALL
USING (auth.role() = 'authenticated' AND user_id = auth.uid()::text)
WITH CHECK (auth.role() = 'authenticated' AND user_id = auth.uid()::text);


-- 2. Saved Property Searches Table
CREATE TABLE IF NOT EXISTS public.saved_property_searches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    title TEXT NOT NULL,
    query_json JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes for Saved Searches Retrieval
CREATE INDEX IF NOT EXISTS idx_saved_searches_user_created ON public.saved_property_searches(user_id, created_at DESC);

-- Enable RLS on saved_property_searches
ALTER TABLE public.saved_property_searches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own saved searches"
ON public.saved_property_searches FOR ALL
USING (auth.role() = 'authenticated' AND user_id = auth.uid()::text)
WITH CHECK (auth.role() = 'authenticated' AND user_id = auth.uid()::text);
