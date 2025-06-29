# Postman Testing Guide for Doctor Availability API

## Step-by-Step Instructions

### Step 1: Sign In to Get JWT Token

1. **Create a new POST request**
   - URL: `http://localhost:3000/auth/doctor/signin`
   - Method: `POST`

2. **Set Headers**
   - `Content-Type: application/json`

3. **Set Request Body (raw JSON)**
   ```json
   {
     "email": "doctor.smith@hospital.com",
     "password": "Doctor@123"
   }
   ```

4. **Send the request**
   - You should get a response like:
   ```json
   {
     "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
     "usertype": "doctor",
     "message": " doctor Loged-In successfully"
   }
   ```

5. **Copy the access_token** - You'll need this for the next request

### Step 2: Set Doctor Availability

1. **Create a new POST request**
   - URL: `http://localhost:3000/doctor/set-availability`
   - Method: `POST`

2. **Set Headers**
   - `Content-Type: application/json`
   - `Authorization: Bearer YOUR_TOKEN_HERE` (replace YOUR_TOKEN_HERE with the actual token from Step 1)

3. **Set Request Body (raw JSON)**
   ```json
   {
     "from": "2025-06-29T09:00:00.000Z",
     "to": "2025-06-29T17:00:00.000Z"
   }
   ```
   
   **⚠️ IMPORTANT**: 
   - Make sure you select "raw" body type in Postman
   - Select "JSON" from the dropdown next to "raw"
   - Copy and paste the exact JSON above (including quotes and formatting)

4. **Send the request**
   - You should get a success response like:
   ```json
   {
     "message": "Availability slots added successfully",
     "count": 16
   }
   ```

## Common Postman Setup Issues

### Issue 1: Missing Authorization Header
**Symptom**: Getting validation errors or 401 Unauthorized
**Solution**: 
1. Go to the "Authorization" tab in Postman
2. Select "Bearer Token" from the Type dropdown
3. Paste your JWT token in the Token field
OR
4. Manually add header: `Authorization: Bearer YOUR_TOKEN`

### Issue 2: Wrong Content-Type
**Symptom**: Server doesn't recognize the request body
**Solution**: Set header `Content-Type: application/json`

### Issue 3: Invalid Date Format
**Symptom**: Validation error about ISO 8601 format
**Solution**: Use the exact format: `"2025-06-29T09:00:00.000Z"`

### Issue 4: Token Expired
**Symptom**: 401 Unauthorized even with token
**Solution**: Sign in again to get a fresh token

## Postman Environment Setup (Optional)

To make testing easier, you can set up Postman environment variables:

1. **Create Environment Variables**
   - `base_url`: `http://localhost:3000`
   - `doctor_token`: (empty initially)

2. **Update Sign In Request**
   - URL: `{{base_url}}/auth/doctor/signin`
   - Add to Tests tab:
   ```javascript
   if (pm.response.code === 200) {
       const response = pm.response.json();
       pm.environment.set("doctor_token", response.access_token);
   }
   ```

3. **Update Set Availability Request**
   - URL: `{{base_url}}/doctor/set-availability`
   - Authorization: Bearer Token with `{{doctor_token}}`

## Troubleshooting Checklist

- [ ] Server is running on localhost:3000
- [ ] Doctor account exists (run sign up first if needed)
- [ ] JWT token is copied correctly (no extra spaces)
- [ ] Authorization header is set correctly
- [ ] Content-Type is application/json
- [ ] Request body has both "from" and "to" fields
- [ ] Dates are in ISO 8601 format
- [ ] "to" date is after "from" date
- [ ] Token hasn't expired (tokens typically expire after 1 hour)

## 🚨 Postman Troubleshooting - Common Issues

### Issue: Getting validation errors like in your screenshot

**Problem**: The request body or headers are not set correctly in Postman.

**Step-by-Step Fix:**

1. **Check Authorization Header** (MOST COMMON ISSUE)
   - Go to the "Authorization" tab in Postman
   - Select "Bearer Token" from the Type dropdown
   - Paste your JWT token (without "Bearer " prefix)
   - OR manually add in Headers tab: `Authorization` = `Bearer your_token_here`

2. **Check Request Body Format**
   - Click on "Body" tab
   - Select "raw" radio button
   - From dropdown next to "raw", select "JSON" 
   - Paste this EXACT text:
   ```json
   {
     "from": "2025-06-29T09:00:00.000Z",
     "to": "2025-06-29T17:00:00.000Z"
   }
   ```

3. **Check Headers**
   - Go to "Headers" tab
   - Ensure you have: `Content-Type` = `application/json`
   - Ensure you have: `Authorization` = `Bearer your_jwt_token`

4. **Verify URL**
   - URL should be exactly: `http://localhost:3000/doctor/set-availability`
   - Method should be: `POST`

### Quick Test - Get Fresh Token First

If still not working, get a fresh token:

1. **Sign In Request** (to get new token):
   ```
   POST http://localhost:3000/auth/doctor/signin
   Headers: Content-Type: application/json
   Body (raw JSON):
   {
     "email": "doctor.smith@hospital.com",
     "password": "Doctor@123"
   }
   ```

2. **Copy the access_token from response**

3. **Use that token in availability request**

## Example Working Requests

### Complete Sign In Request
```
POST http://localhost:3000/auth/doctor/signin
Content-Type: application/json

{
  "email": "doctor.smith@hospital.com",
  "password": "Doctor@123"
}
```

### Complete Set Availability Request
```
POST http://localhost:3000/doctor/set-availability
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "from": "2025-06-29T09:00:00.000Z",
  "to": "2025-06-29T17:00:00.000Z"
}
```
