-- Migration: 00014_create_property_promotions_and_entitlements.sql
-- Description: Create property_promotions and user_entitlements tables with strict RLS and anti-tampering constraints

-- 1. Create Property Promotions Table
CREATE TABLE IF NOT EXISTS public.property_promotions (
    id TEXT PRIMARY KEY,
    property_id TEXT NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    owner_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    promotion_type TEXT NOT NULL, -- 'FEATURED', 'BOOST', 'TOP_PLACEMENT'
    priority_level INT NOT NULL DEFAULT 1,
    status TEXT NOT NULL DEFAULT 'ACTIVE', -- 'PENDING', 'ACTIVE', 'PAUSED', 'EXPIRED', 'CANCELLED', 'REJECTED'
    start_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_promotions_property_status ON public.property_promotions(property_id, status);
CREATE INDEX IF NOT EXISTS idx_promotions_owner ON public.property_promotions(owner_id);
CREATE INDEX IF NOT EXISTS idx_promotions_status_end ON public.property_promotions(status, end_at);

ALTER TABLE public.property_promotions ENABLE ROW LEVEL SECURITY;

-- Property Promotions RLS
CREATE POLICY "Public read active unexpired promotions"
ON public.property_promotions
FOR SELECT
USING (
    (status = 'ACTIVE' AND end_at > NOW())
    OR owner_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

CREATE POLICY "Owner create promotion for own eligible property"
ON public.property_promotions
FOR INSERT
TO authenticated
WITH CHECK (
    owner_id = (SELECT auth.uid())::text
    AND owner_id = (SELECT owner_id::text FROM public.properties WHERE id = property_id)
);

CREATE POLICY "Owner update own promotion status or Admin manage"
ON public.property_promotions
FOR UPDATE
TO authenticated
USING (
    owner_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
)
WITH CHECK (
    owner_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

-- 2. Create User Entitlements Table
CREATE TABLE IF NOT EXISTS public.user_entitlements (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    entitlement_key TEXT NOT NULL, -- 'CREATE_LISTING', 'PROMOTE_LISTING', 'FEATURED_LISTING', 'PRIORITY_PLACEMENT'
    total_quota INT NOT NULL DEFAULT 0,
    used_quota INT NOT NULL DEFAULT 0,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_user_entitlement UNIQUE(user_id, entitlement_key)
);

CREATE INDEX IF NOT EXISTS idx_entitlements_user_key ON public.user_entitlements(user_id, entitlement_key);

ALTER TABLE public.user_entitlements ENABLE ROW LEVEL SECURITY;

-- Entitlements RLS
CREATE POLICY "Users read own entitlements or Admin read all"
ON public.user_entitlements
FOR SELECT
TO authenticated
USING (
    user_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

CREATE POLICY "Admin only insert or update entitlements"
ON public.user_entitlements
FOR ALL
TO authenticated
USING (
    public.is_app_admin_or_founder()
)
WITH CHECK (
    public.is_app_admin_or_founder()
);
