-- ==============================================================================
-- Migration 00029: Decouple Profiles From Supabase auth.users
-- Project: Belagavi Property (PropertyHub)
-- Target Identity Architecture:
--   Firebase UID (auth.jwt()->>'sub') -> profiles.firebase_uid (TEXT UNIQUE)
--   profiles.id (UUID PRIMARY KEY, gen_random_uuid()) -> properties.owner_id (UUID FK)
-- ==============================================================================

BEGIN;

-- 1. Safely drop legacy foreign key constraint linking profiles.id to auth.users.id
-- This allows external Firebase Third-Party Auth identities to be provisioned
-- into public.profiles without requiring duplicate rows in Supabase auth.users.
ALTER TABLE public.profiles 
    DROP CONSTRAINT IF EXISTS profiles_id_fkey;

-- 2. Guarantee profiles.id has automatic UUID generation
ALTER TABLE public.profiles 
    ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 3. Guarantee firebase_uid column exists on public.profiles
ALTER TABLE public.profiles 
    ADD COLUMN IF NOT EXISTS firebase_uid TEXT;

-- 4. Guarantee unique index on firebase_uid for fast lookup & 1:1 identity constraint
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_firebase_uid 
    ON public.profiles(firebase_uid);

-- 5. Hardened Profile Identity Guard Trigger:
-- Prevents clients from mutating their firebase_uid or self-escalating role / verification status
CREATE OR REPLACE FUNCTION public.protect_profile_identity_fields()
RETURNS TRIGGER AS $$
BEGIN
    -- Only allow app admin or founder to alter role or verification status
    IF NOT public.is_app_admin_or_founder() THEN
        IF NEW.firebase_uid IS DISTINCT FROM OLD.firebase_uid THEN
            RAISE EXCEPTION 'firebase_uid is immutable';
        END IF;
        IF NEW.role IS DISTINCT FROM OLD.role THEN
            RAISE EXCEPTION 'role cannot be modified by user';
        END IF;
        IF NEW.is_verified IS DISTINCT FROM OLD.is_verified THEN
            RAISE EXCEPTION 'is_verified cannot be modified by user';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_protect_profile_identity ON public.profiles;
CREATE TRIGGER trg_protect_profile_identity
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.protect_profile_identity_fields();

COMMIT;
