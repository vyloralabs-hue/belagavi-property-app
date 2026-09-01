-- Migration: 00010_harden_property_moderation_audit_log.sql
-- Description: Create property_moderation_audit_logs table and harden property update RLS

-- 1. Create Moderation Audit Logs Table
CREATE TABLE IF NOT EXISTS public.property_moderation_audit_logs (
    id TEXT PRIMARY KEY,
    property_id TEXT NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    actor_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    old_status TEXT,
    new_status TEXT NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indices for rapid property history lookups
CREATE INDEX IF NOT EXISTS idx_property_moderation_property_id ON public.property_moderation_audit_logs(property_id);
CREATE INDEX IF NOT EXISTS idx_property_moderation_actor_id ON public.property_moderation_audit_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_property_moderation_created_at ON public.property_moderation_audit_logs(created_at DESC);

-- Enable Row-Level Security
ALTER TABLE public.property_moderation_audit_logs ENABLE ROW LEVEL SECURITY;

-- 2. Audit Log SELECT Policy
-- Admins/Founders can view all audit logs; Owners can view audit logs for their own properties
CREATE POLICY "View property moderation audit logs"
ON public.property_moderation_audit_logs
FOR SELECT
TO authenticated
USING (
    public.is_app_admin_or_founder()
    OR EXISTS (
        SELECT 1 FROM public.properties p 
        WHERE p.id = property_moderation_audit_logs.property_id 
        AND p.owner_id::text = (SELECT auth.uid())::text
    )
);

-- 3. Audit Log INSERT Policy
-- Only Admins/Founders or authorized actors can write to audit logs
CREATE POLICY "Insert property moderation audit logs"
ON public.property_moderation_audit_logs
FOR INSERT
TO authenticated
WITH CHECK (
    public.is_app_admin_or_founder()
    OR (SELECT auth.uid())::text = actor_id
);

-- 4. Hardened Properties UPDATE Policy on owner_id immutability
DROP POLICY IF EXISTS "Properties update policy" ON public.properties;

CREATE POLICY "Hardened properties update policy"
ON public.properties
FOR UPDATE
TO authenticated
USING (
    (auth.uid() = owner_id)
    OR public.is_app_admin_or_founder()
)
WITH CHECK (
    (
        -- Owner can update, but owner_id CANNOT change
        auth.uid() = owner_id 
        AND owner_id = (SELECT p.owner_id FROM public.properties p WHERE p.id = properties.id)
    )
    OR public.is_app_admin_or_founder()
);
