# =============================================================================
# Belagavi Property - Supabase Payment Edge Functions Deployment Script
# Operating System: Windows PowerShell
# Safety: Fail-fast, secret-safe (never prints or commits secrets), environment-checked
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [ValidateSet('test', 'prod')]
    [string]$Environment = 'test',

    [Parameter(Mandatory=$false)]
    [string]$ProjectRef = ''
)

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  BELAGAVI PROPERTY - PAYMENT EDGE FUNCTION DEPLOYER ($Environment)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Check Supabase CLI Availability
if (-not (Get-Command "supabase" -ErrorAction SilentlyContinue)) {
    Write-Error "Supabase CLI is not installed or not in PATH. Please install from https://supabase.com/docs/guides/cli"
    exit 1
}

# 2. Check Target Project
if (-not $ProjectRef) {
    Write-Host "[INFO] No -ProjectRef supplied. Using currently linked Supabase project." -ForegroundColor Yellow
} else {
    Write-Host "[INFO] Target Supabase Project Reference: $ProjectRef" -ForegroundColor Green
}

# 3. Check Required Secret Environment Variables (without printing values)
$requiredVars = @("RAZORPAY_KEY_ID", "RAZORPAY_KEY_SECRET", "RAZORPAY_WEBHOOK_SECRET")
$missingVars = @()

foreach ($var in $requiredVars) {
    if (-not [System.Environment]::GetEnvironmentVariable($var)) {
        $missingVars += $var
    }
}

if ($missingVars.Count -gt 0) {
    Write-Host "[WARNING] The following local environment variables are not set for automated secret upload:" -ForegroundColor Yellow
    foreach ($m in $missingVars) {
        Write-Host "  - $m" -ForegroundColor Yellow
    }
    Write-Host "[INFO] Please ensure these secrets are configured in the Supabase Dashboard under Project Settings -> Edge Functions -> Secrets." -ForegroundColor Cyan
}

# 4. Deploy Functions Sequentially
$functions = @("create-razorpay-order", "verify-razorpay-payment", "razorpay-webhook")

foreach ($fn in $functions) {
    Write-Host "`n[DEPLOYING] supabase/functions/$fn..." -ForegroundColor Green
    if ($ProjectRef) {
        supabase functions deploy $fn --project-ref $ProjectRef --no-verify-jwt:$($fn -eq "razorpay-webhook")
    } else {
        supabase functions deploy $fn --no-verify-jwt:$($fn -eq "razorpay-webhook")
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Error "[FAILED] Deployment failed for function '$fn'. Aborting."
        exit 1
    }
    Write-Host "[SUCCESS] Deployed $fn." -ForegroundColor Green
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "  DEPLOYMENT COMPLETE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor White
Write-Host "1. Register Webhook URL in Razorpay Dashboard: https://<project-ref>.supabase.co/functions/v1/razorpay-webhook" -ForegroundColor White
Write-Host "2. Enable events: payment.captured, order.paid, payment.failed" -ForegroundColor White
Write-Host "3. Set Webhook Secret to match RAZORPAY_WEBHOOK_SECRET in Supabase Secrets." -ForegroundColor White
