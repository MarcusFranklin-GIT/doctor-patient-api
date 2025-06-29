// Test doctor signup with required name field
const doctorData = {
  email: "doctor.test@hospital.com",
  password: "Doctor@123",
  name: "Dr. Test Doctor",
  specialization: "Neurology"
};

// Function to test doctor signup
async function testDoctorSignup() {
  try {
    console.log("Testing doctor signup with name field...");
    const response = await fetch("http://localhost:3000/auth/doctor/signup", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(doctorData)
    });
    
    const data = await response.json();
    console.log("Response:", data);
    
    if (response.ok) {
      console.log("Doctor signup successful!");
      testDoctorSignin();
    } else {
      console.error("Doctor signup failed:", data);
    }
  } catch (error) {
    console.error("Error testing doctor signup:", error);
  }
}

// Function to test doctor signin
async function testDoctorSignin() {
  try {
    console.log("\nTesting doctor signin...");
    const signinData = {
      email: doctorData.email,
      password: doctorData.password
    };
    
    const response = await fetch("http://localhost:3000/auth/doctor/signin", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(signinData)
    });
    
    const data = await response.json();
    console.log("Response:", data);
    
    if (response.ok) {
      console.log("Doctor signin successful!");
    } else {
      console.error("Doctor signin failed:", data);
    }
  } catch (error) {
    console.error("Error testing doctor signin:", error);
  }
}

// Run the test
testDoctorSignup();
