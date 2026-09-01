-- Migration: 00007_create_property_inquiries_rls.sql
-- Description: Create property_inquiries table with Row-Level Security for Buyer, Seller, and Admin

CREATE TABLE IF NOT EXISTS public.property_inquiries (
    id TEXT PRIMARY KEY,
    property_id TEXT NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    property_title TEXT NOT NULL,
    property_category TEXT,
    property_location TEXT,
    buyer_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    buyer_name TEXT NOT NULL,
    buyer_phone TEXT NOT NULL,
    buyer_email TEXT,
    seller_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    interest_type TEXT NOT NULL DEFAULT 'buy',
    initial_message TEXT NOT NULL,
    preferred_contact_method TEXT DEFAULT 'Phone Call',
    preferred_visit_date TEXT,
    preferred_visit_time TEXT,
    financing_status TEXT,
    listed_price NUMERIC,
    monthly_rent NUMERIC,
    deposit_amount NUMERIC,
    lease_duration_months INTEGER,
    buyer_offer_price NUMERIC,
    seller_counter_offer_price NUMERIC,
    current_negotiated_amount NUMERIC,
    offer_status TEXT DEFAULT 'submitted',
    negotiation_history JSONB DEFAULT '[]'::jsonb,
    status TEXT NOT NULL DEFAULT 'newEnquiry',
    site_visit_status TEXT NOT NULL DEFAULT 'none',
    scheduled_visit_date_time TIMESTAMPTZ,
    site_visit_notes TEXT,
    doc_verification_status TEXT DEFAULT 'notStarted',
    doc_verification_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indices for rapid buyer and seller lookups
CREATE INDEX IF NOT EXISTS idx_property_inquiries_buyer_id ON public.property_inquiries(buyer_id);
CREATE INDEX IF NOT EXISTS idx_property_inquiries_seller_id ON public.property_inquiries(seller_id);
CREATE INDEX IF NOT EXISTS idx_property_inquiries_property_id ON public.property_inquiries(property_id);
CREATE INDEX IF NOT EXISTS idx_property_inquiries_status ON public.property_inquiries(status);

-- Enable Row-Level Security
ALTER TABLE public.property_inquiries ENABLE ROW LEVEL SECURITY;

-- 1. SELECT Policy:
-- Authenticated users can view inquiries if they are the buyer, the property seller/owner, or an Admin/Founder
CREATE POLICY "Users can view relevant inquiries"
ON public.property_inquiries
FOR SELECT
TO authenticated
USING (
    buyer_id = (SELECT auth.uid())::text
    OR seller_id = (SELECT auth.uid())::text
    OR public.is_admin_or_owner_role()
);

-- 2. INSERT Policy:
-- Authenticated buyers can submit inquiries for properties (buyer_id must match authenticated session)
CREATE POLICY "Authenticated buyers can create inquiries"
ON public.property_inquiries
FOR INSERT
TO authenticated
WITH CHECK (
    buyer_id = (SELECT auth.uid())::text
    OR public.is_admin_or_owner_role()
);

-- 3. UPDATE Policy:
-- Buyer, Seller, or Admin can update their respective transaction states
CREATE POLICY "Participants and admins can update inquiries"
ON public.property_inquiries
FOR UPDATE
TO authenticated
USING (
    buyer_id = (SELECT auth.uid())::text
    OR seller_id = (SELECT auth.uid())::text
    OR public.is_admin_or_owner_role()
)
WITH CHECK (
    buyer_id = (SELECT auth.uid())::text
    OR seller_id = (SELECT auth.uid())::text
    OR public.is_admin_or_owner_role()
);

-- 4. DELETE Policy:
-- Admin/Founder or listing owner can delete/cancel inactive inquiries
CREATE POLICY "Admins and sellers can delete inquiries"
ON public.property_inquiries
FOR DELETE
TO authenticated
USING (
    seller_id = (SELECT auth.uid())::text
    OR public.is_admin_or_owner_role()
);
