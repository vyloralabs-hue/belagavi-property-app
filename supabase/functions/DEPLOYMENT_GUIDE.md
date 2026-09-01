# Belagavi Property — Supabase Edge Functions Deployment & Configuration Guide

This document outlines the standard operating procedure for deploying the server-authoritative Razorpay payment engine to Supabase.

---

## 1. Mode Distinction

| Parameter | Test / Staging Mode | Live Production Mode |
| :--- | :--- | :--- |
| **Razorpay Key ID Prefix** | `rzp_test_...` | `rzp_live_...` |
| **Razorpay Key Secret** | Test key secret from Dashboard | Live key secret from Dashboard |
| **Bank Settlement** | Simulated / Test UPI & Cards | Real INR banking transaction |
| **Webhook Target** | `https://<STAGING_PROJECT>.supabase.co/functions/v1/razorpay-webhook` | `https://<PROD_PROJECT>.supabase.co/functions/v1/razorpay-webhook` |

---

## 2. Required Environment Secrets

Configure these secrets in the Supabase Dashboard (`Project Settings` > `Edge Functions` > `Secrets`) or via CLI:

```bash
# Test Mode
supabase secrets set RAZORPAY_KEY_ID=rzp_test_PLACEHOLDER
supabase secrets set RAZORPAY_KEY_SECRET=test_secret_PLACEHOLDER
supabase secrets set RAZORPAY_WEBHOOK_SECRET=test_webhook_secret_PLACEHOLDER

# Production Mode
supabase secrets set RAZORPAY_KEY_ID=rzp_live_PLACEHOLDER
supabase secrets set RAZORPAY_KEY_SECRET=live_secret_PLACEHOLDER
supabase secrets set RAZORPAY_WEBHOOK_SECRET=live_webhook_secret_PLACEHOLDER
```

> [!CAUTION]
> Never commit actual keys into Git or local source code files. Always set secrets directly in the Supabase Cloud console.

---

## 3. Database Migration Deployment

Ensure migration `00015_create_server_authoritative_payment_orders_and_webhooks.sql` is applied to the database:

```bash
supabase db push
```

---

## 4. Edge Functions Deployment

Deploy each function to the target Supabase project:

```bash
# 1. Order creation endpoint
supabase functions deploy create-razorpay-order

# 2. Payment verification endpoint
supabase functions deploy verify-razorpay-payment

# 3. Public Webhook receiver (disables JWT verification for incoming Razorpay requests)
supabase functions deploy razorpay-webhook --no-verify-jwt
```

Alternatively, run the automated deployment script:
```powershell
.\supabase\functions\deploy_payment_functions.ps1 -Environment test -ProjectRef <your-project-ref>
```

---

## 5. Razorpay Webhook Configuration in Merchant Dashboard

1. Log into the [Razorpay Dashboard](https://dashboard.razorpay.com/).
2. Navigate to **Settings** > **Webhooks** > **Add New Webhook**.
3. **Webhook URL:** `https://<YOUR_SUPABASE_PROJECT_REF>.supabase.co/functions/v1/razorpay-webhook`
4. **Secret:** Provide a strong random secret string (and set the same value in `RAZORPAY_WEBHOOK_SECRET` in Supabase Secrets).
5. **Active Events to Select:**
   * `payment.captured`
   * `order.paid`
   * `payment.failed`
6. Click **Save Webhook**.

---

## 6. Pre-Launch Verification Checklist

- [ ] Migration `00015` applied and confirmed (`SELECT count(*) FROM pricing_plans;` returns 9 rows).
- [ ] `create-razorpay-order` responds with `401` when invoked without a JWT token.
- [ ] `verify-razorpay-payment` rejects forged HMAC signatures with `400 Invalid payment signature`.
- [ ] `razorpay-webhook` responds with `400` when invoked without `x-razorpay-signature`.
- [ ] Test transaction executed in Flutter app with Razorpay Test Mode card/UPI.
- [ ] Verification confirmed in `public.payment_orders` (`status = 'captured'`).
- [ ] Entitlement confirmed in `public.user_entitlements` and `public.property_promotions`.
- [ ] Invoice verified in `public.invoices` with 18% GST breakdown.

---

## 7. Rollback & Recovery Procedures

If an issue occurs post-deployment:
1. **Revert Edge Functions:**
   Redeploy previous stable Edge Function commit via `supabase functions deploy <function-name>`.
2. **Disable Inactive Pricing Plans:**
   Update `pricing_plans` table: `UPDATE pricing_plans SET is_active = FALSE WHERE plan_id = '...';` to prevent new checkout orders.
3. **Audit Log Inspection:**
   Query `public.financial_audit_logs` to inspect all recent state transitions and failure reasons.
