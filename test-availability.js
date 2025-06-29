/**
 * Test script for Doctor Availability API
 * Run this after starting the server to test the availability endpoint
 */

const axios = require('axios');
const fs = require('fs');

// Load test data
const testData = JSON.parse(fs.readFileSync('./test-data.json', 'utf8'));

const BASE_URL = 'http://localhost:3000';
let authToken = '';

async function testAvailability() {
    try {
        console.log('🔐 Step 1: Doctor Sign In...');
        
        // First, sign in to get the token
        const signinResponse = await axios.post(`${BASE_URL}/auth/doctor/signin`, testData.doctor.signin);
        
        console.log('✅ Sign in successful');
        console.log('Token:', signinResponse.data.access_token);
        
        authToken = signinResponse.data.access_token;
        
        console.log('\n📅 Step 2: Testing Valid Availability...');
        
        // Test valid availability
        const availabilityResponse = await axios.post(
            `${BASE_URL}/doctor/set-availability`,
            testData.doctor.availability.valid,
            {
                headers: {
                    'Authorization': `Bearer ${authToken}`,
                    'Content-Type': 'application/json'
                }
            }
        );
        
        console.log('✅ Availability set successfully:');
        console.log(JSON.stringify(availabilityResponse.data, null, 2));
        
        console.log('\n❌ Step 3: Testing Invalid Availability (missing from)...');
        
        // Test invalid availability - missing from
        try {
            await axios.post(
                `${BASE_URL}/doctor/set-availability`,
                testData.doctor.availability.invalid.missing_from,
                {
                    headers: {
                        'Authorization': `Bearer ${authToken}`,
                        'Content-Type': 'application/json'
                    }
                }
            );
        } catch (error) {
            console.log('Expected error for missing from field:');
            console.log(JSON.stringify(error.response.data, null, 2));
        }
        
        console.log('\n❌ Step 4: Testing Invalid Date Format...');
        
        // Test invalid date format
        try {
            await axios.post(
                `${BASE_URL}/doctor/set-availability`,
                testData.doctor.availability.invalid.invalid_date_format,
                {
                    headers: {
                        'Authorization': `Bearer ${authToken}`,
                        'Content-Type': 'application/json'
                    }
                }
            );
        } catch (error) {
            console.log('Expected error for invalid date format:');
            console.log(JSON.stringify(error.response.data, null, 2));
        }
        
        console.log('\n✅ All tests completed!');
        
    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
    }
}

// Run the test if this file is executed directly
if (require.main === module) {
    testAvailability();
}

module.exports = { testAvailability };
