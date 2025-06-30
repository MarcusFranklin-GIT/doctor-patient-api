$BASE_URL = "http://localhost:3000"

Write-Host "Patient API - Complete Test Suite" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Yellow

# Step 1: Create Patient Account (if doesn't exist)
Write-Host "`nStep 1: Create Patient Account" -ForegroundColor Cyan
Write-Host "Endpoint: POST $BASE_URL/auth/patient/signup" -ForegroundColor Gray

$patientSignupBody = @{
    email = "patient.john@example.com"
    password = "Patient@123"
    name = "John Doe"
    age = 35
    gender = "Male"
} | ConvertTo-Json

Write-Host "`nRequest Body:" -ForegroundColor White
Write-Host $patientSignupBody -ForegroundColor Gray

try {
    $signupResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/patient/signup" -Method Post -Body $patientSignupBody -ContentType "application/json"
    Write-Host "`nPatient Signup Successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor White
    Write-Host ($signupResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
}
catch {
    Write-Host "`nPatient signup info: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "(This is normal if patient already exists)" -ForegroundColor Gray
}

# Step 2: Patient Sign In
Write-Host "`nStep 2: Patient Sign In" -ForegroundColor Cyan
Write-Host "Endpoint: POST $BASE_URL/auth/patient/signin" -ForegroundColor Gray

$patientSigninBody = @{
    email = "patient.john@example.com"
    password = "Patient@123"
} | ConvertTo-Json

Write-Host "`nRequest Body:" -ForegroundColor White
Write-Host $patientSigninBody -ForegroundColor Gray

try {
    $signinResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/patient/signin" -Method Post -Body $patientSigninBody -ContentType "application/json"
    $patientToken = $signinResponse.access_token
    
    Write-Host "`nPatient Sign In Successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor White
    Write-Host ($signinResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
    
    Write-Host "`nPatient Token (first 50 chars): $($patientToken.Substring(0, 50))..." -ForegroundColor Yellow
}
catch {
    Write-Host "`nPatient sign in failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 3: Test Get All Doctors
Write-Host "`nStep 3: Get All Doctors" -ForegroundColor Cyan
Write-Host "Endpoint: GET $BASE_URL/patient/all-doctors" -ForegroundColor Gray

$patientHeaders = @{
    "Authorization" = "Bearer $patientToken"
    "Content-Type" = "application/json"
}

Write-Host "`nRequest Headers:" -ForegroundColor White
Write-Host "Authorization: Bearer <patient_token>" -ForegroundColor Gray
Write-Host "Content-Type: application/json" -ForegroundColor Gray

try {
    $doctorsResponse = Invoke-RestMethod -Uri "$BASE_URL/patient/all-doctors" -Method Get -Headers $patientHeaders
    Write-Host "`nGet All Doctors Successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor White
    Write-Host ($doctorsResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
    
    Write-Host "`nTotal Doctors Found: $($doctorsResponse.Count)" -ForegroundColor Yellow
}
catch {
    Write-Host "`nGet all doctors failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorContent = $reader.ReadToEnd()
        Write-Host "Error details: $errorContent" -ForegroundColor Yellow
    }
}

# Step 4: Test with Doctor Token (should fail)
Write-Host "`nStep 4: Test Authorization (Doctor token should fail)" -ForegroundColor Cyan
Write-Host "This tests that only patients can access the endpoint" -ForegroundColor Yellow

# First get doctor token
$doctorSigninBody = '{"email":"doctor.smith@hospital.com","password":"Doctor@123"}'
try {
    $doctorSigninResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/doctor/signin" -Method Post -Body $doctorSigninBody -ContentType "application/json"
    $doctorToken = $doctorSigninResponse.access_token
    
    $doctorHeaders = @{
        "Authorization" = "Bearer $doctorToken"
        "Content-Type" = "application/json"
    }
    
    # Try to access patient endpoint with doctor token
    $doctorTestResponse = Invoke-RestMethod -Uri "$BASE_URL/patient/all-doctors" -Method Get -Headers $doctorHeaders
    Write-Host "`nUnexpected: Doctor was able to access patient endpoint" -ForegroundColor Yellow
}
catch {
    Write-Host "`nExpected: Doctor token rejected for patient endpoint" -ForegroundColor Green
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Cyan
}

Write-Host "`nTest Suite Complete!" -ForegroundColor Green
