-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 12 FOUNDER & ADMIN GOVERNANCE SCHEMA
-- Target Schema Version: 1.12.0
-- Created: 2026-08-10
-- =============================================================================

-- High-Performance Composite Indexes for Status Counts & Queue Filtering
CREATE INDEX IF NOT EXISTS idx_properties_status_created 
ON public.properties(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_properties_owner_status 
ON public.properties(owner_id, status);

CREATE INDEX IF NOT EXISTS idx_properties_builder_status 
ON public.properties(builder_id, status) WHERE builder_id IS NOT NULL;

-- Moderation Audit Log Index Enhancements
CREATE INDEX IF NOT EXISTS idx_moderation_logs_prop_time 
ON public.property_moderation_audit_logs(property_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_moderation_logs_actor_time 
ON public.property_moderation_audit_logs(actor_id, created_at DESC);

-- RPC Function for Server-Side Database Status Aggregate Counts
CREATE OR REPLACE FUNCTION get_property_status_counts()
RETURNS TABLE (status TEXT, count BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT p.status::TEXT, COUNT(*)::BIGINT
    FROM public.properties p
    GROUP BY p.status;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
