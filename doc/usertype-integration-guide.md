# User Type Integration Guide

This document explains how the `usertype` field works in the hospital login API.

## Overview

The system includes a `usertype` field to differentiate between doctors and patients. This field is:
- Automatically set during registration
- Included in JWT tokens 
- Returned in login responses
- Used for role-based access control

## Schema Implementation

### Doctor Schema
```typescript
@Prop({required:true})
usertype = 'doctor'; 
```

### Patient Schema
```typescript
@Prop({required:true})
usertype = 'patient';
```

## Authentication Flow

1. **During Registration**:
   - The `usertype` field is automatically set by the schema based on which endpoint is used
   - Do not include this field in the registration request body
   - For doctors, it's set to 'doctor'
   - For patients, it's set to 'patient'

2. **During Login**:
   - The `usertype` is retrieved from the database
   - Included in the JWT payload
   - Returned in the response

3. **For Protected Routes**:
   - Extract `usertype` from JWT token
   - Use for role-based access control

## Sample Responses

### Doctor Login Response
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usertype": "doctor",
  "message": "doctor Loged-In successfully"
}
```

### Patient Login Response
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usertype": "patient",
  "message": "Patient logged in successfully"
}
```

## JWT Payload Structure

```json
{
  "sub": "60d21b4667d0d8992e610c85",  // MongoDB _id
  "email": "doctor@example.com",
  "usertype": "doctor",               // or "patient"
  "iat": 1624303011,
  "exp": 1624306611
}
```

## Using Usertype in Frontend

Extract the usertype from the login response to:
1. Redirect users to appropriate dashboards
2. Show/hide features based on user role
3. Apply different styles or UI elements

## Using Usertype in Backend Guards

Create role-based guards to protect routes:

```typescript
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.get<string[]>('roles', context.getHandler());
    if (!requiredRoles) {
      return true;
    }
    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.includes(user.usertype);
  }
}
```

Usage:
```typescript
@Roles('doctor')
@UseGuards(JwtAuthGuard, RolesGuard)
@Get('appointments')
getDoctorAppointments() {
  // Only accessible to doctors
}
```
