-- ==============================================================================
-- Migration 00021a: Add firebase_uid column and index to public.profiles
-- Project: Belagavi Property (PropertyHub)
-- Step 1 of 2: Schema Column & Index Addition (Pure DDL, No Policies)
-- ==============================================================================

-- 1. Safely add firebase_uid column to public.profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS firebase_uid TEXT;

-- 2. Ensure profiles.id generates UUID automatically if omitted on insert
ALTER TABLE public.profiles ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 3. Create unique index on firebase_uid for fast lookup & constraint integrity
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_firebase_uid ON public.profiles(firebase_uid);
