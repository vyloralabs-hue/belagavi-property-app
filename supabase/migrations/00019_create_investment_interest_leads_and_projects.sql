-- =========================================================================
-- Migration 00019: Create Investment Projects & Callback Leads Schema with RLS
-- Project: Belagavi Property (PropertyHub)
-- Authenticated Identity: Firebase JWT Subject (auth.jwt()->>'sub') -> profiles.firebase_uid
-- =========================================================================

-- 1. Create Investment Projects Table First
CREATE TABLE IF NOT EXISTS public.investment_projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    short_description TEXT NOT NULL,
    detailed_description TEXT,
    target_amount NUMERIC(15, 2) NOT NULL,
    min_investment_amount NUMERIC(15, 2) NOT NULL,
    expected_returns_indicative TEXT,
    project_duration_months INT,
    status TEXT NOT NULL DEFAULT 'draft', -- draft, upcoming, open, paused, closed, fully_subscribed, archived
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    location TEXT NOT NULL DEFAULT 'Belagavi',
    risk_level TEXT NOT NULL DEFAULT 'MODERATE',
    legal_entity_name TEXT NOT NULL DEFAULT 'BELAGAVI PROPERTY LLP',
    cover_image_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Create Investment Interest / Callback Leads Table Second
CREATE TABLE IF NOT EXISTS public.investment_interest_leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES public.investment_projects(id) ON DELETE SET NULL,
    user_id TEXT, -- Stores Firebase UID (auth.jwt()->>'sub')
    name TEXT NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email TEXT,
    city TEXT DEFAULT 'Belagavi',
    state TEXT DEFAULT 'Karnataka',
    preferred_contact_method TEXT DEFAULT 'Call / WhatsApp',
    preferred_contact_time TEXT,
    message TEXT,
    consent_version VARCHAR(50) NOT NULL DEFAULT 'v1.0_2026',
    consent_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(50) NOT NULL DEFAULT 'NEW', -- NEW, CONTACTED, IN_REVIEW, CONVERTED, CLOSED
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Enable Row-Level Security on Both Tables
ALTER TABLE public.investment_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investment_interest_leads ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies for Investment Projects
DROP POLICY IF EXISTS "Public read open active investment projects" ON public.investment_projects;
CREATE POLICY "Public read open active investment projects"
    ON public.investment_projects FOR SELECT
    USING (status IN ('open', 'upcoming') AND is_active = TRUE);

DROP POLICY IF EXISTS "Admin manage investment projects" ON public.investment_projects;
CREATE POLICY "Admin manage investment projects"
    ON public.investment_projects FOR ALL
    USING (
        EXISTS (
            SELECT 1
            FROM public.profiles
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub')
              AND profiles.role::text IN ('admin', 'founder')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.profiles
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub')
              AND profiles.role::text IN ('admin', 'founder')
        )
    );

-- 5. RLS Policies for Investment Leads / Callbacks
DROP POLICY IF EXISTS "Anyone can insert callback lead" ON public.investment_interest_leads;
CREATE POLICY "Anyone can insert callback lead"
    ON public.investment_interest_leads FOR INSERT
    WITH CHECK (
        user_id IS NULL
        OR user_id = (auth.jwt()->>'sub')
    );

DROP POLICY IF EXISTS "Private read callback lead" ON public.investment_interest_leads;
CREATE POLICY "Private read callback lead"
    ON public.investment_interest_leads FOR SELECT
    USING (
        (user_id IS NOT NULL AND user_id = (auth.jwt()->>'sub'))
        OR EXISTS (
            SELECT 1
            FROM public.profiles
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub')
              AND profiles.role::text IN ('admin', 'founder')
        )
    );
