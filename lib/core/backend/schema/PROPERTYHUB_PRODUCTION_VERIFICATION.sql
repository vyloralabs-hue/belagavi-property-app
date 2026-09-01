-- =============================================================================
-- PROPERTYHUB / BELAGAVI PROPERTY PRODUCTION SCHEMA VERIFICATION QUERY
-- Registered Business Identity: BELAGAVI PROPERTY LLP
-- Purpose: Verify Live Database Deployment Status (PASS / FAIL)
-- =============================================================================

WITH expected_tables AS (
    SELECT unnest(ARRAY[
        'pricing_plans',
        'payment_orders',
        'payment_transactions',
        'entitlements',
        'advertising_placements',
        'ad_revenue_events',
        'invoices',
        'refunds',
        'financial_audit_logs',
        'property_promotion_entitlements',
        'property_promotion_events',
        'investment_interest_leads',
        'investment_projects',
        'investment_documents',
        'investment_content_config',
        'investment_audit_logs',
        'property_enquiries',
        'property_contact_requests',
        'owner_daily_metrics',
        'subscriptions',
        'developer_profiles',
        'developer_subscription_requirements',
        'professional_listing_access',
        'developer_subscription_audit',
        'builder_subscriptions',
        'land_developer_subscriptions',
        'subscription_plan_limits',
        'subscription_audit_logs'
    ]) AS table_name
),
table_check AS (
    SELECT 
        e.table_name,
        CASE WHEN t.table_name IS NOT NULL THEN 'PASS' ELSE 'FAIL (MISSING)' END AS table_status,
        CASE WHEN c.relrowsecurity THEN 'PASS (RLS ENABLED)' ELSE 'FAIL (NO RLS)' END AS rls_status
    FROM expected_tables e
    LEFT JOIN information_schema.tables t 
        ON t.table_schema = 'public' AND t.table_name = e.table_name
    LEFT JOIN pg_class c 
        ON c.relname = e.table_name AND c.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
)
SELECT 
    table_name,
    table_status,
    rls_status
FROM table_check
ORDER BY table_name;
