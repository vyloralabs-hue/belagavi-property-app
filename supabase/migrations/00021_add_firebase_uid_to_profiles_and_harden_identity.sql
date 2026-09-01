-- ==============================================================================
-- Migration 00021: Add firebase_uid to profiles & Bridge Firebase Third-Party Auth RLS
-- Project: Belagavi Property (PropertyHub)
-- Authenticated Identity: Firebase JWT Subject (auth.jwt()->>'sub') -> profiles.firebase_uid -> profiles.id (UUID)
-- ==============================================================================

-- 1. Safely add firebase_uid column to public.profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS firebase_uid TEXT;

-- 2. Ensure profiles.id generates UUID automatically if not supplied
ALTER TABLE public.profiles ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 3. Create unique index on firebase_uid for high-speed sub -> profile lookup
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_firebase_uid ON public.profiles(firebase_uid);

-- 4. Create Non-Recursive Security Definer Helper for Admin / Founder role lookup
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

-- 5. Drop old / obsolete policies on public.profiles
DROP POLICY IF EXISTS "Public profiles read access" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Anyone can insert profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;

-- 6. New Privacy-Safe RLS Policies on public.profiles
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

-- 7. Drop old / obsolete policies on public.properties
DROP POLICY IF EXISTS "Public properties read access" ON public.properties;
DROP POLICY IF EXISTS "Public can view active properties" ON public.properties;
DROP POLICY IF EXISTS "Owners can insert properties" ON public.properties;
DROP POLICY IF EXISTS "Owners can update their own properties" ON public.properties;
DROP POLICY IF EXISTS "Owners can delete their own properties" ON public.properties;
DROP POLICY IF EXISTS "Owner update own property" ON public.properties;
DROP POLICY IF EXISTS "Owner delete own property" ON public.properties;

-- 8. New Hardened RLS Policies on public.properties
-- Public can ONLY view active listings; Owners view own non-public records; Admins view all
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
