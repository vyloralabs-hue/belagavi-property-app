-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 15 UNIFIED INDIA SEARCH & DISCOVERY SCHEMA
-- Target Schema Version: 1.15.0
-- Created: 2026-08-10
-- =============================================================================

-- Composite B-Tree & GIN Trigram Search Indexes for Unified Discovery
CREATE INDEX IF NOT EXISTS idx_properties_unified_search 
ON public.properties USING gin (title gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_businesses_unified_search 
ON public.businesses USING gin (name gin_trgm_ops);

-- Database RPC for Unified Multi-Source Search Execution
CREATE OR REPLACE FUNCTION unified_search_query(
    search_text TEXT,
    target_city_id TEXT DEFAULT NULL,
    max_results INT DEFAULT 20
)
RETURNS TABLE (
    result_type TEXT,
    entity_id TEXT,
    title TEXT,
    subtitle TEXT,
    location_label TEXT,
    category_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- 1. Matching Properties
    SELECT 
        'PROPERTY'::TEXT AS result_type,
        p.id::TEXT AS entity_id,
        p.title AS title,
        (p.locality || ', ' || p.city) AS subtitle,
        (p.locality || ', ' || p.city) AS location_label,
        p.category::TEXT AS category_name
    FROM public.properties p
    WHERE p.status IN ('published', 'approved', 'active')
      AND (p.title ILIKE '%' || search_text || '%' OR p.locality ILIKE '%' || search_text || '%')
    LIMIT max_results / 2

    UNION ALL

    -- 2. Matching Businesses
    SELECT 
        'BUSINESS'::TEXT AS result_type,
        b.id::TEXT AS entity_id,
        b.name AS title,
        b.address AS subtitle,
        b.address AS location_label,
        b.category_id AS category_name
    FROM public.businesses b
    WHERE b.status IN ('published', 'approved', 'active')
      AND (b.name ILIKE '%' || search_text || '%' OR b.address ILIKE '%' || search_text || '%')
    LIMIT max_results / 2;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
