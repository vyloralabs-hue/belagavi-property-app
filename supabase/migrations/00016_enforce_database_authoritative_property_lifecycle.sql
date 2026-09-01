-- Migration: 00016_enforce_database_authoritative_property_lifecycle.sql
-- Description: Enforces authoritative database-level property lifecycle security, owner immutability, and admin lock guarantees.

-- 1. Helper function to check if the current user possesses administrative / founder authority
CREATE OR REPLACE FUNCTION public.is_app_admin_or_founder()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() 
        AND role::text IN ('admin', 'founder', 'super_admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Trigger function enforcing authoritative lifecycle rules
CREATE OR REPLACE FUNCTION public.enforce_property_lifecycle_rules()
RETURNS TRIGGER AS $$
BEGIN
    -- If user possesses Admin or Founder authority, permit global moderation override
    IF public.is_app_admin_or_founder() OR public.is_admin_or_owner_role() THEN
        RETURN NEW;
    END IF;

    -- 1. Owner ID is strictly immutable
    IF NEW.owner_id <> OLD.owner_id THEN
        RAISE EXCEPTION 'Access Denied: Property owner_id cannot be changed.';
    END IF;

    -- 2. Verification Status is authoritative and controlled strictly by platform admins
    IF NEW.verification_status <> OLD.verification_status THEN
        RAISE EXCEPTION 'Access Denied: Property verification status is controlled by administrator.';
    END IF;

    -- 3. Customer cannot bypass administrative locks (rejected, disputed, archived)
    IF OLD.status::text IN ('rejected', 'disputed', 'archived') THEN
        IF NEW.status::text IN ('approved', 'published', 'active') THEN
            RAISE EXCEPTION 'Access Denied: Cannot bypass administrative restriction from status % to %.', OLD.status, NEW.status;
        END IF;
    END IF;

    -- 4. Customer cannot self-approve or publish without admin verification
    IF OLD.status::text IN ('draft', 'submitted', 'pending_verification', 'under_review') THEN
        IF NEW.status::text IN ('approved', 'published', 'active') THEN
            RAISE EXCEPTION 'Access Denied: Property must be reviewed and approved by administrator before publication.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Attach trigger to public.properties table
DROP TRIGGER IF EXISTS trg_enforce_property_lifecycle ON public.properties;

CREATE TRIGGER trg_enforce_property_lifecycle
BEFORE UPDATE ON public.properties
FOR EACH ROW
EXECUTE FUNCTION public.enforce_property_lifecycle_rules();

-- 4. Harden Delete Policy: Customers cannot delete Disputed or Sold listings
DROP POLICY IF EXISTS "Properties delete policy" ON public.properties;

CREATE POLICY "Hardened properties delete policy"
ON public.properties FOR DELETE
TO authenticated
USING (
    (
        auth.uid() = owner_id 
        AND status::text NOT IN ('disputed', 'sold')
    )
    OR public.is_app_admin_or_founder()
);
