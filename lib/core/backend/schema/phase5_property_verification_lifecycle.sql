-- ====================================================================
-- BELAGAVI PROPERTY — PHASE 4 DATABASE MIGRATION
-- PROPERTY VERIFICATION & LIFECYCLE MANAGEMENT SCHEMA
-- ====================================================================

-- 1. ADD VERIFICATION & REJECTION REASON COLUMNS TO PROPERTIES TABLE
ALTER TABLE public.properties 
ADD COLUMN IF NOT EXISTS rejection_reason TEXT,
ADD COLUMN IF NOT EXISTS verification_notes TEXT;

-- 2. CREATE INDEXES FOR FAST LIFECYCLE & VERIFICATION QUEUE QUERIES
CREATE INDEX IF NOT EXISTS idx_properties_status ON public.properties(status);
CREATE INDEX IF NOT EXISTS idx_properties_owner_id ON public.properties(owner_id);
CREATE INDEX IF NOT EXISTS idx_properties_builder_id ON public.properties(features->>'builder_id');
CREATE INDEX IF NOT EXISTS idx_properties_created_at ON public.properties(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_properties_updated_at ON public.properties(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_properties_verification_status ON public.properties(verification_status);

-- 3. INTERNAL NOTIFICATIONS TABLE (IN-APP STATUS NOTIFICATIONS)
CREATE TABLE IF NOT EXISTS public.internal_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    property_id UUID REFERENCES public.properties(id) ON DELETE CASCADE,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for User Notifications Lookup
CREATE INDEX IF NOT EXISTS idx_internal_notifications_user ON public.internal_notifications(user_id, is_read, created_at DESC);

-- Enable RLS on Internal Notifications
ALTER TABLE public.internal_notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only read their own notifications
CREATE POLICY "Users View Own Internal Notifications"
    ON public.internal_notifications FOR SELECT
    USING (auth.uid() = user_id);

-- RLS Policy: System / Admin can insert notifications
CREATE POLICY "System Insert Internal Notifications"
    ON public.internal_notifications FOR INSERT
    WITH CHECK (TRUE);
