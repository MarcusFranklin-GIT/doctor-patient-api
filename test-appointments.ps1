# Test Appointments Endpoint Script
# This script tests the /auth/appointments endpoint for both doctors and patients

Write-Host "🏥 Testing Appointments Endpoint" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

$baseUrl = "http://localhost:3000"

# Test data
$doctorCredentials = @{
    email = "dr.smith@hospital.com"
    password = "password123"
}

$patientCredentials = @{
    email = "john.doe@email.com"
    password = "password123"
}

try {
    Write-Host "`n📋 Step 1: Doctor Login" -ForegroundColor Yellow
    $doctorLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/doctor/signin" -Method POST -Body ($doctorCredentials | ConvertTo-Json) -ContentType "application/json"
    $doctorToken = $doctorLoginResponse.access_token
    Write-Host "✅ Doctor login successful" -ForegroundColor Green
    Write-Host "Doctor Token: $($doctorToken.Substring(0, 50))..." -ForegroundColor Cyan

    Write-Host "`n📋 Step 2: Patient Login" -ForegroundColor Yellow
    $patientLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/patient/signin" -Method POST -Body ($patientCredentials | ConvertTo-Json) -ContentType "application/json"
    $patientToken = $patientLoginResponse.access_token
    Write-Host "✅ Patient login successful" -ForegroundColor Green
    Write-Host "Patient Token: $($patientToken.Substring(0, 50))..." -ForegroundColor Cyan

    Write-Host "`n📋 Step 3: Get Doctor Appointments" -ForegroundColor Yellow
    try {
        $doctorHeaders = @{
            "Authorization" = "Bearer $doctorToken"
            "Content-Type" = "application/json"
        }
        $doctorAppointments = Invoke-RestMethod -Uri "$baseUrl/auth/appointments" -Method GET -Headers $doctorHeaders
        Write-Host "✅ Doctor appointments retrieved successfully" -ForegroundColor Green
        Write-Host "Doctor Appointments:" -ForegroundColor Cyan
        $doctorAppointments | ConvertTo-Json -Depth 3 | Write-Host
    } catch {
        Write-Host "⚠️ No appointments found for doctor or error: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    Write-Host "`n📋 Step 4: Get Patient Appointments" -ForegroundColor Yellow
    try {
        $patientHeaders = @{
            "Authorization" = "Bearer $patientToken"
            "Content-Type" = "application/json"
        }
        $patientAppointments = Invoke-RestMethod -Uri "$baseUrl/auth/appointments" -Method GET -Headers $patientHeaders
        Write-Host "✅ Patient appointments retrieved successfully" -ForegroundColor Green
        Write-Host "Patient Appointments:" -ForegroundColor Cyan
        $patientAppointments | ConvertTo-Json -Depth 3 | Write-Host
    } catch {
        Write-Host "⚠️ No appointments found for patient or error: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    Write-Host "`n🎉 Appointments endpoint test completed!" -ForegroundColor Green

} catch {
    Write-Host "❌ Error during testing: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Full error details:" -ForegroundColor Red
    Write-Host $_.Exception | Format-List -Force
}

Write-Host "`n📝 Note: If no appointments are found, make sure to book some appointments first using the patient booking endpoint." -ForegroundColor Yellow
