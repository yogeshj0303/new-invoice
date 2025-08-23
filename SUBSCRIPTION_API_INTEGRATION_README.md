# Subscription API Integration

This document describes the integration of the subscription API in the invoice app.

## API Endpoint

- **URL**: `https://new-invoice.acttconnect.com/api/subscriptions`
- **Method**: GET
- **Response Format**: JSON

## API Response Structure

```json
{
  "success": true,
  "data": [
    {
      "id": 4,
      "plan_name": "Basic",
      "plan_price": "99.00",
      "plan_validity": "30",
      "user_add_count": "1",
      "business_add_count": "1",
      "invoice_add_count": "100",
      "plan_status": "active",
      "created_at": "2025-08-23T06:24:19.000000Z",
      "updated_at": "2025-08-23T06:24:19.000000Z",
      "plan_description": "Up to 100 invoice/ month , 1 buisness , 1 user , basic CRM features"
    },
    {
      "id": 5,
      "plan_name": "Advanced",
      "plan_price": "199.00",
      "plan_validity": "30",
      "user_add_count": "5",
      "business_add_count": "3",
      "invoice_add_count": "1000",
      "plan_status": "active",
      "created_at": "2025-08-23T06:26:48.000000Z",
      "updated_at": "2025-08-23T06:26:48.000000Z",
      "plan_description": "Up to 1000 invoice / month , 3 business , 5 users , advanced CRM features"
    },
    {
      "id": 6,
      "plan_name": "Enterprise",
      "plan_price": "399.00",
      "plan_validity": "unlimited",
      "user_add_count": "unlimited",
      "business_add_count": "unlimited",
      "invoice_add_count": "unlimited",
      "plan_status": "active",
      "created_at": "2025-08-23T06:26:48.000000Z",
      "updated_at": "2025-08-23T06:26:48.000000Z",
      "plan_description": "Up to unlimited invoice / month , unlimited businesses , unlimited users , full CRM Suite"
    }
  ]
}
```

## Implementation Details

### 1. Subscription Model (`lib/models/subscription.dart`)

The `Subscription` class represents a subscription plan with the following properties:
- `id`: Unique identifier for the plan
- `planName`: Name of the plan (Basic, Advanced, Enterprise)
- `planPrice`: Monthly price in rupees
- `planValidity`: Plan validity period (30 days or unlimited)
- `userAddCount`: Number of users allowed
- `businessAddCount`: Number of businesses allowed
- `invoiceAddCount`: Number of invoices allowed per month
- `planStatus`: Current status of the plan
- `planDescription`: Detailed description of the plan features

### 2. API Service (`lib/services/api_service.dart`)

The `ApiService.getSubscriptions()` method:
- Makes a GET request to the subscriptions endpoint
- Handles both success and error responses
- Parses the JSON response into `Subscription` objects
- Returns a standardized response format with success status and data

### 3. Subscription Screen (`lib/screens/subscription_screen.dart`)

The subscription screen has been updated to:
- Fetch subscription data from the API on initialization
- Display loading states while fetching data
- Show error states with retry functionality
- Display subscription plans dynamically based on API data
- Allow users to select plans and view detailed information
- Support pull-to-refresh functionality
- Show subscription confirmation dialogs

## Features

### Dynamic Plan Display
- Plans are loaded from the API and displayed with appropriate colors and gradients
- Fallback to default plans if API fails
- Real-time plan selection with visual feedback

### Loading and Error States
- Loading spinner while fetching data
- Error messages with retry buttons
- Graceful fallback to default plans

### Interactive Elements
- Plan selection with tap feedback
- Subscription details modal for each plan
- Confirmation dialog before subscription
- Pull-to-refresh functionality

### Responsive Design
- Animated transitions and micro-interactions
- Adaptive color schemes based on plan types
- Mobile-optimized layout

## Usage

1. **View Plans**: The screen automatically loads subscription plans from the API
2. **Select Plan**: Tap on any plan to select it and view details
3. **View Details**: Tap on a selected plan to see detailed information
4. **Subscribe**: Use the "Subscribe Now" button to initiate subscription
5. **Refresh**: Pull down or use the refresh button to reload plans

## Error Handling

The integration includes comprehensive error handling:
- Network errors with user-friendly messages
- API response validation
- Fallback to default plans when needed
- Retry mechanisms for failed requests

## Future Enhancements

- Payment gateway integration
- Subscription management
- Plan comparison features
- Usage analytics
- Custom plan creation
