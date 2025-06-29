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

## 📋 Valid Date Format Examples

### Accepted ISO 8601 Formats
```json
{
  "from": "2025-06-29T09:00:00.000Z",     // UTC timezone
  "to": "2025-06-29T17:00:00.000Z"
}
```

```json
{
  "from": "2025-06-29T09:00:00+05:30",    // IST timezone
  "to": "2025-06-29T17:00:00+05:30"
}
```

```json
{
  "from": "2025-06-29T09:00:00-05:00",    // EST timezone
  "to": "2025-06-29T17:00:00-05:00"
}
```

---

## 🔧 PowerShell Testing Commands

### Complete Test Script
```powershell
# Run the complete test
.\working-test.ps1
```

### Manual Step-by-Step Commands

#### 1. Sign In
```powershell
$signinBody = '{"email":"doctor.smith@hospital.com","password":"Doctor@123"}'
$signinResponse = Invoke-RestMethod -Uri "http://localhost:3000/auth/doctor/signin" -Method Post -Body $signinBody -ContentType "application/json"
$token = $signinResponse.access_token
```

#### 2. Set Headers
```powershell
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}
```

#### 3. Test Availability
```powershell
$availabilityBody = '{"from":"2025-06-29T09:00:00.000Z","to":"2025-06-29T17:00:00.000Z"}'
Invoke-RestMethod -Uri "http://localhost:3000/doctor/set-availability" -Method Post -Body $availabilityBody -Headers $headers
```

---

## 🎯 Expected Behavior Summary

| Test Case | Expected Status | Expected Response |
|-----------|----------------|-------------------|
| Valid signin | 200 OK | JWT token + usertype |
| Valid availability | 200 OK | Success message + slot count |
| Missing field | 400 Bad Request | Validation error |
| Invalid date format | 400 Bad Request | ISO 8601 format error |
| End before start | 400 Bad Request | Time logic error |
| No auth header | 401 Unauthorized | Unauthorized message |
| Invalid token | 401 Unauthorized | Unauthorized message |

---

## ✅ Quick Verification Checklist

- [ ] Server is running on localhost:3000
- [ ] Doctor account exists (run signup first if needed)
- [ ] JWT token is properly formatted in Authorization header
- [ ] Request body uses exact ISO 8601 date format
- [ ] Content-Type header is set to application/json
- [ ] Token hasn't expired (get new one if over 1 hour old)
