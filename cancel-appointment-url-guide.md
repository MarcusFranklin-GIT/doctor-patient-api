# Cancel Appointment URL Reference

## 🎯 Cancel Appointment Endpoint

### URL Format
```
DELETE /auth/appointments/:appointmentId
```

### Full URL Examples
```
DELETE http://localhost:3000/auth/appointments/677d1234567890abcdef1234
DELETE http://localhost:3000/auth/appointments/677d5678901234abcdef5678
```

### Required Headers
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

### URL Parameters
- `:appointmentId` - The MongoDB ObjectId of the appointment to cancel

### Example Usage

#### Using curl
```bash
curl -X DELETE "http://localhost:3000/auth/appointments/677d1234567890abcdef1234" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json"
```

#### Using PowerShell
```powershell
$headers = @{
    "Authorization" = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    "Content-Type" = "application/json"
}
Invoke-RestMethod -Uri "http://localhost:3000/auth/appointments/677d1234567890abcdef1234" -Method DELETE -Headers $headers
```

#### Using JavaScript/Fetch
```javascript
fetch('http://localhost:3000/auth/appointments/677d1234567890abcdef1234', {
  method: 'DELETE',
  headers: {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    'Content-Type': 'application/json'
  }
})
```

### Response Format
```json
{
  "message": "Appointment canceled successfully",
  "appointmentId": "677d1234567890abcdef1234",
  "canceledBy": "patient"
}
```

### Error Responses

#### Appointment Not Found
```json
{
  "statusCode": 500,
  "message": "An error occurred while canceling appointment: Appointment not found"
}
```

#### Already Canceled
```json
{
  "statusCode": 500,
  "message": "An error occurred while canceling appointment: Appointment is already canceled"
}
```

#### Unauthorized
```json
{
  "statusCode": 401,
  "message": "Unauthorized"
}
```

#### Not Your Appointment
```json
{
  "statusCode": 500,
  "message": "An error occurred while canceling appointment: You are not authorized to cancel this appointment"
}
```

### How to Get Appointment ID

1. **Get your appointments first:**
   ```
   GET /auth/appointments
   ```

2. **Find the appointment you want to cancel and copy its `_id`:**
   ```json
   [
     {
       "_id": "677d1234567890abcdef1234",  // <-- This is the appointmentId
       "doctorId": "...",
       "patientId": "...",
       "slotId": "...",
       "status": "open"
     }
   ]
   ```

3. **Use that ID in the cancel URL:**
   ```
   DELETE /auth/appointments/677d1234567890abcdef1234
   ```

### Important Notes
- The appointment ID is a MongoDB ObjectId (24 character hex string)
- Only the doctor or patient involved in the appointment can cancel it
- Once canceled, the appointment cannot be canceled again
- When an appointment is canceled, the corresponding slot becomes available for booking again
