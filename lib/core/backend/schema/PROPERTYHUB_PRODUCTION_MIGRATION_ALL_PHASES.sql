-- =============================================================================
-- PROPERTYHUB / BELAGAVI PROPERTY PRODUCTION CONSOLIDATED MIGRATIONS
-- Registered Business Identity: BELAGAVI PROPERTY LLP
-- Target: Supabase Live Production Database
-- Execution Mode: Non-Destructive, Additive, Idempotent
-- =============================================================================

-- =============================================================================
-- PHASE 16: MONETIZATION & ADS SCHEMA
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.pricing_plans (
    plan_id TEXT PRIMARY KEY,
    product_type TEXT NOT NULL,
    plan_name TEXT NOT NULL,
    billing_cycle TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    discount_amount NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,
    tax_amount NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,
    final_amount NUMERIC(10, 2) NOT NULL,
    duration_days INT NOT NULL,
    listing_limit INT DEFAULT 1 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    effective_from TIMESTAMPTZ NOT NULL,
    effective_until TIMESTAMPTZ
);

INSERT INTO public.pricing_plans (plan_id, product_type, plan_name, billing_cycle, amount, discount_amount, final_amount, duration_days, effective_from)
VALUES 
  ('plan_prop_free', 'property', 'Property Basic Free Listing', 'free', 0.00, 0.00, 0.00, 3650, NOW()),
  ('plan_shop_free', 'shop', 'Local Shop Basic Free Listing', 'free', 0.00, 0.00, 0.00, 3650, NOW()),
  ('plan_shop_monthly', 'shop', 'Local Shop Monthly Premium', 'monthly', 500.00, 0.00, 500.00, 30, NOW()),
  ('plan_shop_yearly', 'shop', 'Local Shop Yearly Premium (Save ₹1,000)', 'yearly', 5000.00, 1000.00, 5000.00, 365, NOW()),
  ('plan_builder_pro', 'builder', 'Builder Pro Enterprise Tier', 'yearly', 25000.00, 0.00, 25000.00, 365, NOW()),
  ('plan_broker_pro', 'broker', 'Broker Pro Agent Tier', 'monthly', 1500.00, 0.00, 1500.00, 30, NOW())
ON CONFLICT (plan_id) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.payment_orders (
    order_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    plan_id TEXT NOT NULL REFERENCES public.pricing_plans(plan_id),
    product_type TEXT NOT NULL,
    reference_entity_id TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    status TEXT DEFAULT 'initiated' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.payment_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id TEXT NOT NULL REFERENCES public.payment_orders(order_id),
    payment_id TEXT NOT NULL,
    provider_name TEXT DEFAULT 'razorpay' NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    status TEXT NOT NULL,
    signature TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.entitlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    product_type TEXT NOT NULL,
    boost_type TEXT DEFAULT 'freeListing' NOT NULL,
    reference_entity_id TEXT NOT NULL,
    plan_id TEXT NOT NULL REFERENCES public.pricing_plans(plan_id),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    priority_score INT DEFAULT 0 NOT NULL,
    granted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.advertising_placements (
    id TEXT PRIMARY KEY,
    placement_type TEXT NOT NULL,
    provider_type TEXT DEFAULT 'adMob' NOT NULL,
    is_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    refresh_rate_seconds INT DEFAULT 30 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

INSERT INTO public.advertising_placements (id, placement_type, provider_type, is_enabled)
VALUES
  ('place_home_feed', 'homeFeed', 'adMob', true),
  ('place_prop_search', 'propertySearch', 'adMob', true),
  ('place_shop_search', 'shopSearch', 'adMob', true),
  ('place_unified_search', 'unifiedSearch', 'adMob', true)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.ad_revenue_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    placement_type TEXT NOT NULL,
    provider_type TEXT NOT NULL,
    event_type TEXT NOT NULL,
    estimated_revenue_inr NUMERIC(10, 4) DEFAULT 0.0000 NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.invoices (
    invoice_number TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    order_id TEXT NOT NULL REFERENCES public.payment_orders(order_id),
    subtotal_amount NUMERIC(10, 2) NOT NULL,
    discount_amount NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,
    tax_amount_gst NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,
    total_paid_amount NUMERIC(10, 2) NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    paid_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.refunds (
    refund_id TEXT PRIMARY KEY,
    payment_id TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    refund_type TEXT NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE public.pricing_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entitlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.advertising_placements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ad_revenue_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.refunds ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public read active pricing plans' AND tablename = 'pricing_plans') THEN
    CREATE POLICY "Public read active pricing plans" ON public.pricing_plans FOR SELECT USING (is_active = true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'User read own entitlements' AND tablename = 'entitlements') THEN
    CREATE POLICY "User read own entitlements" ON public.entitlements FOR SELECT USING (user_id = auth.uid()::text);
  END IF;
END $$;

-- =============================================================================
-- PHASE 17: PRODUCTION MONETIZATION & REVENUE GOVERNANCE SCHEMA
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.financial_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id TEXT NOT NULL,
    actor_role TEXT NOT NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    previous_state TEXT NOT NULL,
    new_state TEXT NOT NULL,
    amount_in_paise BIGINT DEFAULT 0 NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    reason TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_entitlements_user_entity ON public.entitlements(user_id, reference_entity_id, is_active);
CREATE INDEX IF NOT EXISTS idx_payment_orders_user ON public.payment_orders(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_financial_audit_logs_actor ON public.financial_audit_logs(actor_id, timestamp DESC);

ALTER TABLE public.financial_audit_logs ENABLE ROW LEVEL SECURITY;

-- =============================================================================
-- PHASE 17B: PREMIUM PROPERTY PRIORITY & ACCESS SCHEMAS
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.property_promotion_entitlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id TEXT NOT NULL,
    owner_id TEXT NOT NULL,
    plan_id TEXT NOT NULL,
    tier TEXT NOT NULL,
    priority_boost_score INT DEFAULT 0 NOT NULL,
    amount_in_paise BIGINT DEFAULT 0 NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    status TEXT DEFAULT 'active' NOT NULL,
    granted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.property_promotion_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id TEXT NOT NULL,
    event_type TEXT NOT NULL,
    tier TEXT DEFAULT 'free' NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_property_promotion_entitlements_prop_status ON public.property_promotion_entitlements(property_id, status, expires_at);
CREATE INDEX IF NOT EXISTS idx_property_promotion_entitlements_owner ON public.property_promotion_entitlements(owner_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_property_promotion_events_prop_time ON public.property_promotion_events(property_id, timestamp DESC);

ALTER TABLE public.property_promotion_entitlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_promotion_events ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Owner read own promotion entitlements' AND tablename = 'property_promotion_entitlements') THEN
    CREATE POLICY "Owner read own promotion entitlements" ON public.property_promotion_entitlements FOR SELECT USING (owner_id = auth.uid()::text);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public read active promotion entitlements' AND tablename = 'property_promotion_entitlements') THEN
    CREATE POLICY "Public read active promotion entitlements" ON public.property_promotion_entitlements FOR SELECT USING (status = 'active' AND expires_at > NOW());
  END IF;
END $$;

-- =============================================================================
-- PHASE 17C: INVEST WITH US SCHEMAS (BELAGAVI PROPERTY LLP)
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.investment_interest_leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NULL,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    interest_region TEXT NULL,
    indicative_interest_amount NUMERIC NULL,
    preferred_contact_method TEXT DEFAULT 'WhatsApp' NOT NULL,
    message TEXT NULL,
    consent_version TEXT DEFAULT 'v1.0_2026' NOT NULL,
    consent_timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    status TEXT DEFAULT 'NEW' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.investment_projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    property_type TEXT NOT NULL,
    project_status TEXT DEFAULT 'In Development' NOT NULL,
    description TEXT NOT NULL,
    development_status TEXT NOT NULL,
    disclosable_documents JSONB DEFAULT '[]'::jsonb NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.investment_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    document_type TEXT NOT NULL,
    file_url TEXT NOT NULL,
    is_public BOOLEAN DEFAULT true NOT NULL,
    approved_by TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.investment_content_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    legal_entity_name TEXT DEFAULT 'BELAGAVI PROPERTY LLP' NOT NULL,
    module_status TEXT DEFAULT 'INFORMATION_ONLY' NOT NULL,
    indicative_profit_sharing_range TEXT DEFAULT '10%–30%' NOT NULL,
    legal_disclaimer TEXT NOT NULL,
    whatsapp_number TEXT DEFAULT '+919845012345' NOT NULL,
    company_phone_number TEXT DEFAULT '+919845012345' NOT NULL,
    company_email TEXT DEFAULT 'invest@belagaviproperty.com' NOT NULL,
    is_production_payment_enabled BOOLEAN DEFAULT false NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.investment_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id TEXT NOT NULL,
    actor_role TEXT NOT NULL,
    action TEXT NOT NULL,
    lead_id TEXT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_investment_interest_leads_status_time ON public.investment_interest_leads(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_investment_audit_logs_actor_time ON public.investment_audit_logs(actor_id, timestamp DESC);

ALTER TABLE public.investment_interest_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investment_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investment_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investment_content_config ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public insert investment interest leads' AND tablename = 'investment_interest_leads') THEN
    CREATE POLICY "Public insert investment interest leads" ON public.investment_interest_leads FOR INSERT WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public read investment projects' AND tablename = 'investment_projects') THEN
    CREATE POLICY "Public read investment projects" ON public.investment_projects FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public read public investment documents' AND tablename = 'investment_documents') THEN
    CREATE POLICY "Public read public investment documents" ON public.investment_documents FOR SELECT USING (is_public = true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Public read investment compliance config' AND tablename = 'investment_content_config') THEN
    CREATE POLICY "Public read investment compliance config" ON public.investment_content_config FOR SELECT USING (true);
  END IF;
END $$;

-- =============================================================================
-- PHASE 18: OWNER COMMAND CENTER SCHEMAS
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.property_enquiries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id TEXT NOT NULL,
    owner_id TEXT NOT NULL,
    lead_type TEXT DEFAULT 'INQUIRY' NOT NULL,
    actor_role TEXT DEFAULT 'BUYER' NOT NULL,
    name TEXT NOT NULL,
    contact_method TEXT NOT NULL,
    phone_number TEXT NULL,
    email TEXT NULL,
    property_title TEXT NOT NULL,
    location TEXT NOT NULL,
    status TEXT DEFAULT 'NEW' NOT NULL,
    notes TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.property_contact_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id TEXT NOT NULL,
    owner_id TEXT NOT NULL,
    request_type TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.owner_daily_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id TEXT NOT NULL,
    property_id TEXT NOT NULL,
    metric_date DATE NOT NULL,
    views_count INT DEFAULT 0 NOT NULL,
    search_appearances INT DEFAULT 0 NOT NULL,
    detail_opens INT DEFAULT 0 NOT NULL,
    enquiries_count INT DEFAULT 0 NOT NULL,
    call_clicks INT DEFAULT 0 NOT NULL,
    whatsapp_clicks INT DEFAULT 0 NOT NULL,
    favorites_count INT DEFAULT 0 NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT uq_owner_daily_metrics UNIQUE(owner_id, property_id, metric_date)
);

CREATE INDEX IF NOT EXISTS idx_property_enquiries_owner_status ON public.property_enquiries(owner_id, status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_property_contact_requests_owner ON public.property_contact_requests(owner_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_owner_daily_metrics_owner_date ON public.owner_daily_metrics(owner_id, metric_date DESC);

ALTER TABLE public.property_enquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_contact_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.owner_daily_metrics ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Owner read own property enquiries' AND tablename = 'property_enquiries') THEN
    CREATE POLICY "Owner read own property enquiries" ON public.property_enquiries FOR SELECT USING (owner_id = auth.uid()::text);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Owner update own property enquiries' AND tablename = 'property_enquiries') THEN
    CREATE POLICY "Owner update own property enquiries" ON public.property_enquiries FOR UPDATE USING (owner_id = auth.uid()::text);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Owner read own contact requests' AND tablename = 'property_contact_requests') THEN
    CREATE POLICY "Owner read own contact requests" ON public.property_contact_requests FOR SELECT USING (owner_id = auth.uid()::text);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Owner read own daily metrics' AND tablename = 'owner_daily_metrics') THEN
    CREATE POLICY "Owner read own daily metrics" ON public.owner_daily_metrics FOR SELECT USING (owner_id = auth.uid()::text);
  END IF;
END $$;

-- =============================================================================
-- PHASE 19: CENTRAL MONETIZATION & PAYMENT SCHEMAS
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    product_type TEXT NOT NULL,
    plan_id TEXT NOT NULL,
    reference_entity_id TEXT NOT NULL,
    start_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'ACTIVE' NOT NULL,
    auto_renew BOOLEAN DEFAULT false NOT NULL,
    gateway_subscription_reference TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_status ON public.subscriptions(user_id, status, end_at DESC);

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'User read own subscriptions' AND tablename = 'subscriptions') THEN
    CREATE POLICY "User read own subscriptions" ON public.subscriptions FOR SELECT USING (user_id = auth.uid()::text);
  END IF;
END $$;

-- =============================================================================
-- PHASE 19 BUILDER & LAND DEVELOPER PAID ACCESS SCHEMAS
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.developer_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE,
    developer_type TEXT NOT NULL,
    company_name TEXT NOT NULL,
    rera_registration_number TEXT NULL,
    verification_status TEXT DEFAULT 'PENDING' NOT NULL,
    subscription_status TEXT DEFAULT 'INACTIVE' NOT NULL,
    current_plan_id TEXT NULL,
    subscription_expires_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.developer_subscription_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    developer_type TEXT NOT NULL,
    property_category TEXT NOT NULL,
    subscription_required BOOLEAN DEFAULT true NOT NULL,
    min_required_plan_id TEXT DEFAULT 'plan_builder_pro' NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

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

CREATE TABLE IF NOT EXISTS public.developer_subscription_audit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id TEXT NOT NULL,
    actor_role TEXT NOT NULL,
    action TEXT NOT NULL,
    developer_id TEXT NOT NULL,
    previous_state TEXT NULL,
    new_state TEXT NOT NULL,
    reason TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_developer_profiles_user ON public.developer_profiles(user_id, subscription_status);
CREATE INDEX IF NOT EXISTS idx_professional_listing_access_prop ON public.professional_listing_access(property_id, owner_id);
CREATE INDEX IF NOT EXISTS idx_developer_subscription_audit_actor ON public.developer_subscription_audit(actor_id, timestamp DESC);

ALTER TABLE public.developer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.professional_listing_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.developer_subscription_audit ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Developer read own profile' AND tablename = 'developer_profiles') THEN
    CREATE POLICY "Developer read own profile" ON public.developer_profiles FOR SELECT USING (user_id = auth.uid()::text);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Developer read own listing access' AND tablename = 'professional_listing_access') THEN
    CREATE POLICY "Developer read own listing access" ON public.professional_listing_access FOR SELECT USING (owner_id = auth.uid()::text);
  END IF;
END $$;

-- =============================================================================
-- PHASE 20: BUILDER & LAND DEVELOPER SUBSCRIPTION SCHEMAS
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.builder_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE,
    plan_id TEXT NOT NULL,
    active_project_limit INT DEFAULT 3 NOT NULL,
    status TEXT DEFAULT 'INACTIVE' NOT NULL,
    start_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.land_developer_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE,
    plan_id TEXT NOT NULL,
    active_layout_limit INT DEFAULT 3 NOT NULL,
    status TEXT DEFAULT 'INACTIVE' NOT NULL,
    start_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

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

CREATE INDEX IF NOT EXISTS idx_builder_subscriptions_user ON public.builder_subscriptions(user_id, status);
CREATE INDEX IF NOT EXISTS idx_land_developer_subscriptions_user ON public.land_developer_subscriptions(user_id, status);
CREATE INDEX IF NOT EXISTS idx_subscription_audit_logs_actor ON public.subscription_audit_logs(actor_id, timestamp DESC);

ALTER TABLE public.builder_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.land_developer_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_audit_logs ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Builder read own subscription' AND tablename = 'builder_subscriptions') THEN
    CREATE POLICY "Builder read own subscription" ON public.builder_subscriptions FOR SELECT USING (user_id = auth.uid()::text);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Land developer read own subscription' AND tablename = 'land_developer_subscriptions') THEN
    CREATE POLICY "Land developer read own subscription" ON public.land_developer_subscriptions FOR SELECT USING (user_id = auth.uid()::text);
  END IF;
END $$;
