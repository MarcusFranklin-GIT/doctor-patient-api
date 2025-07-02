# Doctor Availability API - Complete Testing Guide

## 🎯 Step-by-Step Testing Data

### Prerequisites
- Server running on `http://localhost:3000`
- Doctor account created (email: `doctor.smith@hospital.com`, password: `Doctor@123`)

---

## 📝 Step 1: Doctor Sign In

### Request
```http
POST http://localhost:3000/auth/doctor/signin
Content-Type: application/json
```

### Request Body
```json
{
  "email": "doctor.smith@hospital.com",
  "password": "Doctor@123"
}
```

### Expected Response (200 OK)
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2ODYwYjk4OGRhODFkNzUwZTVjNmQ2NmUiLCJlbWFpbCI6ImRvY3Rvci5zbWl0aEBob3NwaXRhbC5jb20iLCJ1c2VydHlwZSI6ImRvY3RvciIsImlhdCI6MTc1MTE3MTMzNywiZXhwIjoxNzUxMTc0OTM3fQ.8tCse_nU9B73C6nZn1LcadNX0kV4JJqZ9K907cpNL5Y",
  "usertype": "doctor",
  "message": " doctor Loged-In successfully"
}
```

### Important Notes
- Copy the `access_token` - you'll need it for all subsequent requests
- Token expires after 1 hour (3600 seconds)

---

## 🔍 Step 2: Debug JWT Token (Optional)

### Request
```http
GET http://localhost:3000/doctor/debug-token
Authorization: Bearer <your_access_token_here>
Content-Type: application/json
```

### Expected Response (200 OK)
```json
{
  "message": "JWT Token Debug Info",
  "user": {
    "userId": "6860b988da81d750e5c6d66e",
    "usertype": "doctor",
    "email": "doctor.smith@hospital.com",
    "sub": "6860b988da81d750e5c6d66e"
  },
  "userKeys": ["userId", "usertype", "email", "sub"],
  "usertype": "doctor",
  "sub": "6860b988da81d750e5c6d66e"
}
```

### JWT Token Contents
The JWT token contains these fields:
- `sub`: User ID (MongoDB ObjectId)
- `email`: Doctor's email address
- `usertype`: "doctor" (lowercase!)
- `iat`: Issued at timestamp
- `exp`: Expires at timestamp

---

## ✅ Step 3: Set Doctor Availability (Valid Data)

### Request
```http
POST http://localhost:3000/doctor/set-availability
Authorization: Bearer <your_access_token_here>
Content-Type: application/json
```

### Request Body
```json
{
  "from": "2025-06-29T09:00:00.000Z",
  "to": "2025-06-29T17:00:00.000Z"
}
```

### Expected Response (200 OK)
```json
{
  "message": "Availability slots added successfully",
  "count": 32
}
```

---

## ❌ Step 4: Test Error Cases

### 4.1 Missing Required Field

**Request Body:**
```json
{
  "to": "2025-06-29T17:00:00.000Z"
}
```

**Expected Response (400 Bad Request):**
```json
{
  "message": ["Start time (from) is required"],
  "error": "Validation failed",
  "statusCode": 400,
  "example": {
    "from": "2025-06-29T09:00:00.000Z",
    "to": "2025-06-29T17:00:00.000Z"
  }
}
```

### 4.2 Invalid Date Format

**Request Body:**
```json
{
  "from": "2025-06-29 09:00:00",
  "to": "2025-06-29 17:00:00"
}
```

**Expected Response (400 Bad Request):**
```json
{
  "message": ["Start time (from) must be a valid ISO 8601 date string (e.g., \"2025-06-28T10:00:00Z\")"],
  "error": "Validation failed",
  "statusCode": 400,
  "example": {
    "from": "2025-06-29T09:00:00.000Z",
    "to": "2025-06-29T17:00:00.000Z"
  }
}
```

### 4.3 End Time Before Start Time

**Request Body:**
```json
{
  "from": "2025-06-29T17:00:00.000Z",
  "to": "2025-06-29T09:00:00.000Z"
}
```

**Expected Response (400 Bad Request):**
```json
{
  "message": "End time must be after start time",
  "error": "Bad Request",
  "statusCode": 400
}
```

### 4.4 Missing Authorization Header

**Headers:** (No Authorization header)
```http
Content-Type: application/json
```

**Expected Response (401 Unauthorized):**
```json
{
  "message": "Unauthorized",
  "statusCode": 401
}
```

---

## 🚫 Step 7: Appointment Cancellation

### 7.1 Get Appointments (Doctor/Patient)

#### Request
```http
GET http://localhost:3000/auth/appointments
Authorization: Bearer YOUR_JWT_TOKEN
```

#### Expected Response (200 OK)
```json
[
  {
    "_id": "677d1234567890abcdef1234",
    "doctorId": "6860b988da81d750e5c6d66e",
    "patientId": "6860b988da81d750e5c6d77f",
    "slotId": "677d1234567890abcdef5678",
    "status": "open",
    "__v": 0
  }
]
```

### 7.2 Cancel Appointment

#### Request
```http
DELETE http://localhost:3000/auth/appointments/677d1234567890abcdef1234
Authorization: Bearer YOUR_JWT_TOKEN
```

#### Expected Response (200 OK)
```json
{
  "message": "Appointment canceled successfully",
  "appointmentId": "677d1234567890abcdef1234",
  "canceledBy": "patient"
}
```

### 7.3 Verify Slot Availability After Cancellation

After canceling an appointment, the corresponding slot should become available again.

#### Request
```http
GET http://localhost:3000/patient/doctors/DOCTOR_ID/slots
Authorization: Bearer PATIENT_JWT_TOKEN
```

The previously booked slot should now show `"status": "available"`.

---

## 🔄 Appointment Cancellation Flow

1. **Book an appointment** using the patient booking endpoint
2. **Get appointments** to retrieve the appointment ID
3. **Cancel appointment** using the appointment ID
4. **Verify** the slot is available again
5. **Try to cancel again** (should fail with appropriate error)

### Cancellation Rules
- Both doctors and patients can cancel appointments
- Only appointments with status "open" can be canceled
- Canceled appointments cannot be canceled again
- When an appointment is canceled:
  - Appointment status → "canceled"
  - Corresponding slot status → "available"

---

## 📋 Updated Testing Scripts

### PowerShell Script
```powershell
# Run the complete cancellation test
.\test-appointment-cancellation.ps1
```

### Bash Script
```bash
# Run the complete cancellation test
./test-appointment-cancellation.sh
```

---

## 🔄 Updated Error Scenarios

| Scenario | Expected Status | Expected Response |
|----------|----------------|-------------------|
| Cancel non-existent appointment | 500 Internal Server Error | "Appointment not found" |
| Cancel already canceled appointment | 500 Internal Server Error | "Appointment is already canceled" |
| Cancel without authorization | 401 Unauthorized | Unauthorized message |
| Cancel appointment of another user | 500 Internal Server Error | "You are not authorized to cancel this appointment" |
