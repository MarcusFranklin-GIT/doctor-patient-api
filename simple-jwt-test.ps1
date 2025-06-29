#!/usr/bin/env pwsh

# Simple JWT debug script

$BASE_URL = "http://localhost:3000"

Write-Host "🔐 JWT Debug Test" -ForegroundColor Yellow

# Step 1: Sign in
Write-Host "`n1. Signing in..." -ForegroundColor Cyan
$signinBody = @{
    email = "doctor.smith@hospital.com"
    password = "Doctor@123"
} | ConvertTo-Json

try {
    $signinResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/doctor/signin" -Method Post -Body $signinBody -ContentType "application/json"
    $token = $signinResponse.access_token
    Write-Host "✅ Got token: $($token.Substring(0, 50))..." -ForegroundColor Green
    
    Write-Host "`nFull signin response:" -ForegroundColor Cyan
    Write-Host ($signinResponse | ConvertTo-Json -Depth 3) -ForegroundColor White
}
catch {
    Write-Host "❌ Sign in failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Test debug endpoint
Write-Host "`n2. Testing debug endpoint..." -ForegroundColor Cyan
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $debugResponse = Invoke-RestMethod -Uri "$BASE_URL/doctor/debug-token" -Method Get -Headers $headers
    Write-Host "✅ Debug response:" -ForegroundColor Green
    Write-Host ($debugResponse | ConvertTo-Json -Depth 3) -ForegroundColor White
}
catch {
    Write-Host "❌ Debug failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorContent = $reader.ReadToEnd()
        Write-Host "Error: $errorContent" -ForegroundColor Red
    }
}

# Step 3: Test availability
Write-Host "`n3. Testing set availability..." -ForegroundColor Cyan
$availabilityBody = @{
    from = "2025-06-29T09:00:00.000Z"
    to = "2025-06-29T17:00:00.000Z"
} | ConvertTo-Json

try {
    $availabilityResponse = Invoke-RestMethod -Uri "$BASE_URL/doctor/set-availability" -Method Post -Body $availabilityBody -Headers $headers
    Write-Host "✅ Availability set:" -ForegroundColor Green
    Write-Host ($availabilityResponse | ConvertTo-Json -Depth 3) -ForegroundColor White
}
catch {
    Write-Host "❌ Availability failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorContent = $reader.ReadToEnd()
        Write-Host "Error: $errorContent" -ForegroundColor Red
    }
}
