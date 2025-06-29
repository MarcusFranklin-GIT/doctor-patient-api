$BASE_URL = "http://localhost:3000"

Write-Host "Doctor Availability API - Complete Test Suite" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Yellow

# Step 1: Sign in
Write-Host "`nStep 1: Doctor Sign In" -ForegroundColor Cyan
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
    
    Write-Host "`nSign In Successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor White
    Write-Host ($signinResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
}
catch {
    Write-Host "`nSign in failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Debug JWT Token
Write-Host "`nStep 2: Debug JWT Token Contents" -ForegroundColor Cyan
Write-Host "Endpoint: GET $BASE_URL/doctor/debug-token" -ForegroundColor Gray

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $debugResponse = Invoke-RestMethod -Uri "$BASE_URL/doctor/debug-token" -Method Get -Headers $headers
    Write-Host "`nDebug Successful!" -ForegroundColor Green
    Write-Host "JWT Token Contents:" -ForegroundColor White
    Write-Host ($debugResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
}
catch {
    Write-Host "`nDebug failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Set Availability - Valid Data
Write-Host "`nStep 3: Set Doctor Availability (Valid Data)" -ForegroundColor Cyan
Write-Host "Endpoint: POST $BASE_URL/doctor/set-availability" -ForegroundColor Gray

$availabilityBody = @{
    from = "2025-06-29T09:00:00.000Z"
    to = "2025-06-29T17:00:00.000Z"
} | ConvertTo-Json

Write-Host "`nRequest Body:" -ForegroundColor White
Write-Host $availabilityBody -ForegroundColor Gray

try {
    $availabilityResponse = Invoke-RestMethod -Uri "$BASE_URL/doctor/set-availability" -Method Post -Body $availabilityBody -Headers $headers
    Write-Host "`nAvailability Set Successfully!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor White
    Write-Host ($availabilityResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
}
catch {
    Write-Host "`nAvailability failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTest Suite Complete!" -ForegroundColor Green
