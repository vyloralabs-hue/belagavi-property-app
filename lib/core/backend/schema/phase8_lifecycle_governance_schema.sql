-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 8 PROPERTY LIFECYCLE & GOVERNANCE SCHEMA
-- Target Schema Version: 1.8.0
-- Created: 2026-08-10
-- =============================================================================

-- Create Moderation Audit Logs Table
CREATE TABLE IF NOT EXISTS public.property_moderation_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id TEXT NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    actor_id TEXT NOT NULL,
    actor_role TEXT NOT NULL CHECK (actor_role IN ('founder', 'admin', 'owner', 'builder', 'seller', 'agent')),
    action TEXT NOT NULL,
    reason TEXT,
    previous_status TEXT NOT NULL,
    new_status TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- High-Performance Indexes for Admin Verification Queue & Audit Queries
CREATE INDEX IF NOT EXISTS idx_mod_audit_property_id ON public.property_moderation_audit_logs(property_id);
CREATE INDEX IF NOT EXISTS idx_mod_audit_actor_id ON public.property_moderation_audit_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_mod_audit_created_at ON public.property_moderation_audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_mod_audit_new_status ON public.property_moderation_audit_logs(new_status);

-- Enable RLS on moderation audit logs
ALTER TABLE public.property_moderation_audit_logs ENABLE ROW LEVEL SECURITY;

-- 1. SELECT Policy: Founder/Admin can read all logs. Property owner can read logs for their own properties.
CREATE POLICY "Moderation logs select policy"
ON public.property_moderation_audit_logs FOR SELECT
USING (
    auth.role() = 'authenticated'
    AND (
        (auth.jwt() ->> 'role') IN ('founder', 'admin')
        OR actor_id = auth.uid()::text
        OR EXISTS (
            SELECT 1 FROM public.properties p
            WHERE p.id = property_id AND p.owner_id = auth.uid()::text
        )
    )
);

-- 2. INSERT Policy: Authenticated users can insert audit records for actions they perform
CREATE POLICY "Moderation logs insert policy"
ON public.property_moderation_audit_logs FOR INSERT
WITH CHECK (
    auth.role() = 'authenticated'
    AND actor_id = auth.uid()::text
);
