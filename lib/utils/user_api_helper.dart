import '../services/api_service.dart';
import '../models/user.dart';
import '../utils/auth_utils.dart';

/// Helper class to demonstrate how to use the updated API service
/// with automatic user ID retrieval
class UserApiHelper {
  
  /// Get current user information
  static Future<User?> getCurrentUser() async {
    return await ApiService.getCurrentUser();
  }
  
  /// Get current user ID
  static Future<int?> getCurrentUserId() async {
    return await ApiService.getCurrentUserId();
  }
  
  /// Example: Get business profile for current user
  static Future<Map<String, dynamic>> getCurrentUserBusinessProfile() async {
    // No need to pass userId - it will be retrieved automatically
    return await ApiService.getBusinessProfile();
  }
  
  /// Example: Get customers for current user
  static Future<Map<String, dynamic>> getCurrentUserCustomers() async {
    // No need to pass userId - it will be retrieved automatically
    return await ApiService.getCustomers();
  }
  
  /// Example: Get items for current user
  static Future<Map<String, dynamic>> getCurrentUserItems() async {
    // No need to pass userId - it will be retrieved automatically
    return await ApiService.getItems();
  }
  
  /// Example: Create a customer for current user
  static Future<Map<String, dynamic>> createCustomerForCurrentUser({
    required String customerName,
    required String companyName,
    required String email,
    required String phone,
    required String gst,
    required String gstTreatment,
    required String placeOfSupply,
    required String state,
  }) async {
    // No need to pass userId - it will be retrieved automatically
    return await ApiService.createCustomer(
      customerName: customerName,
      companyName: companyName,
      email: email,
      phone: phone,
      gst: gst,
      gstTreatment: gstTreatment,
      placeOfSupply: placeOfSupply,
      state: state,
    );
  }
  
  /// Example: Create an item for current user
  static Future<Map<String, dynamic>> createItemForCurrentUser({
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
  }) async {
    // No need to pass userId - it will be retrieved automatically
    return await ApiService.createItem(
      itemName: itemName,
      unit: unit,
      salesPriceAmount: salesPriceAmount,
      salesPriceTax: salesPriceTax,
      purchasePriceAmount: purchasePriceAmount,
      purchasePriceTax: purchasePriceTax,
      mrpPrice: mrpPrice,
      gst: gst,
      openingStock: openingStock,
      asOfDate: asOfDate,
      lowAlertStatus: lowAlertStatus,
      lowAlertQuantity: lowAlertQuantity,
      itemCategoryId: itemCategoryId,
      itemDescription: itemDescription,
      showOnlineStore: showOnlineStore,
      imagePaths: imagePaths,
    );
  }
  
  /// Example: Update an item for current user
  static Future<Map<String, dynamic>> updateItemForCurrentUser({
    required int itemId,
    String? itemName,
    String? unit,
    String? salesPriceAmount,
    String? purchasePriceAmount,
    String? mrpPrice,
    String? gst,
    int? openingStock,
    int? lowAlertQuantity,
    String? lowAlertStatus,
    String? asOfDate,
    int? itemCategoryId,
    String? itemDescription,
    String? showOnlineStore,
  }) async {
    // No need to pass userId - it will be retrieved automatically
    return await ApiService.updateItem(
      itemId: itemId,
      itemName: itemName,
      unit: unit,
      salesPriceAmount: salesPriceAmount,
      purchasePriceAmount: purchasePriceAmount,
      mrpPrice: mrpPrice,
      gst: gst,
      openingStock: openingStock,
      lowAlertQuantity: lowAlertQuantity,
      lowAlertStatus: lowAlertStatus,
      asOfDate: asOfDate,
      itemCategoryId: itemCategoryId,
      itemDescription: itemDescription,
      showOnlineStore: showOnlineStore,
    );
  }
  
  /// Example: Create an invoice for current user
  static Future<Map<String, dynamic>> createInvoiceForCurrentUser({
    required String customerId,
    required String customerName,
    required String customerNumber,
    required String paymentType,
    required String discountPercent,
    required String discountAmount,
    required String roundOff,
    required String totalAmount,
    required String amountReceived,
    required String note,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> charges,
  }) async {
    // No need to pass userId - it will be retrieved automatically
    return await ApiService.createInvoice(
      customerId: customerId,
      customerName: customerName,
      customerNumber: customerNumber,
      paymentType: paymentType,
      discountPercent: discountPercent,
      discountAmount: discountAmount,
      roundOff: roundOff,
      totalAmount: totalAmount,
      amountReceived: amountReceived,
      note: note,
      items: items,
      charges: charges,
    );
  }
  
  /// Example: Create an item category for current user
  static Future<Map<String, dynamic>> createItemCategoryForCurrentUser(String categoryName) async {
    // No need to pass userId - it will be retrieved automatically
    return await ApiService.createItemCategory(categoryName);
  }
  
  /// Check if user is authenticated and has data
  static Future<bool> isUserAuthenticated() async {
    final userId = await getCurrentUserId();
    return userId != null;
  }
  
  /// Get user authentication status with details
  static Future<Map<String, dynamic>> getUserAuthStatus() async {
    final isLoggedIn = await AuthUtils.isLoggedIn();
    final hasUserData = await AuthUtils.hasUserData();
    final userId = await getCurrentUserId();
    final user = await getCurrentUser();
    
    return {
      'isLoggedIn': isLoggedIn,
      'hasUserData': hasUserData,
      'userId': userId,
      'user': user?.toJson(),
    };
  }
}
