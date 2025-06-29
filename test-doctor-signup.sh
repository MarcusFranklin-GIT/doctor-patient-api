#!/bin/bash

# Test doctor signup with name field
echo "Testing doctor signup with name field..."
curl -X POST http://localhost:3000/auth/doctor/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "doctor.test@hospital.com",
    "password": "Doctor@123",
    "name": "Dr. Test Doctor",
    "specialization": "Neurology"
  }'

echo -e "\n\n"
sleep 2

# Test doctor signin
echo "Testing doctor signin..."
curl -X POST http://localhost:3000/auth/doctor/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "doctor.test@hospital.com",
    "password": "Doctor@123"
  }'

echo -e "\n\n"
