-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 1 SUPABASE DATABASE SCHEMA MIGRATION
-- Safe Additive DDL Migration Script for Phase 1 Foundation
-- Target Schema Version: 1.1.0
-- Created: 2026-08-07
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. PROPERTY DOCUMENTS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.property_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id VARCHAR(255) NOT NULL,
    document_type VARCHAR(100) NOT NULL, -- encumbranceCertificate, saleDeed, rtcKatha, taxReceipt, reraDoc, other
    document_name VARCHAR(255) NOT NULL,
    document_url TEXT NOT NULL,
    uploaded_by VARCHAR(255) NOT NULL,
    verification_status VARCHAR(50) DEFAULT 'pending', -- unverified, pending, verified, rejected
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_property_documents_property_id ON public.property_documents(property_id);
CREATE INDEX IF NOT EXISTS idx_property_documents_status ON public.property_documents(verification_status);

-- -----------------------------------------------------------------------------
-- 2. PROPERTY UNLOCKS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.property_unlocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    unlock_type VARCHAR(50) NOT NULL, -- payPerProperty, credit, membership
    amount NUMERIC(12, 2) DEFAULT 0.00,
    credits_used INT DEFAULT 0,
    unlocked_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    status VARCHAR(50) DEFAULT 'active', -- active, expired, revoked
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_property_unlocks_user_property ON public.property_unlocks(user_id, property_id);
CREATE INDEX IF NOT EXISTS idx_property_unlocks_status ON public.property_unlocks(status);

-- -----------------------------------------------------------------------------
-- 3. BUILDER PROJECTS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    builder_id VARCHAR(255) NOT NULL,
    project_name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    project_type VARCHAR(100) NOT NULL, -- apartment, gatedCommunity, villaProject, commercialComplex, mixedUse
    status VARCHAR(50) DEFAULT 'underConstruction', -- upcoming, underConstruction, readyToMove, completed
    country VARCHAR(100) DEFAULT 'India',
    state VARCHAR(100) DEFAULT 'Karnataka',
    district VARCHAR(100) DEFAULT 'Belagavi',
    city VARCHAR(100) DEFAULT 'Belagavi',
    locality VARCHAR(255) NOT NULL,
    approximate_location VARCHAR(255) NOT NULL,
    exact_location TEXT NOT NULL, -- Protected location field
    rera_number VARCHAR(100),
    possession_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_projects_builder_id ON public.projects(builder_id);
CREATE INDEX IF NOT EXISTS idx_projects_city_locality ON public.projects(city, locality);

-- -----------------------------------------------------------------------------
-- 4. PROJECT TOWERS TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.towers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    tower_name VARCHAR(100) NOT NULL,
    total_floors INT NOT NULL DEFAULT 1,
    status VARCHAR(50) DEFAULT 'underConstruction', -- planned, underConstruction, completed
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_towers_project_id ON public.towers(project_id);

-- -----------------------------------------------------------------------------
-- 5. UNIT INVENTORY TABLE
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.unit_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    tower_id UUID NOT NULL REFERENCES public.towers(id) ON DELETE CASCADE,
    unit_number VARCHAR(50) NOT NULL,
    floor_number INT NOT NULL DEFAULT 1,
    unit_type VARCHAR(50) NOT NULL, -- 1BHK, 2BHK, 3BHK, 4BHK, penthouse, duplex, shop, office
    carpet_area NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    built_up_area NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    price NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    availability_status VARCHAR(50) DEFAULT 'AVAILABLE', -- AVAILABLE, RESERVED, SOLD, BLOCKED
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_unit_inventory_tower ON public.unit_inventory(tower_id);
CREATE INDEX IF NOT EXISTS idx_unit_inventory_status ON public.unit_inventory(availability_status);
