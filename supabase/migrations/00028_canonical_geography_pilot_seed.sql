-- =============================================================================
-- BELAGAVI PROPERTY PLATFORM — MIGRATION 00028: CANONICAL GEOGRAPHY PILOT SEED
-- Scope: Pilot Controlled Hierarchy (India -> Karnataka / Maharashtra)
-- ID Strategy: Natural key lookups resolving to canonical UUIDs (Idempotent ON CONFLICT / WHERE NOT EXISTS)
-- Hardening: Guaranteed NULL-safe alias idempotency using WHERE NOT EXISTS predicates.
-- Status: PREPARED PILOT SEED — DO NOT DEPLOY AUTOMATICALLY
-- =============================================================================

DO 
DECLARE
    -- State IDs
    v_st_ka UUID;
    v_st_mh UUID;

    -- District IDs
    v_dst_belagavi UUID;
    v_dst_dharwad UUID;
    v_dst_bangalore UUID;
    v_dst_pune UUID;
    v_dst_mumbai UUID;

    -- Taluk IDs
    v_tlk_belagavi UUID;
    v_tlk_chikodi UUID;
    v_tlk_gokak UUID;
    v_tlk_athani UUID;
    v_tlk_hubballi UUID;
    v_tlk_dharwad UUID;

    -- City IDs
    v_ct_belagavi UUID;
    v_ct_hubballi UUID;
    v_ct_dharwad UUID;
    v_ct_bengaluru UUID;
    v_ct_pune UUID;
    v_ct_mumbai UUID;

    -- Locality IDs
    v_loc_tilakwadi UUID;
    v_loc_shahapur UUID;
    v_loc_piranwadi UUID;
    v_loc_camp UUID;
    v_loc_udyambag UUID;
    v_loc_hindalga UUID;
    v_loc_hanuman_nagar UUID;
    v_loc_college_rd UUID;

BEGIN
    -- 1. Country: India
    INSERT INTO public.countries (code, name, normalized_name, dial_code, currency_code, currency_symbol, is_active)
    VALUES ('IN', 'India', 'india', '+91', 'INR', '₹', true)
    ON CONFLICT (code) DO UPDATE
    SET name = EXCLUDED.name, normalized_name = EXCLUDED.normalized_name;

    -- 2. States: Karnataka, Maharashtra
    INSERT INTO public.states (country_code, name, normalized_name, code, is_union_territory, translations, is_active)
    VALUES
        ('IN', 'Karnataka', 'karnataka', 'KA', false, '{"kn": "ಕರ್ನಾಟಕ", "hi": "कर्नाटक"}'::jsonb, true),
        ('IN', 'Maharashtra', 'maharashtra', 'MH', false, '{"mr": "महाराष्ट्र", "hi": "महाराष्ट्र"}'::jsonb, true)
    ON CONFLICT (country_code, normalized_name) DO UPDATE
    SET name = EXCLUDED.name, code = EXCLUDED.code;

    SELECT id INTO v_st_ka FROM public.states WHERE country_code = 'IN' AND normalized_name = 'karnataka';
    SELECT id INTO v_st_mh FROM public.states WHERE country_code = 'IN' AND normalized_name = 'maharashtra';

    ASSERT v_st_ka IS NOT NULL, 'Parent state Karnataka failed to resolve.';
    ASSERT v_st_mh IS NOT NULL, 'Parent state Maharashtra failed to resolve.';

    -- 3. Districts
    INSERT INTO public.districts (state_id, name, normalized_name, state_code, is_active)
    VALUES
        (v_st_ka, 'Belagavi', 'belagavi', 'KA', true),
        (v_st_ka, 'Dharwad', 'dharwad', 'KA', true),
        (v_st_ka, 'Bengaluru Urban', 'bengaluru urban', 'KA', true),
        (v_st_mh, 'Pune', 'pune', 'MH', true),
        (v_st_mh, 'Mumbai City', 'mumbai city', 'MH', true)
    ON CONFLICT (state_id, normalized_name) DO UPDATE
    SET name = EXCLUDED.name, state_code = EXCLUDED.state_code;

    SELECT id INTO v_dst_belagavi FROM public.districts WHERE state_id = v_st_ka AND normalized_name = 'belagavi';
    SELECT id INTO v_dst_dharwad FROM public.districts WHERE state_id = v_st_ka AND normalized_name = 'dharwad';
    SELECT id INTO v_dst_bangalore FROM public.districts WHERE state_id = v_st_ka AND normalized_name = 'bengaluru urban';
    SELECT id INTO v_dst_pune FROM public.districts WHERE state_id = v_st_mh AND normalized_name = 'pune';
    SELECT id INTO v_dst_mumbai FROM public.districts WHERE state_id = v_st_mh AND normalized_name = 'mumbai city';

    ASSERT v_dst_belagavi IS NOT NULL, 'District Belagavi failed to resolve.';
    ASSERT v_dst_dharwad IS NOT NULL, 'District Dharwad failed to resolve.';
    ASSERT v_dst_bangalore IS NOT NULL, 'District Bengaluru Urban failed to resolve.';
    ASSERT v_dst_pune IS NOT NULL, 'District Pune failed to resolve.';
    ASSERT v_dst_mumbai IS NOT NULL, 'District Mumbai City failed to resolve.';

    -- 4. Taluks (Karnataka Pilot)
    INSERT INTO public.taluks (district_id, name, normalized_name, is_active)
    VALUES
        (v_dst_belagavi, 'Belagavi', 'belagavi', true),
        (v_dst_belagavi, 'Chikodi', 'chikodi', true),
        (v_dst_belagavi, 'Gokak', 'gokak', true),
        (v_dst_belagavi, 'Athani', 'athani', true),
        (v_dst_dharwad, 'Hubballi', 'hubballi', true),
        (v_dst_dharwad, 'Dharwad', 'dharwad', true)
    ON CONFLICT (district_id, normalized_name) DO UPDATE
    SET name = EXCLUDED.name;

    SELECT id INTO v_tlk_belagavi FROM public.taluks WHERE district_id = v_dst_belagavi AND normalized_name = 'belagavi';
    SELECT id INTO v_tlk_chikodi FROM public.taluks WHERE district_id = v_dst_belagavi AND normalized_name = 'chikodi';
    SELECT id INTO v_tlk_gokak FROM public.taluks WHERE district_id = v_dst_belagavi AND normalized_name = 'gokak';
    SELECT id INTO v_tlk_athani FROM public.taluks WHERE district_id = v_dst_belagavi AND normalized_name = 'athani';
    SELECT id INTO v_tlk_hubballi FROM public.taluks WHERE district_id = v_dst_dharwad AND normalized_name = 'hubballi';
    SELECT id INTO v_tlk_dharwad FROM public.taluks WHERE district_id = v_dst_dharwad AND normalized_name = 'dharwad';

    ASSERT v_tlk_belagavi IS NOT NULL, 'Taluk Belagavi failed to resolve.';
    ASSERT v_tlk_hubballi IS NOT NULL, 'Taluk Hubballi failed to resolve.';
    ASSERT v_tlk_dharwad IS NOT NULL, 'Taluk Dharwad failed to resolve.';

    -- 5. Cities (Pilot Cities with approximate city-center reference points)
    INSERT INTO public.cities (district_id, taluk_id, name, normalized_name, is_tier1, is_tier2, latitude, longitude, is_active)
    VALUES
        (v_dst_belagavi, v_tlk_belagavi, 'Belagavi', 'belagavi', false, true, 15.8497, 74.4977, true),
        (v_dst_dharwad, v_tlk_hubballi, 'Hubballi', 'hubballi', false, true, 15.3647, 75.1240, true),
        (v_dst_dharwad, v_tlk_dharwad, 'Dharwad', 'dharwad', false, true, 15.4589, 75.0078, true),
        (v_dst_bangalore, NULL, 'Bengaluru', 'bengaluru', true, false, 12.9716, 77.5946, true),
        (v_dst_pune, NULL, 'Pune', 'pune', true, false, 18.5204, 73.8567, true),
        (v_dst_mumbai, NULL, 'Mumbai', 'mumbai', true, false, 19.0760, 72.8777, true)
    ON CONFLICT (district_id, normalized_name) DO UPDATE
    SET name = EXCLUDED.name, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude;

    SELECT id INTO v_ct_belagavi FROM public.cities WHERE district_id = v_dst_belagavi AND normalized_name = 'belagavi';
    SELECT id INTO v_ct_hubballi FROM public.cities WHERE district_id = v_dst_dharwad AND normalized_name = 'hubballi';
    SELECT id INTO v_ct_dharwad FROM public.cities WHERE district_id = v_dst_dharwad AND normalized_name = 'dharwad';
    SELECT id INTO v_ct_bengaluru FROM public.cities WHERE district_id = v_dst_bangalore AND normalized_name = 'bengaluru';
    SELECT id INTO v_ct_pune FROM public.cities WHERE district_id = v_dst_pune AND normalized_name = 'pune';
    SELECT id INTO v_ct_mumbai FROM public.cities WHERE district_id = v_dst_mumbai AND normalized_name = 'mumbai';

    ASSERT v_ct_belagavi IS NOT NULL, 'City Belagavi failed to resolve.';
    ASSERT v_ct_hubballi IS NOT NULL, 'City Hubballi failed to resolve.';
    ASSERT v_ct_dharwad IS NOT NULL, 'City Dharwad failed to resolve.';
    ASSERT v_ct_bengaluru IS NOT NULL, 'City Bengaluru failed to resolve.';
    ASSERT v_ct_pune IS NOT NULL, 'City Pune failed to resolve.';
    ASSERT v_ct_mumbai IS NOT NULL, 'City Mumbai failed to resolve.';

    -- 6. Localities: Verified Belagavi Pilot Localities (with verified pincodes from curated directory)
    INSERT INTO public.localities (city_id, name, normalized_name, pincode, is_active)
    VALUES
        (v_ct_belagavi, 'Tilakwadi', 'tilakwadi', '590006', true),
        (v_ct_belagavi, 'Shahapur', 'shahapur', '590003', true),
        (v_ct_belagavi, 'Piranwadi', 'piranwadi', '590014', true),
        (v_ct_belagavi, 'Camp', 'camp', '590001', true),
        (v_ct_belagavi, 'Udyambag', 'udyambag', '590008', true),
        (v_ct_belagavi, 'Hindalga', 'hindalga', '591108', true),
        (v_ct_belagavi, 'Hanuman Nagar', 'hanuman nagar', '590019', true),
        (v_ct_belagavi, 'College Road', 'college road', '590001', true)
    ON CONFLICT (city_id, normalized_name) DO UPDATE
    SET name = EXCLUDED.name, pincode = EXCLUDED.pincode;

    SELECT id INTO v_loc_tilakwadi FROM public.localities WHERE city_id = v_ct_belagavi AND normalized_name = 'tilakwadi';
    SELECT id INTO v_loc_shahapur FROM public.localities WHERE city_id = v_ct_belagavi AND normalized_name = 'shahapur';
    SELECT id INTO v_loc_piranwadi FROM public.localities WHERE city_id = v_ct_belagavi AND normalized_name = 'piranwadi';

    ASSERT v_loc_tilakwadi IS NOT NULL, 'Locality Tilakwadi failed to resolve.';
    ASSERT v_loc_shahapur IS NOT NULL, 'Locality Shahapur failed to resolve.';
    ASSERT v_loc_piranwadi IS NOT NULL, 'Locality Piranwadi failed to resolve.';

    -- 7. Master Location Aliases
    -- Idempotent City Aliases using WHERE NOT EXISTS on (normalized_alias, city_id)
    -- Matching partial unique index uq_alias_city_target:
    INSERT INTO public.location_aliases (entity_type, alias, normalized_alias, city_id, locality_id, state_id, parent_city_id, is_active)
    SELECT 'city', 'Belgaum', 'belgaum', v_ct_belagavi, NULL, NULL, NULL, true
    WHERE NOT EXISTS (
        SELECT 1 FROM public.location_aliases WHERE entity_type = 'city' AND normalized_alias = 'belgaum' AND city_id = v_ct_belagavi
    );

    INSERT INTO public.location_aliases (entity_type, alias, normalized_alias, city_id, locality_id, state_id, parent_city_id, is_active)
    SELECT 'city', 'bgm', 'bgm', v_ct_belagavi, NULL, NULL, NULL, true
    WHERE NOT EXISTS (
        SELECT 1 FROM public.location_aliases WHERE entity_type = 'city' AND normalized_alias = 'bgm' AND city_id = v_ct_belagavi
    );

    INSERT INTO public.location_aliases (entity_type, alias, normalized_alias, city_id, locality_id, state_id, parent_city_id, is_active)
    SELECT 'city', 'belagaon', 'belagaon', v_ct_belagavi, NULL, NULL, NULL, true
    WHERE NOT EXISTS (
        SELECT 1 FROM public.location_aliases WHERE entity_type = 'city' AND normalized_alias = 'belagaon' AND city_id = v_ct_belagavi
    );

    INSERT INTO public.location_aliases (entity_type, alias, normalized_alias, city_id, locality_id, state_id, parent_city_id, is_active)
    SELECT 'city', 'Hubli', 'hubli', v_ct_hubballi, NULL, NULL, NULL, true
    WHERE NOT EXISTS (
        SELECT 1 FROM public.location_aliases WHERE entity_type = 'city' AND normalized_alias = 'hubli' AND city_id = v_ct_hubballi
    );

    INSERT INTO public.location_aliases (entity_type, alias, normalized_alias, city_id, locality_id, state_id, parent_city_id, is_active)
    SELECT 'city', 'Bangalore', 'bangalore', v_ct_bengaluru, NULL, NULL, NULL, true
    WHERE NOT EXISTS (
        SELECT 1 FROM public.location_aliases WHERE entity_type = 'city' AND normalized_alias = 'bangalore' AND city_id = v_ct_bengaluru
    );

    INSERT INTO public.location_aliases (entity_type, alias, normalized_alias, city_id, locality_id, state_id, parent_city_id, is_active)
    SELECT 'city', 'blr', 'blr', v_ct_bengaluru, NULL, NULL, NULL, true
    WHERE NOT EXISTS (
        SELECT 1 FROM public.location_aliases WHERE entity_type = 'city' AND normalized_alias = 'blr' AND city_id = v_ct_bengaluru
    );

    INSERT INTO public.location_aliases (entity_type, alias, normalized_alias, city_id, locality_id, state_id, parent_city_id, is_active)
    SELECT 'city', 'Poona', 'poona', v_ct_pune, NULL, NULL, NULL, true
    WHERE NOT EXISTS (
        SELECT 1 FROM public.location_aliases WHERE entity_type = 'city' AND normalized_alias = 'poona' AND city_id = v_ct_pune
    );

    INSERT INTO public.location_aliases (entity_type, alias, normalized_alias, city_id, locality_id, state_id, parent_city_id, is_active)
    SELECT 'city', 'Bombay', 'bombay', v_ct_mumbai, NULL, NULL, NULL, true
    WHERE NOT EXISTS (
        SELECT 1 FROM public.location_aliases WHERE entity_type = 'city' AND normalized_alias = 'bombay' AND city_id = v_ct_mumbai
    );

    -- Idempotent Locality Aliases using WHERE NOT EXISTS on (normalized_alias, locality_id, parent_city_id)
    -- Matching partial unique index uq_alias_locality_target:
    INSERT INTO public.location_aliases (entity_type, alias, normalized_alias, city_id, locality_id, state_id, parent_city_id, is_active)
    SELECT 'locality', 'Tilakvadi', 'tilakvadi', NULL, v_loc_tilakwadi, NULL, v_ct_belagavi, true
    WHERE NOT EXISTS (
        SELECT 1 FROM public.location_aliases WHERE entity_type = 'locality' AND normalized_alias = 'tilakvadi' AND locality_id = v_loc_tilakwadi AND parent_city_id = v_ct_belagavi
    );

    INSERT INTO public.location_aliases (entity_type, alias, normalized_alias, city_id, locality_id, state_id, parent_city_id, is_active)
    SELECT 'locality', 'Piranvadi', 'piranvadi', NULL, v_loc_piranwadi, NULL, v_ct_belagavi, true
    WHERE NOT EXISTS (
        SELECT 1 FROM public.location_aliases WHERE entity_type = 'locality' AND normalized_alias = 'piranvadi' AND locality_id = v_loc_piranwadi AND parent_city_id = v_ct_belagavi
    );

    -- Scoped Locality Alias: Shahpur -> Shahapur strictly scoped to Belagavi
    INSERT INTO public.location_aliases (entity_type, alias, normalized_alias, city_id, locality_id, state_id, parent_city_id, is_active)
    SELECT 'locality', 'Shahpur', 'shahpur', NULL, v_loc_shahapur, NULL, v_ct_belagavi, true
    WHERE NOT EXISTS (
        SELECT 1 FROM public.location_aliases WHERE entity_type = 'locality' AND normalized_alias = 'shahpur' AND locality_id = v_loc_shahapur AND parent_city_id = v_ct_belagavi
    );

END ;
