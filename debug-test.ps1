$BASE_URL = "http://localhost:3000"

Write-Host "JWT Debug Test" -ForegroundColor Yellow

# Step 1: Sign in
Write-Host "1. Signing in..." -ForegroundColor Cyan
$signinBody = @{
    email = "doctor.smith@hospital.com"
    password = "Doctor@123"
} | ConvertTo-Json

try {
    $signinResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/doctor/signin" -Method Post -Body $signinBody -ContentType "application/json"
    $token = $signinResponse.access_token
    Write-Host "Got token successfully" -ForegroundColor Green
    
    Write-Host "Signin response:" -ForegroundColor Cyan
    Write-Host ($signinResponse | ConvertTo-Json -Depth 3) -ForegroundColor White
}
catch {
    Write-Host "Sign in failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Step 2: Test debug endpoint
Write-Host "2. Testing debug endpoint..." -ForegroundColor Cyan
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $debugResponse = Invoke-RestMethod -Uri "$BASE_URL/doctor/debug-token" -Method Get -Headers $headers
    Write-Host "Debug response:" -ForegroundColor Green
    Write-Host ($debugResponse | ConvertTo-Json -Depth 3) -ForegroundColor White
}
catch {
    Write-Host "Debug failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# Step 3: Test availability
Write-Host "3. Testing set availability..." -ForegroundColor Cyan
$availabilityBody = @{
    from = "2025-06-29T09:00:00.000Z"
    to = "2025-06-29T17:00:00.000Z"
} | ConvertTo-Json

try {
    $availabilityResponse = Invoke-RestMethod -Uri "$BASE_URL/doctor/set-availability" -Method Post -Body $availabilityBody -Headers $headers
    Write-Host "Availability set successfully:" -ForegroundColor Green
    Write-Host ($availabilityResponse | ConvertTo-Json -Depth 3) -ForegroundColor White
}
catch {
    Write-Host "Availability failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
