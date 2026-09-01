-- Migration: 00008_create_notifications_table_rls.sql
-- Description: Create notifications table with Row-Level Security for Buyer, Seller, and Admin

CREATE TABLE IF NOT EXISTS public.notifications (
    id TEXT PRIMARY KEY,
    recipient_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    property_id TEXT REFERENCES public.properties(id) ON DELETE SET NULL,
    inquiry_id TEXT REFERENCES public.property_inquiries(id) ON DELETE SET NULL,
    site_visit_id TEXT,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indices for rapid queries and ordering
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_id ON public.notifications(recipient_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(recipient_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_property_id ON public.notifications(property_id);
CREATE INDEX IF NOT EXISTS idx_notifications_inquiry_id ON public.notifications(inquiry_id);

-- Enable Row-Level Security
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 1. SELECT Policy:
-- Users can only read notifications directed to their recipient_id (or Admin/Founder global access)
CREATE POLICY "Users can read own notifications"
ON public.notifications
FOR SELECT
TO authenticated
USING (
    recipient_id = (SELECT auth.uid())::text
    OR public.is_admin_or_owner_role()
);

-- 2. INSERT Policy:
-- Authenticated users can insert event notifications (e.g. buyer notifying seller, seller notifying buyer)
CREATE POLICY "Authenticated users can create notifications"
ON public.notifications
FOR INSERT
TO authenticated
WITH CHECK (
    auth.role() = 'authenticated'
    OR public.is_admin_or_owner_role()
);

-- 3. UPDATE Policy:
-- Recipient can mark their notifications as read
CREATE POLICY "Recipients can update own notifications"
ON public.notifications
FOR UPDATE
TO authenticated
USING (
    recipient_id = (SELECT auth.uid())::text
    OR public.is_admin_or_owner_role()
)
WITH CHECK (
    recipient_id = (SELECT auth.uid())::text
    OR public.is_admin_or_owner_role()
);

-- 4. DELETE Policy:
-- Recipient or Admin can remove notifications
CREATE POLICY "Recipients and admins can delete notifications"
ON public.notifications
FOR DELETE
TO authenticated
USING (
    recipient_id = (SELECT auth.uid())::text
    OR public.is_admin_or_owner_role()
);
