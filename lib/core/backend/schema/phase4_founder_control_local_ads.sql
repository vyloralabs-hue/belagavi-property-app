-- ====================================================================
-- BELAGAVI PROPERTY — PHASE 3 DATABASE MIGRATION
-- FOUNDER CONTROL, EMERGENCY MODERATION & LOCAL ADVERTISING SYSTEM
-- ====================================================================

-- 1. EXTEND LISTING STATUS ENUM FOR DISPUTE GOVERNANCE
-- (Supports: draft, submitted, pending_verification, under_review, approved, published, active, paused, rejected, sold, rented, disputed, archived)

-- 2. MODERATION AUDIT LOGS TABLE
CREATE TABLE IF NOT EXISTS public.moderation_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID NOT NULL,
    actor_role VARCHAR(32) NOT NULL DEFAULT 'founder',
    property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    action VARCHAR(64) NOT NULL, -- EMERGENCY_HIDE, PAUSE, REJECT, ARCHIVE, RESTORE, MARK_DISPUTED
    reason TEXT NOT NULL,
    previous_status VARCHAR(32) NOT NULL,
    new_status VARCHAR(32) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast property audit lookup
CREATE INDEX IF NOT EXISTS idx_moderation_logs_property ON public.moderation_audit_logs(property_id);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_actor ON public.moderation_audit_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_moderation_logs_created ON public.moderation_audit_logs(created_at DESC);

-- Enable RLS on Moderation Audit Logs
ALTER TABLE public.moderation_audit_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Founder/Admin only can view and write moderation logs
CREATE POLICY "Founder/Admin View Moderation Logs"
    ON public.moderation_audit_logs FOR SELECT
    USING (
        auth.jwt() ->> 'role' IN ('founder', 'admin', 'moderator')
    );

CREATE POLICY "Founder/Admin Insert Moderation Logs"
    ON public.moderation_audit_logs FOR INSERT
    WITH CHECK (
        auth.jwt() ->> 'role' IN ('founder', 'admin', 'moderator')
    );

-- 3. LOCAL PLATFORM ADVERTISEMENTS TABLE
CREATE TABLE IF NOT EXISTS public.local_advertisements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT NOT NULL,
    video_url TEXT,
    business_name VARCHAR(255) NOT NULL,
    target_url TEXT,
    placement VARCHAR(64) NOT NULL DEFAULT 'homeMiddle', -- homeTop, homeMiddle, homeBottom, propertyList, propertyDetail, searchResults, builderSection, projectSection
    status VARCHAR(32) NOT NULL DEFAULT 'active', -- draft, scheduled, active, paused, expired, archived
    start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_date TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '30 days'),
    priority INT NOT NULL DEFAULT 1, -- 1 (Highest Priority), 2, 3...
    created_by UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for ad placement & active status delivery queries
CREATE INDEX IF NOT EXISTS idx_local_ads_placement_status ON public.local_advertisements(placement, status, priority ASC);
CREATE INDEX IF NOT EXISTS idx_local_ads_dates ON public.local_advertisements(start_date, end_date);

-- Enable RLS on Local Advertisements
ALTER TABLE public.local_advertisements ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Public read for active ads
CREATE POLICY "Public View Active Local Ads"
    ON public.local_advertisements FOR SELECT
    USING (
        status = 'active' AND NOW() BETWEEN start_date AND end_date
    );

-- RLS Policy: Founder/Admin full access for managing ads
CREATE POLICY "Founder/Admin Manage Local Ads"
    ON public.local_advertisements FOR ALL
    USING (
        auth.jwt() ->> 'role' IN ('founder', 'admin')
    );
