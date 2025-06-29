#!/usr/bin/env pwsh

# PowerShell script to test Doctor Availability API

$BASE_URL = "http://localhost:3000"
$DOCTOR_EMAIL = "doctor.smith@hospital.com"
$DOCTOR_PASSWORD = "Doctor@123"

Write-Host "🔐 Step 1: Doctor Sign In..." -ForegroundColor Yellow

# Sign in to get token
$signinBody = @{
    email = $DOCTOR_EMAIL
    password = $DOCTOR_PASSWORD
} | ConvertTo-Json

try {
    $signinResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/doctor/signin" -Method Post -Body $signinBody -ContentType "application/json"
    $token = $signinResponse.access_token
    Write-Host "✅ Sign in successful" -ForegroundColor Green
    Write-Host "Token: $token" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Sign in failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n📅 Step 2: Testing Valid Availability..." -ForegroundColor Yellow

# Test valid availability
$availabilityBody = @{
    from = "2025-06-29T09:00:00.000Z"
    to = "2025-06-29T17:00:00.000Z"
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $availabilityResponse = Invoke-RestMethod -Uri "$BASE_URL/doctor/set-availability" -Method Post -Body $availabilityBody -Headers $headers
    Write-Host "✅ Availability set successfully:" -ForegroundColor Green
    Write-Host ($availabilityResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
} catch {
    Write-Host "❌ Availability test failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorContent = $reader.ReadToEnd()
        Write-Host "Error details: $errorContent" -ForegroundColor Red
    }
}

Write-Host "`n❌ Step 3: Testing Invalid Availability (missing from field)..." -ForegroundColor Yellow

# Test invalid availability - missing from
$invalidBody = @{
    to = "2025-06-29T17:00:00.000Z"
} | ConvertTo-Json

try {
    $invalidResponse = Invoke-RestMethod -Uri "$BASE_URL/doctor/set-availability" -Method Post -Body $invalidBody -Headers $headers
    Write-Host "⚠️ Unexpected success (should have failed)" -ForegroundColor Yellow
} catch {
    Write-Host "✅ Expected validation error:" -ForegroundColor Green
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorContent = $reader.ReadToEnd()
        Write-Host $errorContent -ForegroundColor Cyan
    }
}

Write-Host "`n❌ Step 4: Testing Invalid Date Format..." -ForegroundColor Yellow

# Test invalid date format
$invalidDateBody = @{
    from = "2025-06-29 09:00:00"
    to = "2025-06-29 17:00:00"
} | ConvertTo-Json

try {
    $invalidDateResponse = Invoke-RestMethod -Uri "$BASE_URL/doctor/set-availability" -Method Post -Body $invalidDateBody -Headers $headers
    Write-Host "⚠️ Unexpected success (should have failed)" -ForegroundColor Yellow
} catch {
    Write-Host "✅ Expected validation error for invalid date format:" -ForegroundColor Green
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorContent = $reader.ReadToEnd()
        Write-Host $errorContent -ForegroundColor Cyan
    }
}

Write-Host "`n✅ All tests completed!" -ForegroundColor Green
Write-Host "`n📋 Valid request format example:" -ForegroundColor Yellow
Write-Host @"
{
  "from": "2025-06-29T09:00:00.000Z",
  "to": "2025-06-29T17:00:00.000Z"
}
"@ -ForegroundColor Cyan
