#!/usr/bin/env pwsh

# Complete JWT Test Script with Step-by-Step Data

$BASE_URL = "http://localhost:3000"

Write-Host "🔐 Doctor Availability API - Complete Test Suite" -ForegroundColor Yellow
Write-Host "=================================================" -ForegroundColor Yellow

# Step 1: Sign in
Write-Host "`n📝 Step 1: Doctor Sign In" -ForegroundColor Cyan
Write-Host "Endpoint: POST $BASE_URL/auth/doctor/signin" -ForegroundColor Gray

$signinBody = @{
    email = "doctor.smith@hospital.com"
    password = "Doctor@123"
} | ConvertTo-Json

Write-Host "`nRequest Body:" -ForegroundColor White
Write-Host $signinBody -ForegroundColor Gray

try {
    $signinResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/doctor/signin" -Method Post -Body $signinBody -ContentType "application/json"
    $token = $signinResponse.access_token
    
    Write-Host "`n✅ Sign In Successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor White
    Write-Host ($signinResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
    
    Write-Host "`n🔑 JWT Token (first 50 chars): $($token.Substring(0, 50))..." -ForegroundColor Yellow
}
catch {
    Write-Host "`n❌ Sign in failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Test debug endpoint to show JWT contents
Write-Host "`n📝 Step 2: Debug JWT Token Contents" -ForegroundColor Cyan
Write-Host "Endpoint: GET $BASE_URL/doctor/debug-token" -ForegroundColor Gray

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "`nRequest Headers:" -ForegroundColor White
Write-Host "Authorization: Bearer <token>" -ForegroundColor Gray
Write-Host "Content-Type: application/json" -ForegroundColor Gray

try {
    $debugResponse = Invoke-RestMethod -Uri "$BASE_URL/doctor/debug-token" -Method Get -Headers $headers
    Write-Host "`n✅ Debug Successful!" -ForegroundColor Green
    Write-Host "JWT Token Contents:" -ForegroundColor White
    Write-Host ($debugResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
}
catch {
    Write-Host "`n❌ Debug failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Test availability with valid data
Write-Host "`n📝 Step 3: Set Doctor Availability (Valid Data)" -ForegroundColor Cyan
Write-Host "Endpoint: POST $BASE_URL/doctor/set-availability" -ForegroundColor Gray

$availabilityBody = @{
    from = "2025-06-29T09:00:00.000Z"
    to = "2025-06-29T17:00:00.000Z"
} | ConvertTo-Json

Write-Host "`nRequest Headers:" -ForegroundColor White
Write-Host "Authorization: Bearer <token>" -ForegroundColor Gray
Write-Host "Content-Type: application/json" -ForegroundColor Gray

Write-Host "`nRequest Body:" -ForegroundColor White
Write-Host $availabilityBody -ForegroundColor Gray

try {
    $availabilityResponse = Invoke-RestMethod -Uri "$BASE_URL/doctor/set-availability" -Method Post -Body $availabilityBody -Headers $headers
    Write-Host "`n✅ Availability Set Successfully!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor White
    Write-Host ($availabilityResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
}
catch {
    Write-Host "`n❌ Availability failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Test with invalid data (missing from field)
Write-Host "`n📝 Step 4: Test Invalid Data (Missing from field)" -ForegroundColor Cyan
Write-Host "This should fail with validation error" -ForegroundColor Yellow

$invalidBody1 = @{
    to = "2025-06-29T17:00:00.000Z"
} | ConvertTo-Json

Write-Host "`nRequest Body:" -ForegroundColor White
Write-Host $invalidBody1 -ForegroundColor Gray

try {
    $invalidResponse1 = Invoke-RestMethod -Uri "$BASE_URL/doctor/set-availability" -Method Post -Body $invalidBody1 -Headers $headers
    Write-Host "`n⚠️ Unexpected success (should have failed)" -ForegroundColor Yellow
}
catch {
    Write-Host "`n✅ Expected validation error:" -ForegroundColor Green
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# Step 5: Test with invalid date format
Write-Host "`n📝 Step 5: Test Invalid Date Format" -ForegroundColor Cyan
Write-Host "This should fail with ISO 8601 format error" -ForegroundColor Yellow

$invalidBody2 = @{
    from = "2025-06-29 09:00:00"
    to = "2025-06-29 17:00:00"
} | ConvertTo-Json

Write-Host "`nRequest Body:" -ForegroundColor White
Write-Host $invalidBody2 -ForegroundColor Gray

try {
    $invalidResponse2 = Invoke-RestMethod -Uri "$BASE_URL/doctor/set-availability" -Method Post -Body $invalidBody2 -Headers $headers
    Write-Host "`n⚠️ Unexpected success (should have failed)" -ForegroundColor Yellow
}
catch {
    Write-Host "`n✅ Expected validation error:" -ForegroundColor Green
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n🎉 Test Suite Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
