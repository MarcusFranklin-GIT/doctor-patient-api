$BASE_URL = "http://localhost:3000"

Write-Host "Patient API - Complete Test Suite" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Yellow

# Step 1: Create patient account (if needed)
Write-Host "`nStep 1: Patient Sign Up (if needed)" -ForegroundColor Cyan

$patientSignupBody = @{
    email = "patient.john@example.com"
    password = "Patient@123"
    name = "John Doe"
    age = 35
    gender = "Male"
} | ConvertTo-Json

try {
    $signupResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/patient/signup" -Method Post -Body $patientSignupBody -ContentType "application/json"
    Write-Host "Patient signup successful" -ForegroundColor Green
    Write-Host ($signupResponse | ConvertTo-Json) -ForegroundColor Cyan
}
catch {
    Write-Host "Patient signup failed (may already exist): $($_.Exception.Message)" -ForegroundColor Yellow
}

# Step 2: Sign in as patient
Write-Host "`nStep 2: Patient Sign In" -ForegroundColor Cyan

$patientSigninBody = @{
    email = "patient.john@example.com"
    password = "Patient@123"
} | ConvertTo-Json

try {
    $signinResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/patient/signin" -Method Post -Body $patientSigninBody -ContentType "application/json"
    $patientToken = $signinResponse.access_token
    
    Write-Host "Patient signin successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor White
    Write-Host ($signinResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
}
catch {
    Write-Host "Patient signin failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 3: Test Get All Doctors
Write-Host "`nStep 3: Get All Doctors" -ForegroundColor Cyan
Write-Host "Endpoint: GET $BASE_URL/patient/all-doctors" -ForegroundColor Gray

$patientHeaders = @{
    "Authorization" = "Bearer $patientToken"
    "Content-Type" = "application/json"
}

try {
    $doctorsResponse = Invoke-RestMethod -Uri "$BASE_URL/patient/all-doctors" -Method Get -Headers $patientHeaders
    Write-Host "Get all doctors successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor White
    Write-Host ($doctorsResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
    
    # Get first doctor ID for next test
    if ($doctorsResponse -and $doctorsResponse.Length -gt 0) {
        $firstDoctorId = $doctorsResponse[0]._id
        Write-Host "`nFirst Doctor ID: $firstDoctorId" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Get all doctors failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorContent = $reader.ReadToEnd()
        Write-Host "Error details: $errorContent" -ForegroundColor Red
    }
}

# Step 4: Test Get Doctor Slots (if we have a doctor ID)
if ($firstDoctorId) {
    Write-Host "`nStep 4: Get Doctor Slots" -ForegroundColor Cyan
    Write-Host "Endpoint: GET $BASE_URL/patient/all-doctors/$firstDoctorId/slots" -ForegroundColor Gray

    try {
        $slotsResponse = Invoke-RestMethod -Uri "$BASE_URL/patient/all-doctors/$firstDoctorId/slots" -Method Get -Headers $patientHeaders
        Write-Host "Get doctor slots successful!" -ForegroundColor Green
        Write-Host "Response:" -ForegroundColor White
        Write-Host ($slotsResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
        
        # Get first slot ID for booking test
        if ($slotsResponse -and $slotsResponse.Length -gt 0) {
            $firstSlotId = $slotsResponse[0]._id
            Write-Host "`nFirst Available Slot ID: $firstSlotId" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Get doctor slots failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorContent = $reader.ReadToEnd()
            Write-Host "Error details: $errorContent" -ForegroundColor Red
        }
    }
}

# Step 5: Test Book Appointment (if we have a slot ID)
if ($firstSlotId) {
    Write-Host "`nStep 5: Book Appointment" -ForegroundColor Cyan
    Write-Host "Endpoint: POST $BASE_URL/patient/book-appointment/$firstSlotId" -ForegroundColor Gray

    try {
        $bookingResponse = Invoke-RestMethod -Uri "$BASE_URL/patient/book-appointment/$firstSlotId" -Method Post -Headers $patientHeaders
        Write-Host "Book appointment successful!" -ForegroundColor Green
        Write-Host "Response:" -ForegroundColor White
        Write-Host ($bookingResponse | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
    }
    catch {
        Write-Host "Book appointment failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorContent = $reader.ReadToEnd()
            Write-Host "Error details: $errorContent" -ForegroundColor Red
        }
    }
}

Write-Host "`nTest Suite Complete!" -ForegroundColor Green
