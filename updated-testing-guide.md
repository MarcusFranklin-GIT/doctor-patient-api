# Testing Guide - Updated

## Important: The application now properly validates all inputs!

This guide demonstrates how to test the authentication endpoints with properly formatted data.

## Doctor Endpoints

### Signup Doctor - Valid Data
```bash
curl -X POST http://localhost:3000/auth/doctor/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "doctor.smith@hospital.com",
    "password": "Doctor@123",
    "specialization": "Cardiology"
  }'
```

### Signup Doctor - Invalid Password (Should Return Error)
```bash
curl -X POST http://localhost:3000/auth/doctor/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "doctor.smith@hospital.com",
    "password": "weakpass",
    "specialization": "Cardiology"
  }'
```

### Expected Error Response for Invalid Password
```json
{
  "statusCode": 400,
  "message": [
    "password must be at least 8 characters long and include uppercase, lowercase, number, and special character."
  ],
  "error": "Bad Request"
}
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

## How to Test with Postman

1. Create a new request to http://localhost:3000/auth/doctor/signup
2. Set method to POST
3. Set Body to raw JSON
4. Enter valid data for successful test:
```json
{
  "email": "doctor.smith@hospital.com",
  "password": "Doctor@123",
  "specialization": "Cardiology"
}
```

5. Try with invalid password to confirm validation works:
```json
{
  "email": "doctor.smith@hospital.com",
  "password": "weakpass",
  "specialization": "Cardiology"
}
```

The server should reject the weak password and return a 400 Bad Request error with validation details.
