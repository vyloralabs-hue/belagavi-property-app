-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 19 BUILDER & LAND DEVELOPER PAID ACCESS SCHEMAS
-- Registered Business Identity: BELAGAVI PROPERTY LLP
-- Target Schema Version: 1.19.1
-- Created: 2026-08-10
-- =============================================================================

-- 1. Developer Profiles Table
CREATE TABLE IF NOT EXISTS public.developer_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE,
    developer_type TEXT NOT NULL, -- 'BUILDER', 'PROJECT_DEVELOPER', 'LAND_DEVELOPER', 'LAYOUT_DEVELOPER'
    company_name TEXT NOT NULL,
    rera_registration_number TEXT NULL,
    verification_status TEXT DEFAULT 'PENDING' NOT NULL, -- 'UNVERIFIED', 'PENDING', 'VERIFIED', 'REJECTED'
    subscription_status TEXT DEFAULT 'INACTIVE' NOT NULL, -- 'ACTIVE', 'EXPIRING', 'EXPIRED', 'CANCELLED', 'INACTIVE'
    current_plan_id TEXT NULL,
    subscription_expires_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2. Developer Subscription Requirements Matrix Table
CREATE TABLE IF NOT EXISTS public.developer_subscription_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    developer_type TEXT NOT NULL,
    property_category TEXT NOT NULL,
    subscription_required BOOLEAN DEFAULT true NOT NULL,
    min_required_plan_id TEXT DEFAULT 'plan_builder_pro' NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. Professional Listing Access Log Table
CREATE TABLE IF NOT EXISTS public.professional_listing_access (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id TEXT NOT NULL,
    owner_id TEXT NOT NULL,
    developer_type TEXT NOT NULL,
    is_subscription_verified BOOLEAN DEFAULT false NOT NULL,
    is_moderation_approved BOOLEAN DEFAULT false NOT NULL,
    public_visibility_granted BOOLEAN DEFAULT false NOT NULL,
    evaluated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 4. Developer Subscription Audit Logs Table
CREATE TABLE IF NOT EXISTS public.developer_subscription_audit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id TEXT NOT NULL,
    actor_role TEXT NOT NULL,
    action TEXT NOT NULL, -- 'SUBSCRIPTION_CREATED', 'SUBSCRIPTION_ACTIVATED', 'SUBSCRIPTION_EXPIRED', 'LISTING_PUBLISHED', 'LISTING_BLOCKED'
    developer_id TEXT NOT NULL,
    previous_state TEXT NULL,
    new_state TEXT NOT NULL,
    reason TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_developer_profiles_user
ON public.developer_profiles(user_id, subscription_status);

CREATE INDEX IF NOT EXISTS idx_professional_listing_access_prop
ON public.professional_listing_access(property_id, owner_id);

CREATE INDEX IF NOT EXISTS idx_developer_subscription_audit_actor
ON public.developer_subscription_audit(actor_id, timestamp DESC);

-- Enable RLS
ALTER TABLE public.developer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.professional_listing_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.developer_subscription_audit ENABLE ROW LEVEL SECURITY;

-- Strict RLS Policies
CREATE POLICY "Developer read own profile"
ON public.developer_profiles FOR SELECT
USING (user_id = auth.uid()::text);

CREATE POLICY "Developer read own listing access"
ON public.professional_listing_access FOR SELECT
USING (owner_id = auth.uid()::text);
