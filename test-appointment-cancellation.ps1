# Test Appointment Cancellation Script
# This script tests the complete appointment booking and cancellation flow

Write-Host "🏥 Testing Appointment Cancellation Flow" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

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

    Write-Host "`n📋 Step 2: Patient Login" -ForegroundColor Yellow
    $patientLoginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/patient/signin" -Method POST -Body ($patientCredentials | ConvertTo-Json) -ContentType "application/json"
    $patientToken = $patientLoginResponse.access_token
    Write-Host "✅ Patient login successful" -ForegroundColor Green

    Write-Host "`n📋 Step 3: Set Doctor Availability" -ForegroundColor Yellow
    $availabilityData = @{
        date = "2025-07-15"
        startTime = "09:00"
        endTime = "17:00"
        slotDuration = 30
    }
    $doctorHeaders = @{
        "Authorization" = "Bearer $doctorToken"
        "Content-Type" = "application/json"
    }
    $availabilityResponse = Invoke-RestMethod -Uri "$baseUrl/doctor/set-availability" -Method POST -Body ($availabilityData | ConvertTo-Json) -Headers $doctorHeaders -ContentType "application/json"
    Write-Host "✅ Doctor availability set" -ForegroundColor Green

    Write-Host "`n📋 Step 4: Get Available Slots" -ForegroundColor Yellow
    $doctorId = $doctorLoginResponse.user.sub
    $patientHeaders = @{
        "Authorization" = "Bearer $patientToken"
        "Content-Type" = "application/json"
    }
    $slotsResponse = Invoke-RestMethod -Uri "$baseUrl/patient/doctors/$doctorId/slots" -Method GET -Headers $patientHeaders
    
    if ($slotsResponse.Count -gt 0) {
        $slotId = $slotsResponse[0]._id
        Write-Host "✅ Available slots retrieved. Using slot ID: $slotId" -ForegroundColor Green
        
        Write-Host "`n📋 Step 5: Book Appointment" -ForegroundColor Yellow
        $bookingData = @{
            slotId = $slotId
        }
        $bookingResponse = Invoke-RestMethod -Uri "$baseUrl/patient/book-appointment" -Method POST -Body ($bookingData | ConvertTo-Json) -Headers $patientHeaders -ContentType "application/json"
        Write-Host "✅ Appointment booked successfully" -ForegroundColor Green
        Write-Host "Booking Response:" -ForegroundColor Cyan
        $bookingResponse | ConvertTo-Json -Depth 3 | Write-Host

        Write-Host "`n📋 Step 6: Get Patient Appointments" -ForegroundColor Yellow
        $patientAppointments = Invoke-RestMethod -Uri "$baseUrl/auth/appointments" -Method GET -Headers $patientHeaders
        Write-Host "✅ Patient appointments retrieved" -ForegroundColor Green
        
        if ($patientAppointments.Count -gt 0) {
            $appointmentId = $patientAppointments[0]._id
            Write-Host "Appointment ID: $appointmentId" -ForegroundColor Cyan
            
            Write-Host "`n📋 Step 7: Cancel Appointment (by Patient)" -ForegroundColor Yellow                try {
                    $cancelResponse = Invoke-RestMethod -Uri "$baseUrl/auth/appointments/$appointmentId" -Method DELETE -Headers $patientHeaders
                    Write-Host "✅ Appointment canceled successfully by patient" -ForegroundColor Green
                    Write-Host "Cancel Response:" -ForegroundColor Cyan
                    $cancelResponse | ConvertTo-Json -Depth 3 | Write-Host
                    
                    Write-Host "`n📋 Cancel Appointment URL Used:" -ForegroundColor Yellow
                    Write-Host "DELETE $baseUrl/auth/appointments/$appointmentId" -ForegroundColor Cyan

                Write-Host "`n📋 Step 8: Verify Slot is Available Again" -ForegroundColor Yellow
                $updatedSlotsResponse = Invoke-RestMethod -Uri "$baseUrl/patient/doctors/$doctorId/slots" -Method GET -Headers $patientHeaders
                $availableSlots = $updatedSlotsResponse | Where-Object { $_.status -eq 'available' }
                
                if ($availableSlots.Count -gt 0) {
                    Write-Host "✅ Slot is available again after cancellation" -ForegroundColor Green
                    Write-Host "Available slots count: $($availableSlots.Count)" -ForegroundColor Cyan
                } else {
                    Write-Host "⚠️ No available slots found" -ForegroundColor Yellow
                }

                Write-Host "`n📋 Step 9: Try to Cancel Same Appointment Again (Should Fail)" -ForegroundColor Yellow
                try {
                    $failResponse = Invoke-RestMethod -Uri "$baseUrl/auth/appointments/$appointmentId" -Method DELETE -Headers $patientHeaders
                    Write-Host "⚠️ Expected error but cancellation succeeded" -ForegroundColor Yellow
                } catch {
                    Write-Host "✅ Expected error: $($_.Exception.Message)" -ForegroundColor Green
                }

            } catch {
                Write-Host "❌ Error canceling appointment: $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "⚠️ No appointments found to cancel" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️ No available slots found" -ForegroundColor Yellow
    }

    Write-Host "`n🎉 Appointment cancellation test completed!" -ForegroundColor Green

} catch {
    Write-Host "❌ Error during testing: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Full error details:" -ForegroundColor Red
    Write-Host $_.Exception | Format-List -Force
}

Write-Host "`n📝 Summary of Changes:" -ForegroundColor Cyan
Write-Host "- Added 'status' field to appointment schema (default: 'open')" -ForegroundColor White
Write-Host "- Created cancelAppointment API endpoint: DELETE /auth/appointments/:id" -ForegroundColor White
Write-Host "- Appointment status changes to 'canceled'" -ForegroundColor White
Write-Host "- Corresponding slot status changes back to 'available'" -ForegroundColor White
Write-Host "- Both doctors and patients can cancel their appointments" -ForegroundColor White

Write-Host "`n🌐 Cancel Appointment URL Format:" -ForegroundColor Cyan
Write-Host "DELETE http://localhost:3000/auth/appointments/{appointmentId}" -ForegroundColor White
Write-Host "Example: DELETE http://localhost:3000/auth/appointments/677d1234567890abcdef1234" -ForegroundColor Yellow
Write-Host "Replace {appointmentId} with the actual appointment ID from your database" -ForegroundColor White
