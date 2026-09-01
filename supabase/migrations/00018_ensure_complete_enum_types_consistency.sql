-- ==========================================
-- Migration 00018: Forward-Compatible ENUM Consistency Guarantee
-- Project: Belagavi Property (PropertyHub)
-- Description: Ensures all canonical enum values exist on existing databases
-- ==========================================

-- 1. Listing Status
ALTER TYPE public.listing_status ADD VALUE IF NOT EXISTS 'submitted';
ALTER TYPE public.listing_status ADD VALUE IF NOT EXISTS 'under_review';
ALTER TYPE public.listing_status ADD VALUE IF NOT EXISTS 'changes_requested';
ALTER TYPE public.listing_status ADD VALUE IF NOT EXISTS 'approved';
ALTER TYPE public.listing_status ADD VALUE IF NOT EXISTS 'published';
ALTER TYPE public.listing_status ADD VALUE IF NOT EXISTS 'paused';
ALTER TYPE public.listing_status ADD VALUE IF NOT EXISTS 'rented';
ALTER TYPE public.listing_status ADD VALUE IF NOT EXISTS 'leased';
ALTER TYPE public.listing_status ADD VALUE IF NOT EXISTS 'disputed';

-- 2. Verification Status
ALTER TYPE public.verification_status ADD VALUE IF NOT EXISTS 'changes_requested';

-- 3. User Roles
ALTER TYPE public.user_role ADD VALUE IF NOT EXISTS 'founder';
ALTER TYPE public.user_role ADD VALUE IF NOT EXISTS 'super_admin';

-- 4. Property Category
ALTER TYPE public.property_category ADD VALUE IF NOT EXISTS 'land';
ALTER TYPE public.property_category ADD VALUE IF NOT EXISTS 'other';

-- 5. Property Sub-Type
ALTER TYPE public.property_type ADD VALUE IF NOT EXISTS 'raw_land';
ALTER TYPE public.property_type ADD VALUE IF NOT EXISTS 'other';
