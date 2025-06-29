# API Testing Guide

This guide demonstrates how to test the authentication endpoints using cURL commands.

## Important Note on Validation

This API uses strict validation. If you encounter the error:
```
[Nest] ERROR [PackageLoader] The "class-transformer" package is missing
```
Install the required packages with:
```bash
npm install class-transformer class-validator --save
```

## Doctor Endpoints

### Signup Doctor
```bash
curl -X POST http://localhost:3000/auth/doctor/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "doctor.smith@hospital.com",
    "password": "Doctor@123",
    "name": "Dr. John Smith",
    "specialization": "Cardiology"
  }'
```

### Signin Doctor
```bash
curl -X POST http://localhost:3000/auth/doctor/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "doctor.smith@hospital.com",
    "password": "Doctor@123"
  }'
```

## Patient Endpoints

### Signup Patient
```bash
curl -X POST http://localhost:3000/auth/patient/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "patient.john@example.com",
    "password": "Patient@123",
    "name": "John Doe",
    "age": 35,
    "gender": "Male"
  }'
```

### Signin Patient
```bash
curl -X POST http://localhost:3000/auth/patient/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "patient.john@example.com",
    "password": "Patient@123"
  }'
```

## Testing Invalid Scenarios

### Invalid Email Format
```bash
curl -X POST http://localhost:3000/auth/doctor/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "doctor.smith",
    "password": "Doctor@123",
    "name": "Invalid Doctor",
    "specialization": "Cardiology"
  }'
```

### Weak Password
```bash
curl -X POST http://localhost:3000/auth/doctor/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "doctor.smith@hospital.com",
    "password": "weakpass",
    "name": "Weak Password Doctor",
    "specialization": "Cardiology"
  }'
```

### Non-existent User
```bash
curl -X POST http://localhost:3000/auth/doctor/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "nonexistent@hospital.com",
    "password": "Test@123"
  }'
```

### Expected Error Responses

When you submit invalid data, you'll get validation errors like:

**Invalid Email:**
```json
{
  "statusCode": 400,
  "message": ["email must be an email"],
  "error": "Bad Request"
}
```

**Weak Password:**
```json
{
  "statusCode": 400,
  "message": [
    "password must be longer than or equal to 8 characters",
    "password must contain at least 1 uppercase letter",
    "password must contain at least 1 lowercase letter", 
    "password must contain at least 1 number",
    "password must contain at least 1 symbol"
  ],
  "error": "Bad Request"
}
```

## Expected Success Responses

### Doctor Signin Response
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usertype": "doctor",
  "message": "doctor Loged-In successfully"
}
```

### Patient Signin Response
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usertype": "patient",
  "message": "Patient logged in successfully"
}
```

## User Type Information

Both doctor and patient schemas include a `usertype` field that is automatically set to "doctor" or "patient" respectively. This field:

1. Is included in login responses 
2. Is part of the JWT payload
3. Can be used for role-based access control in your application

For more details on how to use the usertype field, see the `doc/usertype-integration-guide.md` file.

## Testing with Postman

1. Import the `test-data.json` file into Postman
2. Create a new request collection for your API
3. Set up requests for each endpoint using the data from the JSON file
4. Test different scenarios including valid and invalid data
