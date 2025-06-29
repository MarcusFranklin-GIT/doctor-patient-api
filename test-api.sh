#!/bin/bash

# Doctor Availability API - cURL Testing Commands
# Run these commands in sequence to test the API

echo "🔐 Doctor Availability API - cURL Test Suite"
echo "=============================================="

BASE_URL="http://localhost:3000"

echo ""
echo "📝 Step 1: Doctor Sign In"
echo "=========================="

# Sign in and extract token
SIGNIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/doctor/signin" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "doctor.smith@hospital.com",
    "password": "Doctor@123"
  }')

echo "Response:"
echo "$SIGNIN_RESPONSE" | jq '.'

# Extract token (requires jq)
TOKEN=$(echo "$SIGNIN_RESPONSE" | jq -r '.access_token')

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
    echo "❌ Failed to get token. Please check the sign-in response."
    exit 1
fi

echo ""
echo "✅ Token obtained: ${TOKEN:0:50}..."

echo ""
echo "📝 Step 2: Debug JWT Token"
echo "=========================="

curl -s -X GET "$BASE_URL/doctor/debug-token" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.'

echo ""
echo "📝 Step 3: Set Availability (Valid Data)"
echo "========================================"

curl -s -X POST "$BASE_URL/doctor/set-availability" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "from": "2025-06-29T09:00:00.000Z",
    "to": "2025-06-29T17:00:00.000Z"
  }' | jq '.'

echo ""
echo "📝 Step 4: Test Error Cases"
echo "==========================="

echo ""
echo "4.1 Missing Field Test:"
curl -s -X POST "$BASE_URL/doctor/set-availability" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "2025-06-29T17:00:00.000Z"
  }' | jq '.'

echo ""
echo "4.2 Invalid Date Format Test:"
curl -s -X POST "$BASE_URL/doctor/set-availability" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "from": "2025-06-29 09:00:00",
    "to": "2025-06-29 17:00:00"
  }' | jq '.'

echo ""
echo "4.3 No Authorization Test:"
curl -s -X POST "$BASE_URL/doctor/set-availability" \
  -H "Content-Type: application/json" \
  -d '{
    "from": "2025-06-29T09:00:00.000Z",
    "to": "2025-06-29T17:00:00.000Z"
  }' | jq '.'

echo ""
echo "🎉 Test Suite Complete!"
