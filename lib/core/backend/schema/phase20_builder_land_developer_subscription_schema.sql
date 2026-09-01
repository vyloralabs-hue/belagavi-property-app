-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 20 BUILDER & LAND DEVELOPER SUBSCRIPTION SCHEMAS
-- Registered Business Identity: BELAGAVI PROPERTY LLP
-- Target Schema Version: 1.20.0
-- Created: 2026-08-10
-- =============================================================================

-- 1. Builder Subscriptions Table
CREATE TABLE IF NOT EXISTS public.builder_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE,
    plan_id TEXT NOT NULL,
    active_project_limit INT DEFAULT 3 NOT NULL,
    status TEXT DEFAULT 'INACTIVE' NOT NULL, -- 'ACTIVE', 'PAST_DUE', 'EXPIRED', 'CANCELLED', 'SUSPENDED'
    start_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2. Land Developer Subscriptions Table
CREATE TABLE IF NOT EXISTS public.land_developer_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE,
    plan_id TEXT NOT NULL,
    active_layout_limit INT DEFAULT 3 NOT NULL,
    status TEXT DEFAULT 'INACTIVE' NOT NULL, -- 'ACTIVE', 'PAST_DUE', 'EXPIRED', 'CANCELLED', 'SUSPENDED'
    start_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. Subscription Plan Limits Table
CREATE TABLE IF NOT EXISTS public.subscription_plan_limits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id TEXT NOT NULL UNIQUE,
    product_category TEXT NOT NULL,
    monthly_price_paise INT NOT NULL,
    max_active_listings INT NOT NULL,
    priority_score_boost INT DEFAULT 0 NOT NULL,
    is_featured_eligible BOOLEAN DEFAULT false NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 4. Subscription Audit Logs Table
CREATE TABLE IF NOT EXISTS public.subscription_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id TEXT NOT NULL,
    actor_role TEXT NOT NULL,
    action TEXT NOT NULL,
    target_user_id TEXT NOT NULL,
    plan_id TEXT NOT NULL,
    previous_status TEXT NULL,
    new_status TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_builder_subscriptions_user
ON public.builder_subscriptions(user_id, status);

CREATE INDEX IF NOT EXISTS idx_land_developer_subscriptions_user
ON public.land_developer_subscriptions(user_id, status);

CREATE INDEX IF NOT EXISTS idx_subscription_audit_logs_actor
ON public.subscription_audit_logs(actor_id, timestamp DESC);

-- Enable RLS
ALTER TABLE public.builder_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.land_developer_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_audit_logs ENABLE ROW LEVEL SECURITY;

-- Strict RLS Policies
CREATE POLICY "Builder read own subscription"
ON public.builder_subscriptions FOR SELECT
USING (user_id = auth.uid()::text);

CREATE POLICY "Land developer read own subscription"
ON public.land_developer_subscriptions FOR SELECT
USING (user_id = auth.uid()::text);
