# Doctor Availability API Documentation

## Fixed Issues

### Problem
The `POST /doctor/set-availability` endpoint was returning validation errors:
```json
{
    "message": [
        "from must be a valid ISO 8601 date string",
        "from should not be empty",
        "to must be a valid ISO 8601 date string",
        "to should not be empty"
    ],
    "error": "Bad Request",
    "statusCode": 400
}
```

### Root Cause
The `AvailabilityDto` was expecting valid ISO 8601 date strings for the `from` and `to` fields, but the request was either missing these fields or providing them in an invalid format. Additionally, there was a mismatch in the JWT payload field name (`usertype` vs `userType`) causing authorization issues.

### Solution
1. **Enhanced Validation Messages**: Updated `AvailabilityDto` with more descriptive error messages
2. **Improved Error Handling**: Enhanced the controller with better validation pipe configuration
3. **Added Business Logic Validation**: Added check to ensure end time is after start time
4. **Fixed Authorization**: Corrected field name mismatch in `RolesGuard` and controller interface
5. **Created Test Data and Scripts**: Added comprehensive test examples

## API Endpoint

### Set Doctor Availability
**POST** `/doctor/set-availability`

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "from": "2025-06-29T09:00:00.000Z",
  "to": "2025-06-29T17:00:00.000Z"
}
```

**Field Requirements:**
- `from`: **Required**. ISO 8601 date string representing the start time
- `to`: **Required**. ISO 8601 date string representing the end time
- The `to` time must be after the `from` time

**Valid Date Format Examples:**
```
"2025-06-29T09:00:00.000Z"     // UTC timezone
"2025-06-29T09:00:00+05:30"    // IST timezone
"2025-06-29T09:00:00-05:00"    // EST timezone
```

**Success Response (200):**
```json
{
  "message": "Availability slots added successfully",
  "count": 16
}
```

**Error Responses:**

**400 - Missing Required Fields:**
```json
{
  "message": ["Start time (from) is required", "End time (to) is required"],
  "error": "Validation failed",
  "statusCode": 400,
  "example": {
    "from": "2025-06-29T09:00:00.000Z",
    "to": "2025-06-29T17:00:00.000Z"
  }
}
```

**400 - Invalid Date Format:**
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

**400 - End Time Before Start Time:**
```json
{
  "message": "End time must be after start time",
  "error": "Bad Request",
  "statusCode": 400
}
```

**401 - Unauthorized:**
```json
{
  "message": "Unauthorized",
  "statusCode": 401
}
```

## Testing

### Using PowerShell Script
```powershell
.\test-availability.ps1
```

### Using Node.js Script
```bash
node test-availability.js
```

### Manual Testing with cURL
```bash
# First, sign in to get token
curl -X POST http://localhost:3000/auth/doctor/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"doctor.smith@hospital.com","password":"Doctor@123"}'

# Then set availability (replace TOKEN with actual token)
curl -X POST http://localhost:3000/doctor/set-availability \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"from":"2025-06-29T09:00:00.000Z","to":"2025-06-29T17:00:00.000Z"}'
```

### Manual Testing with PowerShell
```powershell
# Sign in
$signinBody = @{
    email = "doctor.smith@hospital.com"
    password = "Doctor@123"
} | ConvertTo-Json

$signinResponse = Invoke-RestMethod -Uri "http://localhost:3000/auth/doctor/signin" -Method Post -Body $signinBody -ContentType "application/json"
$token = $signinResponse.access_token

# Set availability
$availabilityBody = @{
    from = "2025-06-29T09:00:00.000Z"
    to = "2025-06-29T17:00:00.000Z"
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri "http://localhost:3000/doctor/set-availability" -Method Post -Body $availabilityBody -Headers $headers
```

## Common Issues and Solutions

### Issue 1: "from must be a valid ISO 8601 date string"
**Problem**: Date format is incorrect
**Solution**: Use ISO 8601 format like `"2025-06-29T09:00:00.000Z"`

### Issue 2: "from should not be empty" 
**Problem**: Missing required field
**Solution**: Include both `from` and `to` fields in request body

### Issue 3: "End time must be after start time"
**Problem**: The `to` time is before or same as `from` time
**Solution**: Ensure `to` is chronologically after `from`

### Issue 4: 401 Unauthorized
**Problem**: Missing or invalid JWT token
**Solution**: Sign in first to get a valid token, then include it in Authorization header

## Tips
1. Always include timezone information in your dates
2. Use UTC timezone (`Z` suffix) for consistency
3. Ensure the doctor is signed in before setting availability
4. Test with the provided scripts to verify your setup
5. Check server logs for detailed error information
