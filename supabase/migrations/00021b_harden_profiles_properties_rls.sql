-- ==============================================================================
-- Migration 00021b: Harden Profiles and Properties RLS with Firebase UID Bridge
-- Project: Belagavi Property (PropertyHub)
-- Step 2 of 2: Helper Functions & RLS Policies (Transactional & Idempotent)
-- ==============================================================================

BEGIN;

-- 1. Helper function for admin / founder role check via Firebase UID
CREATE OR REPLACE FUNCTION public.is_app_admin_or_founder()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE firebase_uid = (auth.jwt()->>'sub') 
        AND role::text IN ('admin', 'founder')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 2. Drop all legacy / obsolete / permissive policies on public.profiles
DROP POLICY IF EXISTS "Public profiles read access" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can read own profile or admin" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Anyone can insert profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;

-- 3. New Privacy-Safe RLS Policies on public.profiles
CREATE POLICY "Users can read own profile or admin" 
    ON public.profiles FOR SELECT 
    USING (
        firebase_uid = (auth.jwt()->>'sub')
        OR public.is_app_admin_or_founder()
    );

CREATE POLICY "Users can insert own profile" 
    ON public.profiles FOR INSERT 
    WITH CHECK (
        auth.jwt()->>'sub' IS NOT NULL
        AND firebase_uid = (auth.jwt()->>'sub')
    );

CREATE POLICY "Users can update own profile" 
    ON public.profiles FOR UPDATE 
    USING (
        firebase_uid = (auth.jwt()->>'sub')
        OR public.is_app_admin_or_founder()
    )
    WITH CHECK (
        firebase_uid = (auth.jwt()->>'sub')
        OR public.is_app_admin_or_founder()
    );

-- 4. Drop all legacy / obsolete / auth.uid()-based policies on public.properties
DROP POLICY IF EXISTS "Public read active verified properties" ON public.properties;
DROP POLICY IF EXISTS "Owners can insert their properties" ON public.properties;
DROP POLICY IF EXISTS "Owners can update their properties" ON public.properties;
DROP POLICY IF EXISTS "Owners can delete their properties" ON public.properties;
DROP POLICY IF EXISTS "Properties select policy" ON public.properties;
DROP POLICY IF EXISTS "Properties insert policy" ON public.properties;
DROP POLICY IF EXISTS "Properties update policy" ON public.properties;
DROP POLICY IF EXISTS "Properties delete policy" ON public.properties;
DROP POLICY IF EXISTS "Hardened properties update policy" ON public.properties;
DROP POLICY IF EXISTS "Public read active properties or owner" ON public.properties;
DROP POLICY IF EXISTS "Owners can insert properties" ON public.properties;
DROP POLICY IF EXISTS "Owners can update properties" ON public.properties;
DROP POLICY IF EXISTS "Owners can delete properties" ON public.properties;
DROP POLICY IF EXISTS "Public properties read access" ON public.properties;
DROP POLICY IF EXISTS "Public can view active properties" ON public.properties;
DROP POLICY IF EXISTS "Owner update own property" ON public.properties;
DROP POLICY IF EXISTS "Owner delete own property" ON public.properties;

-- 5. New Hardened RLS Policies on public.properties
-- SELECT: Public can ONLY view active listings; Owners view own non-public records; Admins view all
CREATE POLICY "Public read active properties or owner" 
    ON public.properties FOR SELECT 
    USING (
        status = 'active'
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.id = properties.owner_id 
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

CREATE POLICY "Owners can insert properties" 
    ON public.properties FOR INSERT 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.id = properties.owner_id 
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

CREATE POLICY "Owners can update properties" 
    ON public.properties FOR UPDATE 
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.id = properties.owner_id 
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.id = properties.owner_id 
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

CREATE POLICY "Owners can delete properties" 
    ON public.properties FOR DELETE 
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.id = properties.owner_id 
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

COMMIT;
