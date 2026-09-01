-- ==========================================
-- Migration 00001: Create Enterprise ENUM Types
-- Project: Belagavi Property (PropertyHub)
-- ==========================================

-- User Roles
CREATE TYPE user_role AS ENUM (
    'buyer',
    'seller',
    'broker',
    'builder',
    'admin',
    'founder',
    'super_admin'
);

-- Property Category
CREATE TYPE property_category AS ENUM (
    'residential',
    'commercial',
    'plot_land',
    'land',
    'builder_project',
    'other'
);

-- Property Sub-Type
CREATE TYPE property_type AS ENUM (
    'apartment',
    'villa',
    'independent_house',
    'row_house',
    'penthouse',
    'commercial_shop',
    'commercial_office',
    'commercial_showroom',
    'warehouse_godown',
    'residential_plot',
    'commercial_plot',
    'agricultural_land',
    'na_land',
    'builder_apartment_project',
    'builder_gated_community',
    'raw_land',
    'other'
);

-- Listing Status
CREATE TYPE listing_status AS ENUM (
    'draft',
    'submitted',
    'pending_verification',
    'under_review',
    'changes_requested',
    'approved',
    'published',
    'active',
    'paused',
    'rejected',
    'sold',
    'rented',
    'leased',
    'disputed',
    'archived'
);

-- Verification Status
CREATE TYPE verification_status AS ENUM (
    'unverified',
    'pending',
    'changes_requested',
    'verified',
    'rejected'
);

-- Media Type
CREATE TYPE media_type AS ENUM (
    'image',
    'video',
    'virtual_tour_360',
    'floor_plan',
    'legal_document'
);
