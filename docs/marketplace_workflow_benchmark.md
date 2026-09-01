# Indian Property Portal — Marketplace Workflow Benchmark
## Platforms: Housing.com, Magicbricks, NoBroker, 99acres

See the walkthrough artifact for the full comparison.

## Quick Summary

All 4 platforms confirm:
1. OTP mobile login required before listing
2. Multi-step progressive form (5-8 steps)
3. Post-submission moderation gap (24 hrs standard) — listings NOT instantly live
4. Verification and Publishing are completely SEPARATE concepts
5. Dashboard with granular status: Active / Inactive / Under Screening / Expired
6. Freemium model — free basic listing; premium = boost + RM + photoshoot

## Canonical Belagavi Property Lifecycle

draft -> submitted -> under_review -> published (or changes_requested, rejected, paused)

Public visibility: ONLY published / active / approved
Private to owner: all other statuses

## Root Cause Fixed (Red Error)

PropertySearchRemoteDataSourceImpl was querying non-existent DB columns:
- country (does not exist in public.properties)  
- area (does not exist)
- built_up_area (does not exist; real: carpet_area, super_built_up_area, plot_area)
- listing_purpose (does not exist; stored in features JSONB)
- project_id / builder_id (do not exist)

PostgREST threw column-not-found exceptions -> ServerException -> Red error banner.

Also: PropertyModel.fromJson used Dart .name (camelCase) against DB snake_case values -> defaulted to draft.

Both fixed. Full research data in docs/marketplace_research_full.md (create separately).
