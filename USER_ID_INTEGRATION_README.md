# User ID Integration Guide

This document explains how the user ID is now automatically integrated into all API services after completing the user profile.

## Overview

After a user completes their profile, the complete user data (including the user ID) is automatically saved and used in all subsequent API calls. This eliminates the need to manually pass user IDs to API methods.

## How It Works

### 1. Profile Completion
When a user completes their profile in `CompleteProfileScreen`, the API response contains the complete user data:

```json
{
  "message": "User details updated successfully",
  "user": {
    "id": 8,
    "name": "hhshhs",
    "email": "hhahsjs@gmail.com",
    "email_verified_at": null,
    "full_address": "xnnxjxjsjsjsjdjjd",
    "state": "Jammu & Kashmir",
    "district": "Kulgam",
    "phone": "8566655664",
    "verified_otp": "0",
    "avatar": null,
    "created_at": "2025-08-22T09:46:11.000000Z",
    "updated_at": "2025-08-22T09:46:27.000000Z",
    "otp_verified": "1"
  }
}
```

### 2. Automatic Data Storage
The complete user data is automatically stored using:
- `AuthUtils.setLoggedIn()` - Stores login state and user data
- `AuthUtils.storeUserData()` - Stores complete user object
- User ID is stored separately for quick access

### 3. Automatic User ID Retrieval
All API methods now automatically retrieve the current user ID when no `userId` parameter is provided.

## Updated API Methods

### Before (Required userId parameter)
```dart
// Old way - required userId parameter
final result = await ApiService.getCustomers("8");
final result = await ApiService.createItem(userId: "8", itemName: "Product");
```

### After (Automatic userId retrieval)
```dart
// New way - automatic userId retrieval
final result = await ApiService.getCustomers(); // No userId needed
final result = await ApiService.createItem(itemName: "Product"); // No userId needed
```

## Available API Methods

### Business Profile
```dart
// Get business profile for current user
final result = await ApiService.getBusinessProfile();

// Update business profile for current user
final result = await ApiService.updateBusinessProfile(
  businessName: "My Business",
  gstNo: "GST123456",
  // ... other parameters
);
```

### Customers
```dart
// Get customers for current user
final result = await ApiService.getCustomers();

// Create customer for current user
final result = await ApiService.createCustomer(
  customerName: "John Doe",
  companyName: "ABC Corp",
  // ... other parameters
);
```

### Items
```dart
// Get items for current user
final result = await ApiService.getItems();

// Create item for current user
final result = await ApiService.createItem(
  itemName: "Product Name",
  // ... other parameters
);

// Update item for current user
final result = await ApiService.updateItem(
  itemId: 123,
  itemName: "Updated Name",
  // ... other parameters
);
```

### Invoices
```dart
// Create invoice for current user
final result = await ApiService.createInvoice(
  customerId: "456",
  customerName: "John Doe",
  // ... other parameters
);
```

### Item Categories
```dart
// Create item category for current user
final result = await ApiService.createItemCategory("Electronics");
```

## Helper Utility Class

For convenience, use the `UserApiHelper` class:

```dart
import '../utils/user_api_helper.dart';

// Get current user
final user = await UserApiHelper.getCurrentUser();
final userId = await UserApiHelper.getCurrentUserId();

// Check authentication
final isAuthenticated = await UserApiHelper.isUserAuthenticated();

// Get authentication status
final authStatus = await UserApiHelper.getUserAuthStatus();
```

## Data Storage

User data is stored in SharedPreferences with the following keys:
- `isLoggedIn` - Boolean indicating login status
- `userPhone` - User's phone number
- `userName` - User's name
- `userData` - Complete user object (JSON string)
- `userId` - User ID (integer)

## Error Handling

If a user is not authenticated, API methods return:
```dart
{
  'success': false,
  'message': 'User not authenticated',
  // ... other fields
}
```

## Migration Guide

### For Existing Code

1. **Remove userId parameters** from API calls where possible
2. **Update method signatures** to make userId optional
3. **Use automatic retrieval** for current user operations

### Example Migration

```dart
// Before
final customers = await ApiService.getCustomers("8");

// After
final customers = await ApiService.getCustomers();
```

## Benefits

1. **Automatic User Context** - No need to manually track user IDs
2. **Cleaner API Calls** - Simpler method signatures
3. **Consistent Authentication** - All API calls automatically check user authentication
4. **Better User Experience** - Seamless profile completion and data access
5. **Reduced Errors** - No more hardcoded or incorrect user IDs

## Testing

To test the integration:

1. Complete user profile
2. Check that user data is stored
3. Make API calls without userId parameters
4. Verify that current user ID is automatically used
5. Test authentication error handling

## Troubleshooting

### User Not Authenticated Error
- Ensure user has completed profile
- Check if user data is stored in SharedPreferences
- Verify login state is set to true

### Missing User Data
- Check if profile completion was successful
- Verify API response contains user object
- Check SharedPreferences storage

### API Calls Failing
- Ensure user is logged in
- Check network connectivity
- Verify API endpoints are correct
- Check user ID is being retrieved correctly
