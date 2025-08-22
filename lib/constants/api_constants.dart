class ApiConstants {
  // Base URL
  static const String baseURL = 'https://new-invoice.acttconnect.com';
  
  // API Endpoints
  static const String sendOTP = '/api/send-otp';
  static const String verifyOTP = '/api/verify-otp';
  static const String updateUserInfo = '/api/update-user-info';
  static const String customers = '/api/customers';
  static const String items = '/api/items';
  static const String userItems = '/api/items/user';
  // Updated to use standard RESTful endpoint
  static const String updateItem = '/api/items';
  static const String invoices = '/api/invoices';
  
  // API Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // API Response Keys
  static const String messageKey = 'message';
  static const String otpKey = 'otp';
  static const String successKey = 'status'; // Changed from 'success' to 'status' to match API
  static const String errorKey = 'error';
} 