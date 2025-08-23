# FCM Integration for Invoice App

This document describes the Firebase Cloud Messaging (FCM) integration that has been added to the invoice app.

## Overview

The app now includes FCM token generation and sends it with OTP verification requests to enable push notifications.

## Changes Made

### 1. Dependencies Added
- `firebase_core: ^2.24.2`
- `firebase_messaging: ^14.7.10`

### 2. New Files Created
- `lib/services/fcm_service.dart` - FCM service for token management

### 3. Modified Files
- `lib/main.dart` - Added Firebase initialization
- `lib/services/api_service.dart` - Updated sendOTP and verifyOTP to include FCM token
- `pubspec.yaml` - Added Firebase dependencies

## FCM Service Features

### Token Generation
- Automatically initializes Firebase when needed
- Requests notification permissions
- Generates and caches FCM tokens
- Handles token refresh automatically

### Fallback Support
- If Firebase is not available, generates a mock token for testing
- Ensures API calls always include a token parameter

## API Integration

### Send OTP
- **Endpoint**: `POST /api/send-otp`
- **Body**: Includes `fcm_token` field
- **Purpose**: Associates FCM token with phone number for future notifications

### Verify OTP
- **Endpoint**: `POST /api/verify-otp?phone={phone}&otp={otp}&fcm_token={token}`
- **Query Parameters**: 
  - `phone`: Phone number (without +91 prefix)
  - `otp`: 4-digit OTP code
  - `fcm_token`: FCM token for push notifications
- **Purpose**: Verifies OTP and associates FCM token with user account

## Usage Example

```dart
// The FCM token is automatically included in API calls
final result = await ApiService.verifyOTP('7223903303', '1234');
// This will call: /api/verify-otp?phone=7223903303&otp=1234&fcm_token=actual_fcm_token_here
```

## Debug Logging

The integration includes comprehensive debug logging:
- FCM token generation and refresh
- API request URLs with FCM tokens
- Error handling for Firebase initialization

## Testing

- **With Firebase**: Real FCM tokens will be generated and sent
- **Without Firebase**: Mock tokens will be generated for testing purposes
- **Development**: Mock tokens ensure API testing works even without Firebase setup

## Next Steps

1. Run `flutter pub get` to install dependencies
2. Configure Firebase project settings if needed
3. Test OTP verification with FCM token inclusion
4. Implement push notification handling in the app

## Notes

- FCM tokens are automatically managed and refreshed
- The integration gracefully handles Firebase initialization failures
- Mock tokens ensure development and testing can proceed without Firebase setup
