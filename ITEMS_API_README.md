# Items API Integration

This document describes the API integration for managing items in the invoice app.

## API Endpoints

### Base URL
```
https://new-invoice.acttconnect.com
```

### Create Item
- **Endpoint**: `POST /api/items`
- **Description**: Creates a new item with pricing, stock, and other details
- **Parameters**: Query parameters for all item fields

### Get Items
- **Endpoint**: `GET /api/items/user?user_id={userId}`
- **Description**: Retrieves all items for a specific user
- **Parameters**: `user_id` (required)

### Update Item
- **Endpoint**: `POST /api/items/update`
- **Description**: Updates an existing item
- **Parameters**: 
  - `item_id` (required): ID of the item to update
  - `user_id` (required): ID of the user
  - All other fields are optional and will only be updated if provided
- **Response**: Updated item data with success message

## API Response Structure

### Create Item Response
```json
{
  "message": "Item created successfully",
  "data": {
    "item_name": "Sample Item",
    "user_id": "1",
    "updated_at": "2025-08-21T10:29:29.000000Z",
    "created_at": "2025-08-21T10:29:29.000000Z",
    "id": 12,
    "pricings": [
      {
        "id": 12,
        "item_id": 12,
        "unit": "kg",
        "salesprice_amount": "100.50",
        "salesprice_tax": 1,
        "purches_price_amount": "80.25",
        "purches_price_tax": 1,
        "mrp_price": "120.00",
        "gst": "18.00",
        "created_at": "2025-08-21T10:29:29.000000Z",
        "updated_at": "2025-08-21T10:29:29.000000Z"
      }
    ],
    "stocks": [
      {
        "id": 13,
        "item_id": 12,
        "opening_stock": 50,
        "as_of_date": "2025-08-21",
        "item_name": "Sample Item",
        "low_alert_status": "true",
        "low_alert_quantity": 10,
        "created_at": "2025-08-21T10:29:29.000000Z",
        "updated_at": "2025-08-21T10:29:29.000000Z"
      }
    ],
    "other_images": [],
    "details": {
      "id": 7,
      "item_id": 12,
      "item_category_id": 1,
      "item_description": "This is a sample item description",
      "show_online_store": "true",
      "user_id": 1,
      "created_at": "2025-08-21T10:29:29.000000Z",
      "updated_at": "2025-08-21T10:29:29.000000Z"
    }
  }
}
```

### Get Items Response
```json
{
  "data": [
    {
      "id": 4,
      "item_name": "Updated Item",
      "user_id": 1,
      "created_at": "2025-08-21T06:53:18.000000Z",
      "updated_at": "2025-08-21T07:28:04.000000Z",
      "pricings": [...],
      "stocks": [...],
      "other_images": [...],
      "details": {...}
    }
  ],
  "message": "Items fetched successfully"
}
```

### Update Item Response
```json
{
  "message": "Item updated successfully",
  "data": {
    "id": 4,
    "item_name": "Updated Item",
    "user_id": "1",
    "created_at": "2025-08-21T06:53:18.000000Z",
    "updated_at": "2025-08-21T07:28:04.000000Z",
    "pricings": [
      {
        "id": 13,
        "item_id": 4,
        "unit": "box",
        "salesprice_amount": null,
        "salesprice_tax": 0,
        "purches_price_amount": null,
        "purches_price_tax": 0,
        "mrp_price": null,
        "gst": null,
        "created_at": "2025-08-21T10:44:34.000000Z",
        "updated_at": "2025-08-21T10:44:34.000000Z"
      }
    ],
    "stocks": [
      {
        "id": 14,
        "item_id": 4,
        "opening_stock": 100,
        "as_of_date": null,
        "item_name": "Updated Item",
        "low_alert_status": "0",
        "low_alert_quantity": null,
        "created_at": "2025-08-21T10:44:34.000000Z",
        "updated_at": "2025-08-21T10:44:34.000000Z"
      }
    ],
    "other_images": [
      {
        "id": 4,
        "item_id": 4,
        "image_path": "item_other_images/qzaMTBTonO4iDeWHIO1I5kJkBJGEiKXheu9dkTWG.jpg",
        "created_at": "2025-08-21T06:53:18.000000Z",
        "updated_at": "2025-08-21T06:53:18.000000Z"
      }
    ],
    "details": {
      "id": 1,
      "item_id": 4,
      "item_category_id": 1,
      "item_description": "Updated description",
      "show_online_store": "false",
      "user_id": 1,
      "created_at": "2025-08-21T06:53:18.000000Z",
      "updated_at": "2025-08-21T07:28:04.000000Z"
    }
  }
}
```

## Implementation Details

### Models

The app uses the following models to represent items:

1. **Item**: Main item model containing all item information
2. **ItemPricing**: Pricing details including unit, prices, and GST
3. **ItemStock**: Stock information including opening stock and alerts
4. **ItemImage**: Item images
5. **ItemDetails**: Additional item details like category and description

### API Service Methods

#### Create Item
```dart
static Future<Map<String, dynamic>> createItem({
  required String userId,
  required String itemName,
  String? unit,
  String? salesPriceAmount,
  int salesPriceTax = 0,
  String? purchasePriceAmount,
  int purchasePriceTax = 0,
  String? mrpPrice,
  String? gst,
  int? openingStock,
  String? asOfDate,
  String? lowAlertStatus,
  int? lowAlertQuantity,
  int? itemCategoryId,
  String? itemDescription,
  String? showOnlineStore,
  List<String>? imagePaths,
})
```

#### Get Items
```dart
static Future<Map<String, dynamic>> getItems(String userId)
```

**Note**: This method uses the endpoint `/api/items/user?user_id={userId}` to fetch items for a specific user.

#### Update Item
```dart
static Future<Map<String, dynamic>> updateItem({
  required int itemId,
  required String userId,
  String? itemName,
  String? unit,
  String? salesPriceAmount,
  int salesPriceTax = 0,
  String? purchasePriceAmount,
  int purchasePriceTax = 0,
  String? mrpPrice,
  String? gst,
  int? openingStock,
  String? asOfDate,
  String? lowAlertStatus,
  int? lowAlertQuantity,
  int? itemCategoryId,
  String? itemDescription,
  String? showOnlineStore,
  List<String>? imagePaths,
})
```

**Note**: This method uses the endpoint `/api/items/update` to update an existing item. Only the fields that are provided will be updated.

### Usage Example

```dart
// Create a new item
final result = await ApiService.createItem(
  userId: '1',
  itemName: 'Sample Item',
  unit: 'kg',
  salesPriceAmount: '100.50',
  gst: '18.00',
  openingStock: 50,
  itemDescription: 'Sample description',
);

if (result['success'] == true) {
  print('Item created: ${result['message']}');
  final item = result['item'] as Item;
  print('Item ID: ${item.id}');
} else {
  print('Error: ${result['message']}');
}

// Get all items
final itemsResult = await ApiService.getItems('1');
if (itemsResult['success'] == true) {
  final items = itemsResult['items'] as List<Item>;
  print('Found ${items.length} items');
}

// Update an existing item
final updateResult = await ApiService.updateItem(
  itemId: 4,
  userId: '1',
  itemName: 'Updated Item Name',
  salesPriceAmount: '150.00',
  itemDescription: 'Updated description',
);

if (updateResult['success'] == true) {
  print('Item updated: ${updateResult['message']}');
  final updatedItem = updateResult['item'] as Item;
  print('Updated Item ID: ${updatedItem.id}');
} else {
  print('Error: ${updateResult['message']}');
}
```

## Form Fields

The Create Item screen includes the following form fields:

## Edit Functionality

The app also includes an edit feature for existing items:

### Edit Bottom Sheet
- **Location**: `lib/widgets/edit_bottom_sheet_content.dart`
- **Features**:
  - Price & Discount tab for editing pricing information
  - Other Details tab for editing description and other fields
  - Real-time calculation of totals with tax and discounts
  - Integration with the update item API
- **Usage**: Accessible from the Add Item screen when editing items in cart

### Pricing Tab
- Item Name (required)
- Unit
- Sales Price
- Purchase Price
- MRP Price
- GST (dropdown: None, 5%, 12%, 18%, 28%)
- HSN Code

### Stock Tab
- Opening Stock
- As of Date
- Low Stock Alert (toggle)
- Low Alert Quantity (conditional)

### Other Tab
- Item Images
- Item Category (dropdown)
- Show in Online Store (toggle)
- Item Description

## Error Handling

The API service includes comprehensive error handling:

1. **Network Errors**: Catches and reports network-related exceptions
2. **HTTP Status Codes**: Handles different HTTP response codes
3. **Response Parsing**: Safely parses JSON responses with fallbacks
4. **User Feedback**: Shows success/error messages via SnackBar

## Future Enhancements

1. **Image Upload**: Implement actual image picker and upload functionality
2. **Category Management**: Add API endpoints for managing item categories
3. **Validation**: Add server-side validation feedback
4. **Bulk Operations**: Support for creating multiple items at once
5. **Search & Filter**: Add search and filtering capabilities for items

## Testing

To test the API integration:

1. Ensure the backend API is running and accessible
2. Use the Create Item screen to create test items
3. Verify items appear in the items list
4. Check console logs for API request/response details
5. Test error scenarios (network issues, invalid data, etc.)

## Notes

- The current implementation uses a hardcoded user ID ('1') for testing
- Category mapping is currently hardcoded and should be replaced with API calls
- Image upload functionality is prepared but not fully implemented
- All API calls include comprehensive logging for debugging
