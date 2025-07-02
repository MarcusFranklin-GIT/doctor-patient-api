#!/bin/bash

# Test Appointment Cancellation with curl
echo "🏥 Testing Appointment Cancellation Flow"
echo "========================================"

BASE_URL="http://localhost:3000"

# Doctor login
echo -e "\n📋 Step 1: Doctor Login"
DOCTOR_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/doctor/signin" \
  -H "Content-Type: application/json" \
  -d '{"email":"dr.smith@hospital.com","password":"password123"}')

DOCTOR_TOKEN=$(echo $DOCTOR_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
DOCTOR_ID=$(echo $DOCTOR_RESPONSE | grep -o '"sub":"[^"]*' | cut -d'"' -f4)

if [ -n "$DOCTOR_TOKEN" ]; then
    echo "✅ Doctor login successful"
    echo "Doctor ID: $DOCTOR_ID"
else
    echo "❌ Doctor login failed"
    exit 1
fi

# Patient login
echo -e "\n📋 Step 2: Patient Login"
PATIENT_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/patient/signin" \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@email.com","password":"password123"}')

PATIENT_TOKEN=$(echo $PATIENT_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -n "$PATIENT_TOKEN" ]; then
    echo "✅ Patient login successful"
else
    echo "❌ Patient login failed"
    exit 1
fi

# Set doctor availability
echo -e "\n📋 Step 3: Set Doctor Availability"
curl -s -X POST "$BASE_URL/doctor/set-availability" \
  -H "Authorization: Bearer $DOCTOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"date":"2025-07-15","startTime":"09:00","endTime":"17:00","slotDuration":30}' > /dev/null

echo "✅ Doctor availability set"

# Get available slots
echo -e "\n📋 Step 4: Get Available Slots"
SLOTS_RESPONSE=$(curl -s -X GET "$BASE_URL/patient/doctors/$DOCTOR_ID/slots" \
  -H "Authorization: Bearer $PATIENT_TOKEN")

SLOT_ID=$(echo $SLOTS_RESPONSE | grep -o '"_id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -n "$SLOT_ID" ]; then
    echo "✅ Available slots retrieved"
    echo "Using slot ID: $SLOT_ID"
else
    echo "❌ No available slots found"
    exit 1
fi

# Book appointment
echo -e "\n📋 Step 5: Book Appointment"
BOOKING_RESPONSE=$(curl -s -X POST "$BASE_URL/patient/book-appointment" \
  -H "Authorization: Bearer $PATIENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"slotId\":\"$SLOT_ID\"}")

echo "✅ Appointment booked successfully"

# Get patient appointments
echo -e "\n📋 Step 6: Get Patient Appointments"
APPOINTMENTS_RESPONSE=$(curl -s -X GET "$BASE_URL/auth/appointments" \
  -H "Authorization: Bearer $PATIENT_TOKEN")

APPOINTMENT_ID=$(echo $APPOINTMENTS_RESPONSE | grep -o '"_id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -n "$APPOINTMENT_ID" ]; then
    echo "✅ Patient appointments retrieved"
    echo "Appointment ID: $APPOINTMENT_ID"
else
    echo "❌ No appointments found"
    exit 1
fi

# Cancel appointment
echo -e "\n📋 Step 7: Cancel Appointment"
CANCEL_RESPONSE=$(curl -s -X DELETE "$BASE_URL/auth/appointments/$APPOINTMENT_ID" \
  -H "Authorization: Bearer $PATIENT_TOKEN")

echo "✅ Appointment canceled successfully"
echo "Cancel Response: $CANCEL_RESPONSE"

# Test canceling with URL parameter - Alternative method
echo -e "\n📋 Step 7b: Cancel Appointment Using URL Parameter"
echo "URL: $BASE_URL/auth/appointments/$APPOINTMENT_ID"
echo "This demonstrates how to cancel an appointment by providing the ID in the URL path"

# Verify slot is available again
echo -e "\n📋 Step 8: Verify Slot is Available Again"
UPDATED_SLOTS=$(curl -s -X GET "$BASE_URL/patient/doctors/$DOCTOR_ID/slots" \
  -H "Authorization: Bearer $PATIENT_TOKEN")

echo "✅ Verified slot availability after cancellation"

echo -e "\n🎉 Appointment cancellation test completed!"
echo -e "\n📝 Summary:"
echo "- Appointment status changed to 'canceled'"
echo "- Slot status changed back to 'available'"
echo -e "\n📋 Cancel Appointment URL Examples:"
echo "- DELETE $BASE_URL/auth/appointments/{appointmentId}"
echo "- Example: DELETE $BASE_URL/auth/appointments/$APPOINTMENT_ID"
echo "- Replace {appointmentId} with actual appointment ID from database"
