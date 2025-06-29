# Quick Token Generator for Postman
# Run this to get a fresh JWT token to copy into Postman

$BASE_URL = "http://localhost:3000"

Write-Host "🔑 Getting Fresh JWT Token for Postman..." -ForegroundColor Yellow

try {
    $signinBody = @{
        email = "doctor.smith@hospital.com"
        password = "Doctor@123"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$BASE_URL/auth/doctor/signin" -Method Post -Body $signinBody -ContentType "application/json"
    
    Write-Host "`n✅ SUCCESS! Here's your token:" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host $response.access_token -ForegroundColor White
    Write-Host "================================================" -ForegroundColor Yellow
    
    Write-Host "`n📋 Copy the token above and paste it in Postman:" -ForegroundColor Cyan
    Write-Host "1. Go to Authorization tab" -ForegroundColor White
    Write-Host "2. Select 'Bearer Token'" -ForegroundColor White
    Write-Host "3. Paste the token (without 'Bearer ' prefix)" -ForegroundColor White
    
    Write-Host "`n📅 Use this exact body in Postman:" -ForegroundColor Cyan
    Write-Host @"
{
  "from": "2025-06-29T09:00:00.000Z",
  "to": "2025-06-29T17:00:00.000Z"
}
"@ -ForegroundColor Gray

    Write-Host "`n🎯 Token expires in 1 hour" -ForegroundColor Yellow
}
catch {
    Write-Host "`n❌ Error getting token: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure the server is running on localhost:3000" -ForegroundColor Yellow
}
