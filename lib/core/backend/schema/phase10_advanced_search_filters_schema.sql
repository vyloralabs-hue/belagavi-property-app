-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 10 ADVANCED SEARCH, FILTERS & INDEXES
-- Target Schema Version: 1.10.0
-- Created: 2026-08-10
-- =============================================================================

-- High-Performance Composite & Range Indexes for 1,000,000+ Scale Search & Sorting
CREATE INDEX IF NOT EXISTS idx_properties_search_composite 
ON public.properties(status, category, type, purpose, price);

CREATE INDEX IF NOT EXISTS idx_properties_price_asc 
ON public.properties(price ASC) WHERE status IN ('published', 'approved', 'active');

CREATE INDEX IF NOT EXISTS idx_properties_price_desc 
ON public.properties(price DESC) WHERE status IN ('published', 'approved', 'active');

CREATE INDEX IF NOT EXISTS idx_properties_created_at_desc 
ON public.properties(created_at DESC) WHERE status IN ('published', 'approved', 'active');

-- GIN Index for JSONB Features & Amenities Fast Intersection Search
CREATE INDEX IF NOT EXISTS idx_properties_features_gin 
ON public.properties USING GIN (features jsonb_path_ops);
