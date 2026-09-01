-- ==========================================
-- Migration 00006: RBAC & Global Owner/Admin Authority on Properties RLS
-- Project: Belagavi Property (PropertyHub)
-- Description: Enforces Customer own-records isolation & App Owner/Admin global authority
-- ==========================================

-- 1. Helper function to check if the authenticated user possesses administrative / founder authority
CREATE OR REPLACE FUNCTION public.is_admin_or_owner_role()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() 
        AND role::text IN ('admin', 'founder', 'super_admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Drop legacy restrictive policies non-destructively
DROP POLICY IF EXISTS "Public read active verified properties" ON public.properties;
DROP POLICY IF EXISTS "Owners can insert their properties" ON public.properties;
DROP POLICY IF EXISTS "Owners can update their properties" ON public.properties;
DROP POLICY IF EXISTS "Owners can delete their properties" ON public.properties;

-- 3. Comprehensive RBAC Policies on public.properties

-- SELECT: Public can see active/published; Owners can see all their own; Admins/Owners see all.
CREATE POLICY "Properties select policy" 
    ON public.properties FOR SELECT 
    USING (
        status IN ('active', 'published') 
        OR auth.uid() = owner_id 
        OR public.is_admin_or_owner_role()
    );

-- INSERT: Authenticated users can insert properties where owner_id matches their uid, or Admin.
CREATE POLICY "Properties insert policy" 
    ON public.properties FOR INSERT 
    WITH CHECK (
        auth.uid() = owner_id 
        OR public.is_admin_or_owner_role()
    );

-- UPDATE: Authenticated owners can update their own records; Admins/Owners have global update authority.
CREATE POLICY "Properties update policy" 
    ON public.properties FOR UPDATE 
    USING (
        auth.uid() = owner_id 
        OR public.is_admin_or_owner_role()
    )
    WITH CHECK (
        auth.uid() = owner_id 
        OR public.is_admin_or_owner_role()
    );

-- DELETE: Authenticated owners can delete their own records; Admins/Owners have global delete authority.
CREATE POLICY "Properties delete policy" 
    ON public.properties FOR DELETE 
    USING (
        auth.uid() = owner_id 
        OR public.is_admin_or_owner_role()
    );
