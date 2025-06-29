#!/usr/bin/env pwsh

# PowerShell script to test JWT token and debug authorization

param(
    [string]$Token = "",
    [string]$BaseUrl = "http://localhost:3000"
)

function Decode-JWT {
    param([string]$Token)
    
    try {
        $parts = $Token.Split('.')
        if ($parts.Length -ne 3) {
            throw "Invalid JWT format"
        }
        
        # Add padding if needed
        $payload = $parts[1]
        while ($payload.Length % 4) {
            $payload += "="
        }
        
        # Replace URL-safe characters
        $payload = $payload.Replace('-', '+').Replace('_', '/')
        
        # Decode base64
        $bytes = [Convert]::FromBase64String($payload)
        $json = [System.Text.Encoding]::UTF8.GetString($bytes)
        
        return $json | ConvertFrom-Json
    }
    catch {
        Write-Host "❌ Error decoding JWT: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "🔐 JWT Token Debug and Test Script" -ForegroundColor Yellow
Write-Host "===================================" -ForegroundColor Yellow

if (-not $Token) {
    Write-Host "`n🔑 Step 1: Getting JWT Token..." -ForegroundColor Cyan
    
    # Sign in to get token
    $signinBody = @{
        email = "doctor.smith@hospital.com"
        password = "Doctor@123"
    } | ConvertTo-Json
    
    try {
        $signinResponse = Invoke-RestMethod -Uri "$BaseUrl/auth/doctor/signin" -Method Post -Body $signinBody -ContentType "application/json"
        $Token = $signinResponse.access_token
        Write-Host "✅ Token obtained successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to get token: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n🔍 Step 2: Decoding JWT Token..." -ForegroundColor Cyan
Write-Host "Token: $($Token.Substring(0, 50))..." -ForegroundColor Gray

$decoded = Decode-JWT -Token $Token

if ($decoded) {
    Write-Host "✅ JWT Decoded Successfully:" -ForegroundColor Green
    Write-Host ($decoded | ConvertTo-Json -Depth 3) -ForegroundColor White
    
    Write-Host "`n📋 Key Information:" -ForegroundColor Cyan
    Write-Host "- User ID: $($decoded.sub)" -ForegroundColor White
    Write-Host "- Email: $($decoded.email)" -ForegroundColor White
    Write-Host "- User Type: $($decoded.usertype)" -ForegroundColor White
    
    if ($decoded.iat) {
        $issuedAt = [DateTimeOffset]::FromUnixTimeSeconds($decoded.iat).DateTime
        Write-Host "- Issued At: $issuedAt" -ForegroundColor White
    }
    
    if ($decoded.exp) {
        $expiresAt = [DateTimeOffset]::FromUnixTimeSeconds($decoded.exp).DateTime
        Write-Host "- Expires At: $expiresAt" -ForegroundColor White
        
        if ($expiresAt -lt (Get-Date)) {
            Write-Host "⚠️  TOKEN IS EXPIRED!" -ForegroundColor Red
        }
    }
}

Write-Host "`n🧪 Step 3: Testing Debug Endpoint..." -ForegroundColor Cyan

$headers = @{
    "Authorization" = "Bearer $Token"
    "Content-Type" = "application/json"
}

try {
    $debugResponse = Invoke-RestMethod -Uri "$BaseUrl/doctor/debug-token" -Method Get -Headers $headers
    Write-Host "✅ Debug endpoint response:" -ForegroundColor Green
    Write-Host ($debugResponse | ConvertTo-Json -Depth 3) -ForegroundColor White
}
catch {
    Write-Host "❌ Debug endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorContent = $reader.ReadToEnd()
        Write-Host "Error details: $errorContent" -ForegroundColor Red
    }
}

Write-Host "`n🎯 Step 4: Testing Set Availability..." -ForegroundColor Cyan

$availabilityBody = @{
    from = "2025-06-29T09:00:00.000Z"
    to = "2025-06-29T17:00:00.000Z"
} | ConvertTo-Json

try {
    $availabilityResponse = Invoke-RestMethod -Uri "$BaseUrl/doctor/set-availability" -Method Post -Body $availabilityBody -Headers $headers
    Write-Host "✅ Set availability successful:" -ForegroundColor Green
    Write-Host ($availabilityResponse | ConvertTo-Json -Depth 3) -ForegroundColor White
}
catch {
    Write-Host "❌ Set availability failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorContent = $reader.ReadToEnd()
        Write-Host "Error details: $errorContent" -ForegroundColor Red
    }
}

Write-Host "`n✅ Testing Complete!" -ForegroundColor Green
