/**
 * JWT Token Decoder - Shows what's inside your JWT token
 * Run this script to decode a JWT token and see its contents
 */

function decodeJWT(token) {
    try {
        // JWT has 3 parts separated by dots: header.payload.signature
        const parts = token.split('.');
        
        if (parts.length !== 3) {
            throw new Error('Invalid JWT format');
        }
        
        // Decode header (first part)
        const header = JSON.parse(atob(parts[0].replace(/-/g, '+').replace(/_/g, '/')));
        
        // Decode payload (second part)
        const payload = JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));
        
        return {
            header,
            payload,
            isValid: true
        };
    } catch (error) {
        return {
            error: error.message,
            isValid: false
        };
    }
}

// Example usage - replace with your actual token
const exampleUsage = `
// How to use this:
// 1. Get your JWT token from the signin response
// 2. Replace 'YOUR_TOKEN_HERE' with your actual token
// 3. Run: node jwt-decoder.js

const token = "YOUR_TOKEN_HERE";
const decoded = decodeJWT(token);
console.log('JWT Contents:', JSON.stringify(decoded, null, 2));
`;

// If running this file directly
if (require.main === module) {
    console.log('JWT Token Decoder');
    console.log('=================');
    
    // Check if token was passed as command line argument
    const token = process.argv[2];
    
    if (!token) {
        console.log('Usage: node jwt-decoder.js <your-jwt-token>');
        console.log('\nExample:');
        console.log('node jwt-decoder.js eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
        console.log(exampleUsage);
        process.exit(1);
    }
    
    const decoded = decodeJWT(token);
    console.log('JWT Contents:');
    console.log(JSON.stringify(decoded, null, 2));
    
    if (decoded.isValid) {
        console.log('\n🔍 Key Information:');
        console.log('- User ID:', decoded.payload.sub);
        console.log('- Email:', decoded.payload.email);
        console.log('- User Type:', decoded.payload.usertype);
        console.log('- Issued At:', new Date(decoded.payload.iat * 1000).toISOString());
        console.log('- Expires At:', new Date(decoded.payload.exp * 1000).toISOString());
    }
}

module.exports = { decodeJWT };
