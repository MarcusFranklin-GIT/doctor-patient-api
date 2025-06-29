// This file tests the doctor registration with explicit type checking

// Import axios or use native fetch if running in Node.js environment
const axios = require('axios').default;

// Test data for doctor registration
const testDoctor = {
  email: "doctor.test@example.com",
  password: "Doctor@123",
  name: "Dr. Test Doctor",
  specialization: "Cardiology"
};

// Function to test doctor registration
async function testDoctorRegistration() {
  try {
    console.log("Testing doctor registration with the following data:");
    console.log(JSON.stringify(testDoctor, null, 2));
    
    // Send registration request
    const response = await axios.post('http://localhost:3000/auth/doctor/signup', testDoctor);
    
    console.log("Registration successful!");
    console.log("Response:", response.data);
    
    return { success: true, data: response.data };
  } catch (error) {
    console.error("Registration failed!");
    
    if (error.response) {
      // The request was made and the server responded with a status code
      console.error("Server response:", error.response.data);
      console.error("Status:", error.response.status);
    } else if (error.request) {
      // The request was made but no response was received
      console.error("No response received from server");
    } else {
      // Something happened in setting up the request
      console.error("Error:", error.message);
    }
    
    return { success: false, error: error.response?.data || error.message };
  }
}

// Run the test
testDoctorRegistration()
  .then(result => {
    if (result.success) {
      console.log("Test completed successfully");
    } else {
      console.log("Test failed");
    }
  });
