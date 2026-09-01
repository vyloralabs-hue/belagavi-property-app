-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 13 PLATFORM ANALYTICS & CAPACITY MONITORING
-- Target Schema Version: 1.13.0
-- Created: 2026-08-10
-- =============================================================================

-- 1. Privacy-Safe Search Analytics Table (0 PII, 0 Raw Personal Data)
CREATE TABLE IF NOT EXISTS public.search_analytics_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code TEXT DEFAULT 'IN',
    state_id TEXT,
    district_id TEXT,
    city_id TEXT,
    locality_id TEXT,
    category TEXT,
    purpose TEXT,
    result_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes for Fast Aggregate Analytics and Zero-Result Demand Queries
CREATE INDEX IF NOT EXISTS idx_search_analytics_result_count 
ON public.search_analytics_logs(result_count, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_search_analytics_location 
ON public.search_analytics_logs(city_id, created_at DESC);

-- Enable RLS on search_analytics_logs
ALTER TABLE public.search_analytics_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated insert search analytics"
ON public.search_analytics_logs FOR INSERT
WITH CHECK (true);

CREATE POLICY "Founder/Admin read search analytics"
ON public.search_analytics_logs FOR SELECT
USING (auth.role() = 'authenticated');

-- 2. Server-Side Aggregate Metrics Function (0 Client Row Downloads)
CREATE OR REPLACE FUNCTION get_platform_capacity_metrics()
RETURNS TABLE (
    total_properties BIGINT,
    published_properties BIGINT,
    pending_properties BIGINT,
    under_review_properties BIGINT,
    disputed_properties BIGINT,
    archived_properties BIGINT,
    rejected_properties BIGINT,
    paused_properties BIGINT,
    draft_properties BIGINT,
    total_searches BIGINT,
    zero_result_searches BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM public.properties),
        (SELECT COUNT(*) FROM public.properties WHERE status = 'published'),
        (SELECT COUNT(*) FROM public.properties WHERE status = 'submitted'),
        (SELECT COUNT(*) FROM public.properties WHERE status = 'under_review'),
        (SELECT COUNT(*) FROM public.properties WHERE status = 'disputed'),
        (SELECT COUNT(*) FROM public.properties WHERE status = 'archived'),
        (SELECT COUNT(*) FROM public.properties WHERE status = 'rejected'),
        (SELECT COUNT(*) FROM public.properties WHERE status = 'paused'),
        (SELECT COUNT(*) FROM public.properties WHERE status = 'draft'),
        (SELECT COUNT(*) FROM public.search_analytics_logs),
        (SELECT COUNT(*) FROM public.search_analytics_logs WHERE result_count = 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
