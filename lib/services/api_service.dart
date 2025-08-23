import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/business_profile.dart';
import '../models/customer.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../utils/auth_utils.dart';
import 'dart:io'; // Added for File and Platform
import '../models/item.dart'; // Added for Item
import '../models/detailed_invoice.dart'; // Added for DetailedInvoice
import '../services/fcm_service.dart';

class ApiService {
  // Helper method to get current user ID
  static Future<int?> getCurrentUserId() async {
    try {
      return await AuthUtils.getCurrentUserId();
    } catch (e) {
      print('⚠️ [WARNING] Failed to get current user ID: $e');
      return null;
    }
  }

  // Helper method to get current user
  static Future<User?> getCurrentUser() async {
    try {
      return await AuthUtils.getCurrentUser();
    } catch (e) {
      print('⚠️ [WARNING] Failed to get current user: $e');
      return null;
    }
  }

  // Send OTP API
  static Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      // Get FCM token with fallback
      String fcmToken = await FCMService.getTokenWithFallback();
      
      // Debug: Print request details
      final url = '${ApiConstants.baseURL}${ApiConstants.sendOTP}';
      
      // Try different phone number formats
      String cleanPhone = phoneNumber;
      if (phoneNumber.startsWith('+91')) {
        cleanPhone = phoneNumber.substring(3); // Remove +91 prefix
      }
      
      final requestBody = {
        'phone': cleanPhone,
      };
      
      // Add FCM token to request body
      requestBody['fcm_token'] = fcmToken;
      
      print('🔍 [DEBUG] Send OTP Request:');
      print('   URL: $url');
      print('   Headers: ${ApiConstants.defaultHeaders}');
      print('   Body: $requestBody');
      print('   JSON Body: ${jsonEncode(requestBody)}');
      print('   FCM Token: $fcmToken');
      
      // Try different request formats if the first one fails
      print('📡 [DEBUG] Making HTTP POST request...');
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode(requestBody),
      );

      // Debug: Print response details
      print('📡 [DEBUG] Send OTP Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [DEBUG] Success Response Data: $data');
        return {
          ApiConstants.successKey: true,
          ApiConstants.messageKey: data[ApiConstants.messageKey],
          ApiConstants.otpKey: data[ApiConstants.otpKey],
        };
      } else {
        // Handle different status codes
        final errorData = jsonDecode(response.body);
        print('❌ [DEBUG] Error Response Data: $errorData');
        print('❌ [DEBUG] Error Status Code: ${response.statusCode}');
        
        // Try to extract error message from different possible fields
        String errorMessage = 'Failed to send OTP';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        } else if (errorData.containsKey('msg')) {
          errorMessage = errorData['msg'];
        }
        
        return {
          ApiConstants.successKey: false,
          ApiConstants.messageKey: errorMessage,
          ApiConstants.errorKey: 'HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception occurred: $e');
      print('💥 [DEBUG] Exception type: ${e.runtimeType}');
      print('💥 [DEBUG] Stack trace: ${StackTrace.current}');
      return {
        ApiConstants.successKey: false,
        ApiConstants.messageKey: 'Network error: ${e.toString()}',
        ApiConstants.errorKey: 'Exception',
      };
    }
  }

  // Verify OTP API
  static Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    try {
      // Get FCM token with fallback
      String fcmToken = await FCMService.getTokenWithFallback();
      
      // Build URL with FCM token
      String url = '${ApiConstants.baseURL}${ApiConstants.verifyOTP}?phone=$phoneNumber&otp=$otp&fcm_token=$fcmToken';
      
      print('🔍 [DEBUG] Verify OTP Request:');
      print('   URL: $url');
      print('   Headers: ${ApiConstants.defaultHeaders}');
      print('   Phone: $phoneNumber, OTP: $otp');
      print('   FCM Token: $fcmToken');
      
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConstants.defaultHeaders,
      );

      // Debug: Print response details
      print('📡 [DEBUG] Verify OTP Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [DEBUG] Success Response Data: $data');
        print('   Response type: ${data.runtimeType}');
        print('   Response keys: ${data.keys.toList()}');
        
        // Check if user_info exists in the response
        Map<String, dynamic> responseData = {
          ApiConstants.successKey: true,
          ApiConstants.messageKey: data[ApiConstants.messageKey],
        };
        
        // Add user_info if it exists
        if (data.containsKey('user_info')) {
          responseData['user_info'] = data['user_info'];
          print('✅ [DEBUG] User info found in response: ${data['user_info']}');
          print('   User info type: ${data['user_info'].runtimeType}');
          if (data['user_info'] is Map) {
            print('   User info keys: ${data['user_info'].keys.toList()}');
          }
        } else {
          print('ℹ️ [DEBUG] No user_info found in response');
        }
        
        return responseData;
      } else {
        // Handle different status codes
        final errorData = jsonDecode(response.body);
        print('❌ [DEBUG] Error Response Data: $errorData');
        return {
          ApiConstants.successKey: false,
          ApiConstants.messageKey: errorData[ApiConstants.messageKey] ?? 'Failed to verify OTP',
          ApiConstants.errorKey: 'HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception occurred: $e');
      print('💥 [DEBUG] Exception type: ${e.runtimeType}');
      print('💥 [DEBUG] Stack trace: ${StackTrace.current}');
      return {
        ApiConstants.successKey: false,
        ApiConstants.messageKey: 'Network error: ${e.toString()}',
        ApiConstants.errorKey: 'Exception',
      };
    }
  }

  // Update User Profile API
  static Future<Map<String, dynamic>> updateUserProfile({
    required String phoneNumber,
    required String name,
    required String email,
    required String state,
    required String district,
    required String fullAddress,
  }) async {
    try {
      // Debug: Print request details
      final url = '${ApiConstants.baseURL}${ApiConstants.updateUserInfo}';
      
      // Clean phone number (remove +91 prefix if present)
      String cleanPhone = phoneNumber;
      if (phoneNumber.startsWith('+91')) {
        cleanPhone = phoneNumber.substring(3); // Remove +91 prefix
      }
      
      final requestBody = {
        'phone': cleanPhone,
        'name': name,
        'email': email,
        'state': state,
        'district': district,
        'full_address': fullAddress,
      };
      
      print('🔍 [DEBUG] Update Profile Request:');
      print('   URL: $url');
      print('   Headers: ${ApiConstants.defaultHeaders}');
      print('   Body: $requestBody');
      print('   JSON Body: ${jsonEncode(requestBody)}');
      
      print('📡 [DEBUG] Making HTTP POST request...');
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode(requestBody),
      );

      // Debug: Print response details
      print('📡 [DEBUG] Update Profile Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [DEBUG] Success Response Data: $data');
        return {
          ApiConstants.successKey: true,
          ApiConstants.messageKey: data[ApiConstants.messageKey],
          'user': data['user'],
        };
      } else {
        // Handle different status codes
        final errorData = jsonDecode(response.body);
        print('❌ [DEBUG] Error Response Data: $errorData');
        print('❌ [DEBUG] Error Status Code: ${response.statusCode}');
        
        // Try to extract error message from different possible fields
        String errorMessage = 'Failed to update profile';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        } else if (errorData.containsKey('msg')) {
          errorMessage = errorData['msg'];
        }
        
        return {
          ApiConstants.successKey: false,
          ApiConstants.messageKey: errorMessage,
          ApiConstants.errorKey: 'HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception occurred: $e');
      print('💥 [DEBUG] Exception type: ${e.runtimeType}');
      print('💥 [DEBUG] Stack trace: ${StackTrace.current}');
      return {
        ApiConstants.successKey: false,
        ApiConstants.messageKey: 'Network error: ${e.toString()}',
        ApiConstants.errorKey: 'Exception',
      };
    }
  }

  // Get Business Profile API
  static Future<Map<String, dynamic>> getBusinessProfile([int? userId]) async {
    try {
      // Use provided userId or get current user ID
      final currentUserId = userId ?? await getCurrentUserId();
      if (currentUserId == null) {
        return {
          'success': false,
          ApiConstants.messageKey: 'User not authenticated',
          'businessProfile': null,
        };
      }
      
      final url = '${ApiConstants.baseURL}/api/business-profiles?user_id=$currentUserId';
      final response = await http.get(Uri.parse(url), headers: ApiConstants.defaultHeaders);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null && data['data'].isNotEmpty) {
          final businessProfile = BusinessProfile.fromJson(data['data'][0]);
          return {
            'success': true, // Use 'success' for consistency with other methods
            'businessProfile': businessProfile,
            ApiConstants.messageKey: 'Business profile loaded successfully',
          };
        } else {
          return {
            'success': false,
            'notFound': true, // Special indicator for when profile doesn't exist
            ApiConstants.messageKey: 'No business profile found',
            'businessProfile': null,
          };
        }
      } else if (response.statusCode == 404) {
        // Handle 404 specifically - business profile doesn't exist
        return {
          'success': false,
          'notFound': true, // Special indicator for 404 errors
          ApiConstants.messageKey: 'Business profile not found. You can create one below.',
          'businessProfile': null,
        };
      } else {
        return {
          'success': false,
          ApiConstants.messageKey: 'Failed to load business profile. Status: ${response.statusCode}',
          'businessProfile': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        ApiConstants.messageKey: 'Error loading business profile: ${e.toString()}',
        'businessProfile': null,
      };
    }
  }

  // Update Business Profile API
  static Future<Map<String, dynamic>> updateBusinessProfile({
    int? userId,
    required String businessName,
    required String gstNo,
    required String phoneNoFirst,
    String? phoneNoSecond,
    required String email,
    String? businessEmail,
    required String businessAddress,
    required String pincode,
    required String businessDesc,
    required String businessCategory,
    String? website,
    required String businessState,
    required String businessType,
    String? digitalSign,
    String? businessSignature,
  }) async {
    try {
      // Use provided userId or get current user ID
      final currentUserId = userId ?? await getCurrentUserId();
      if (currentUserId == null) {
        return {
          'success': false,
          ApiConstants.messageKey: 'User not authenticated',
          'businessProfile': null,
        };
      }
      
      final url = '${ApiConstants.baseURL}/api/business-profiles?user_id=$currentUserId';
      
      // Build query parameters
      final queryParams = <String, String>{
        'user_id': currentUserId.toString(),
        'business_name': businessName,
        'gst_no': gstNo,
        'phone_no_first': phoneNoFirst,
        'email': email,
        'business_address': businessAddress,
        'pincode': pincode,
        'business_desc': businessDesc,
        'business_category': businessCategory,
        'business_state': businessState,
        'business_type': businessType,
      };

      // Add optional parameters if they exist
      if (phoneNoSecond != null && phoneNoSecond.isNotEmpty) {
        queryParams['phone_no_second'] = phoneNoSecond;
      }
      if (businessEmail != null && businessEmail.isNotEmpty) {
        queryParams['business_email'] = businessEmail;
      }
      if (website != null && website.isNotEmpty) {
        queryParams['website'] = website;
      }

      // Build the final URL with query parameters
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      
      print('🔍 [DEBUG] Update Business Profile Request:');
      print('URL: $uri');
      print('Headers: ${ApiConstants.defaultHeaders}');

      // Create multipart request for file uploads
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      request.headers.addAll(ApiConstants.defaultHeaders);
      
      // Add form fields
      request.fields.addAll(queryParams);
      
      // Add digital signature if exists
      if (digitalSign != null && digitalSign.isNotEmpty) {
        // If digitalSign is a file path, add it as a file
        if (digitalSign.startsWith('/') || digitalSign.contains('\\')) {
          final file = File(digitalSign);
          if (await file.exists()) {
            final stream = http.ByteStream(file.openRead());
            final length = await file.length();
            final multipartFile = http.MultipartFile(
              'digital_sign',
              stream,
              length,
              filename: file.path.split('/').last,
            );
            request.files.add(multipartFile);
          }
        } else {
          // If it's base64 or other format, add as field
          request.fields['digital_sign'] = digitalSign;
        }
      }
      
      // Add business signature if exists
      if (businessSignature != null && businessSignature.isNotEmpty) {
        // If businessSignature is a file path, add it as a file
        if (businessSignature.startsWith('/') || businessSignature.contains('\\')) {
          final file = File(businessSignature);
          if (await file.exists()) {
            final stream = http.ByteStream(file.openRead());
            final length = await file.length();
            final multipartFile = http.MultipartFile(
              'business_signature',
              stream,
              length,
              filename: file.path.split('/').last,
            );
            request.files.add(multipartFile);
          }
        } else {
          // If it's base64 or other format, add as field
          request.fields['business_signature'] = businessSignature;
        }
      }

      print('📡 [DEBUG] Sending multipart request...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('📡 [DEBUG] Update Business Profile Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        print('🔍 [DEBUG] Parsed response data: $data');
        
        if (data['status'] == true) {
          // Safely handle the businessProfile data
          BusinessProfile? businessProfile;
          try {
            if (data['data'] != null) {
              businessProfile = BusinessProfile.fromJson(data['data']);
              print('✅ [DEBUG] Successfully parsed business profile from response');
            } else {
              print('⚠️ [DEBUG] No data field in response, businessProfile will be null');
            }
          } catch (parseError) {
            print('⚠️ [DEBUG] Error parsing business profile from response: $parseError');
            businessProfile = null;
          }
          
          return {
            'success': true,
            ApiConstants.messageKey: data['message'] ?? 'Business profile updated successfully',
            'businessProfile': businessProfile,
          };
        } else {
          return {
            'success': false,
            ApiConstants.messageKey: data['message'] ?? 'Failed to update business profile',
            'businessProfile': null,
          };
        }
      } else {
        return {
          'success': false,
          ApiConstants.messageKey: 'Failed to update business profile. Status: ${response.statusCode}',
          'businessProfile': null,
        };
      }
    } catch (e) {
      print('❌ [ERROR] Update Business Profile Exception: $e');
      print('❌ [ERROR] Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        ApiConstants.messageKey: 'Error updating business profile: ${e.toString()}',
        'businessProfile': null,
      };
    }
  }

  // Create Customer API
  static Future<Map<String, dynamic>> createCustomer({
    String? userId,
    required String customerName,
    required String companyName,
    required String email,
    required String phone,
    required String gst,
    required String gstTreatment,
    required String placeOfSupply,
    required String state,
  }) async {
    try {
      // Use provided userId or get current user ID
      final currentUserId = userId ?? await getCurrentUserId();
      if (currentUserId == null) {
        return {
          'success': false,
          ApiConstants.messageKey: 'User not authenticated',
          'customer': null,
        };
      }
      
      final url = '${ApiConstants.baseURL}${ApiConstants.customers}';
      
      // Build query parameters
      final queryParams = <String, String>{
        'user_id': currentUserId.toString(),
        'customer_name': customerName,
        'company_name': companyName,
        'email': email,
        'phone': phone,
        'gst': gst,
        'gst_treatment': gstTreatment,
        'place_of_supply': placeOfSupply,
        'state': state,
      };

      // Build the final URL with query parameters
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      
      print('🔍 [DEBUG] Create Customer Request:');
      print('URL: $uri');
      print('Headers: ${ApiConstants.defaultHeaders}');
      print('Query Parameters: $queryParams');

      final response = await http.post(
        uri,
        headers: ApiConstants.defaultHeaders,
      );

      print('📡 [DEBUG] Create Customer Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ [DEBUG] Success Response Data: $data');
        
        if (data['status'] == true) {
          // Parse the customer data from response
          Customer? customer;
          try {
            if (data['data'] != null) {
              customer = Customer.fromJson(data['data']);
              print('✅ [DEBUG] Successfully parsed customer from response');
            } else {
              print('⚠️ [DEBUG] No data field in response, customer will be null');
            }
          } catch (parseError) {
            print('⚠️ [DEBUG] Error parsing customer from response: $parseError');
            customer = null;
          }
          
          return {
            'success': true,
            ApiConstants.messageKey: data['message'] ?? 'Customer created successfully',
            'customer': customer,
          };
        } else {
          return {
            'success': false,
            ApiConstants.messageKey: data['message'] ?? 'Failed to create customer',
            'customer': null,
          };
        }
      } else {
        // Handle different status codes
        final errorData = jsonDecode(response.body);
        print('❌ [DEBUG] Error Response Data: $errorData');
        print('❌ [DEBUG] Error Status Code: ${response.statusCode}');
        
        // Try to extract error message from different possible fields
        String errorMessage = 'Failed to create customer';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        } else if (errorData.containsKey('msg')) {
          errorMessage = errorData['msg'];
        }
        
        return {
          'success': false,
          ApiConstants.messageKey: errorMessage,
          ApiConstants.errorKey: 'HTTP ${response.statusCode}',
          'customer': null,
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception occurred: $e');
      print('💥 [DEBUG] Exception type: ${e.runtimeType}');
      print('💥 [DEBUG] Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        ApiConstants.messageKey: 'Network error: ${e.toString()}',
        ApiConstants.errorKey: 'Exception',
        'customer': null,
      };
    }
  }

  // Get Customers List API
  static Future<Map<String, dynamic>> getCustomers([String? userId]) async {
    try {
      // Use provided userId or get current user ID
      final currentUserId = userId ?? await getCurrentUserId();
      
      // Build URL - try with user_id first, then without if user_id is null
      String url;
      if (currentUserId != null) {
        url = '${ApiConstants.baseURL}${ApiConstants.customers}?user_id=$currentUserId';
      } else {
        url = '${ApiConstants.baseURL}${ApiConstants.customers}';
        print('⚠️ [DEBUG] No user ID available, calling API without user_id parameter');
      }
      
      print('🔍 [DEBUG] Get Customers Request:');
      print('URL: $url');
      print('Headers: ${ApiConstants.defaultHeaders}');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.defaultHeaders,
      );

      print('📡 [DEBUG] Get Customers Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [DEBUG] Success Response Data: $data');
        
        if (data['status'] == true) {
          // Parse the customers list from response
          List<Customer> customers = [];
          try {
            if (data['data'] != null && data['data'] is List) {
              print('🔍 [DEBUG] Data field is a list with ${(data['data'] as List).length} items');
              print('🔍 [DEBUG] First item in data: ${(data['data'] as List).isNotEmpty ? (data['data'] as List).first : 'empty list'}');
              
              customers = (data['data'] as List)
                  .map((customerJson) {
                    print('🔍 [DEBUG] Parsing customer JSON: $customerJson');
                    try {
                      final customer = Customer.fromJson(customerJson);
                      print('🔍 [DEBUG] Successfully parsed customer: ${customer.customerName}');
                      return customer;
                    } catch (e) {
                      print('⚠️ [DEBUG] Error parsing individual customer: $e');
                      print('⚠️ [DEBUG] Customer JSON: $customerJson');
                      rethrow;
                    }
                  })
                  .toList();
              print('✅ [DEBUG] Successfully parsed ${customers.length} customers from response');
            } else {
              print('⚠️ [DEBUG] No data field in response or data is not a list');
              print('⚠️ [DEBUG] Data field type: ${data['data']?.runtimeType}');
              print('⚠️ [DEBUG] Data field value: ${data['data']}');
            }
          } catch (parseError) {
            print('⚠️ [DEBUG] Error parsing customers from response: $parseError');
            print('⚠️ [DEBUG] Parse error stack trace: ${StackTrace.current}');
            customers = [];
          }
          
          return {
            ApiConstants.successKey: true,
            ApiConstants.messageKey: data['message'] ?? 'Customers loaded successfully',
            'customers': customers,
          };
        } else {
          print('❌ [DEBUG] API returned status false: ${data['message']}');
          return {
            ApiConstants.successKey: false,
            ApiConstants.messageKey: data['message'] ?? 'Failed to load customers',
            'customers': [],
          };
        }
      } else {
        // Handle different status codes
        final errorData = jsonDecode(response.body);
        print('❌ [DEBUG] Error Response Data: $errorData');
        print('❌ [DEBUG] Error Status Code: ${response.statusCode}');
        
        // Try to extract error message from different possible fields
        String errorMessage = 'Failed to load customers';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['msg'];
        } else if (errorData.containsKey('msg')) {
          errorMessage = errorData['msg'];
        }
        
        return {
          ApiConstants.successKey: false,
          ApiConstants.messageKey: errorMessage,
          ApiConstants.errorKey: 'HTTP ${response.statusCode}',
          'customers': [],
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception occurred: $e');
      print('💥 [DEBUG] Exception type: ${e.runtimeType}');
      print('💥 [DEBUG] Stack trace: ${StackTrace.current}');
      return {
        ApiConstants.successKey: false,
        ApiConstants.messageKey: 'Network error: ${e.toString()}',
        ApiConstants.errorKey: 'Exception',
        'customers': [],
      };
    }
  }

  // Get Item Categories API
  static Future<Map<String, dynamic>> getItemCategories() async {
    try {
      final url = '${ApiConstants.baseURL}/api/item-categories';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 [DEBUG] Categories API Raw Response: ${response.body}');
        print('🔍 [DEBUG] Categories API Parsed Data: $data');
        return data;
      } else {
        print('❌ [DEBUG] Categories API Error Status: ${response.statusCode}');
        print('❌ [DEBUG] Categories API Error Body: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to load categories. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Create Item Category API
  static Future<Map<String, dynamic>> createItemCategory(String categoryName) async {
    try {
      // Get current user ID
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }
      
      final url = '${ApiConstants.baseURL}/api/item-categories';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': currentUserId.toString(),
          'item_category_name': categoryName,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ [DEBUG] Category Created Successfully: ${response.body}');
        return data;
      } else {
        print('❌ [DEBUG] Create Category Error Status: ${response.statusCode}');
        print('❌ [DEBUG] Create Category Error Body: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to create category. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ [DEBUG] Create Category Exception: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Create Item API
  static Future<Map<String, dynamic>> createItem({
    String? userId,
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
    try {
      // Use provided userId or get current user ID
      final currentUserId = userId ?? await getCurrentUserId();
      if (currentUserId == null) {
        return {
          'success': false,
          ApiConstants.messageKey: 'User not authenticated',
          'item': null,
        };
      }
      
      final url = '${ApiConstants.baseURL}${ApiConstants.items}';
      
      // Build form data fields matching the API structure
      final Map<String, String> formFields = {
        'user_id': currentUserId.toString(),
        'item_name': itemName,
      };

      // Add optional fields
      if (itemCategoryId != null) {
        formFields['item_category_id'] = itemCategoryId.toString();
      }
      if (itemDescription != null && itemDescription.isNotEmpty) {
        formFields['item_description'] = itemDescription;
      }
      if (showOnlineStore != null && showOnlineStore.isNotEmpty) {
        formFields['show_online_store'] = showOnlineStore;
      }

      // Add pricing data as nested array
      if (unit != null && unit.isNotEmpty) {
        formFields['pricings[0][unit]'] = unit;
      }
      if (salesPriceAmount != null && salesPriceAmount.isNotEmpty) {
        formFields['pricings[0][salesprice_amount]'] = salesPriceAmount;
      }
      if (salesPriceTax >= 0) {
        formFields['pricings[0][salesprice_tax]'] = salesPriceTax.toString();
      }
      if (purchasePriceAmount != null && purchasePriceAmount.isNotEmpty) {
        formFields['pricings[0][purches_price_amount]'] = purchasePriceAmount;
      }
      if (purchasePriceTax >= 0) {
        formFields['pricings[0][purches_price_tax]'] = purchasePriceTax.toString();
      }
      if (mrpPrice != null && mrpPrice.isNotEmpty) {
        formFields['pricings[0][mrp_price]'] = mrpPrice;
      }
      if (gst != null && gst.isNotEmpty) {
        formFields['pricings[0][gst]'] = gst;
      }

      // Add stock data as nested array
      if (openingStock != null) {
        formFields['stocks[0][opening_stock]'] = openingStock.toString();
      }
      if (asOfDate != null && asOfDate.isNotEmpty) {
        formFields['stocks[0][as_of_date]'] = asOfDate;
      }
      if (lowAlertStatus != null && lowAlertStatus.isNotEmpty) {
        formFields['stocks[0][low_alert_status]'] = lowAlertStatus;
      }
      if (lowAlertQuantity != null) {
        formFields['stocks[0][low_alert_quantity]'] = lowAlertQuantity.toString();
      }

      print('🔍 [DEBUG] Create Item Request:');
      print('URL: $url');
      print('Original default headers: ${ApiConstants.defaultHeaders}');
      print('Form Fields: $formFields');
      print('Image Paths: $imagePaths');

      // Create multipart request for form data
      final request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Add headers (excluding Content-Type for multipart requests)
      final headers = Map<String, String>.from(ApiConstants.defaultHeaders);
      headers.remove('Content-Type'); // Remove Content-Type for multipart requests
      print('📡 [DEBUG] Modified headers (Content-Type removed):');
      print('   Modified headers: $headers');
      request.headers.addAll(headers);
      
      // Debug: Print the actual headers being sent with the request
      print('📡 [DEBUG] Actual request headers after modification:');
      print('   Headers: ${request.headers}');
      
      // Add form fields
      request.fields.addAll(formFields);
      
      // Add images if they exist
      if (imagePaths != null && imagePaths.isNotEmpty) {
        print('📸 [DEBUG] Processing ${imagePaths.length} image paths');
        for (int i = 0; i < imagePaths.length; i++) {
          final imagePath = imagePaths[i];
          print('📸 [DEBUG] Processing image path $i: $imagePath');
          final file = File(imagePath);
          if (await file.exists()) {
            final stream = http.ByteStream(file.openRead());
            final length = await file.length();
            print('📸 [DEBUG] File exists, size: $length bytes');
            final filename = file.path.split(Platform.pathSeparator).last;
            print('📸 [DEBUG] Filename: $filename');
            final multipartFile = http.MultipartFile(
              'images[$i]', // Use indexed field name as expected by backend
              stream,
              length,
              filename: filename,
            );
            request.files.add(multipartFile);
            print('📸 [DEBUG] Added image file: ${file.path} (size: $length bytes)');
          } else {
            print('⚠️ [DEBUG] Image file not found: $imagePath');
          }
        }
      } else {
        print('⚠️ [DEBUG] No image paths provided or empty');
      }

      print('📡 [DEBUG] Sending multipart request...');
      print('📸 [DEBUG] Total files to upload: ${request.files.length}');
      print('📸 [DEBUG] Total form fields: ${request.fields.length}');
      
      // Debug: Print all form fields and files being sent
      print('📤 [DEBUG] Form fields being sent:');
      request.fields.forEach((key, value) {
        print('   $key: $value');
      });
      
      print('📤 [DEBUG] Files being sent:');
      for (int i = 0; i < request.files.length; i++) {
        final file = request.files[i];
        print('   File $i: ${file.field} - ${file.filename} (${file.length} bytes)');
      }
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('📡 [DEBUG] Create Item Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        print('✅ [DEBUG] Success Response Data: $data');
        
        if (data['message'] != null && data['message'].toString().contains('successfully')) {
          // Parse the item data from response
          Item? item;
          try {
            if (data['data'] != null) {
              item = Item.fromJson(data['data']);
              print('✅ [DEBUG] Successfully parsed item from response');
            } else {
              print('⚠️ [DEBUG] No data field in response, item will be null');
            }
          } catch (parseError) {
            print('⚠️ [DEBUG] Error parsing item from response: $parseError');
            item = null;
          }
          
          return {
            'success': true,
            ApiConstants.messageKey: data['message'] ?? 'Item created successfully',
            'item': item,
          };
        } else {
          return {
            'success': false,
            ApiConstants.messageKey: data['message'] ?? 'Failed to create item',
            'item': null,
          };
        }
      } else {
        // Handle different status codes
        final errorData = jsonDecode(responseBody);
        print('❌ [DEBUG] Error Response Data: $errorData');
        print('❌ [DEBUG] Error Status Code: ${response.statusCode}');
        
        // Try to extract error message from different possible fields
        String errorMessage = 'Failed to create item';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        } else if (errorData.containsKey('msg')) {
          errorMessage = errorData['msg'];
        }
        
        return {
          'success': false,
          ApiConstants.messageKey: errorMessage,
          ApiConstants.errorKey: 'HTTP ${response.statusCode}',
          'item': null,
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception occurred: $e');
      print('💥 [DEBUG] Exception type: ${e.runtimeType}');
      print('💥 [DEBUG] Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        ApiConstants.messageKey: 'Network error: ${e.toString()}',
        ApiConstants.errorKey: 'Exception',
        'item': null,
      };
    }
  }

  // Get Items List API
  static Future<Map<String, dynamic>> getItems([String? userId]) async {
    try {
      // Use provided userId or get current user ID
      final currentUserId = userId ?? await getCurrentUserId();
      if (currentUserId == null) {
        return {
          'success': false,
          ApiConstants.messageKey: 'User not authenticated',
          'items': [],
        };
      }
      
      final url = '${ApiConstants.baseURL}${ApiConstants.userItems}?user_id=$currentUserId';
      
      print('🔍 [DEBUG] Get Items Request:');
      print('URL: $url');
      print('Headers: ${ApiConstants.defaultHeaders}');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.defaultHeaders,
      );

      print('📡 [DEBUG] Get Items Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [DEBUG] Success Response Data: $data');
        
        if (data['data'] != null && data['data'] is List) {
          // Parse the items list from response
          List<Item> items = [];
          try {
            items = (data['data'] as List)
                .map((itemJson) => Item.fromJson(itemJson))
                .toList();
            print('✅ [DEBUG] Successfully parsed ${items.length} items from response');
          } catch (parseError) {
            print('⚠️ [DEBUG] Error parsing items from response: $parseError');
            items = [];
          }
          
          return {
            'success': true,
            ApiConstants.messageKey: data['message'] ?? 'Items loaded successfully',
            'items': items,
          };
        } else {
          return {
            'success': true,
            ApiConstants.messageKey: data['message'] ?? 'No items found',
            'items': [],
          };
        }
      } else {
        // Handle different status codes
        final errorData = jsonDecode(response.body);
        print('❌ [DEBUG] Error Response Data: $errorData');
        print('❌ [DEBUG] Error Status Code: ${response.statusCode}');
        
        // Try to extract error message from different possible fields
        String errorMessage = 'Failed to load items';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        } else if (errorData.containsKey('msg')) {
          errorMessage = errorData['msg'];
        }
        
        return {
          'success': false,
          ApiConstants.messageKey: errorMessage,
          ApiConstants.errorKey: 'HTTP ${response.statusCode}',
          'items': [],
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception occurred: $e');
      print('💥 [DEBUG] Exception type: ${e.runtimeType}');
      print('💥 [DEBUG] Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        ApiConstants.messageKey: 'Network error: ${e.toString()}',
        ApiConstants.errorKey: 'Exception',
        'items': [],
      };
    }
  }

  // Get Item by ID API
  static Future<Map<String, dynamic>> getItemById(int itemId) async {
    try {
      final url = '${ApiConstants.baseURL}${ApiConstants.items}/$itemId';
      
      print('🔍 [DEBUG] Get Item by ID Request:');
      print('URL: $url');
      print('Item ID: $itemId');
      print('Headers: ${ApiConstants.defaultHeaders}');
      
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.defaultHeaders,
      );
      
      print('📥 [DEBUG] Get Item by ID Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [DEBUG] Success Response Data: $data');
        
        return {
          'success': true,
          'data': data['data'],
          ApiConstants.messageKey: data['message'] ?? 'Item fetched successfully',
        };
      } else {
        // Handle different status codes
        final errorData = jsonDecode(response.body);
        print('❌ [DEBUG] Error Response Data: $errorData');
        print('❌ [DEBUG] Error Status Code: ${response.statusCode}');
        
        // Try to extract error message from different possible fields
        String errorMessage = 'Failed to fetch item';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        } else if (errorData.containsKey('msg')) {
          errorMessage = errorData['msg'];
        }
        
        return {
          'success': false,
          'data': null,
          ApiConstants.messageKey: errorMessage,
          ApiConstants.errorKey: 'HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception occurred: $e');
      print('💥 [DEBUG] Exception type: ${e.runtimeType}');
      print('💥 [DEBUG] Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        'data': null,
        ApiConstants.messageKey: 'Network error: ${e.toString()}',
        ApiConstants.errorKey: 'Exception',
      };
    }
  }

  // Update Item API
  static Future<Map<String, dynamic>> updateItem({
    required int itemId,
    String? userId,
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
    try {
      // Validate item ID
      if (itemId <= 0) {
        print('❌ [ERROR] Invalid item ID: $itemId');
        return {
          'success': false,
          'item': null,
          ApiConstants.messageKey: 'Invalid item ID',
          ApiConstants.errorKey: 'Validation Error',
        };
      }
      
      // Build URL
      final url = '${ApiConstants.baseURL}${ApiConstants.updateItem}';
      
      print('🔄 [DEBUG] Update Item Request:');
      print('URL: $url');
      print('Item ID: $itemId (Type: ${itemId.runtimeType})');
      print('Headers: ${ApiConstants.defaultHeaders}');
      
      // Prepare form fields according to API format
      final Map<String, String> formFields = <String, String>{};
      
      
      
      // Use provided userId or get current user ID
      final currentUserId = userId ?? await getCurrentUserId();
      if (currentUserId == null) {
        return {
          'success': false,
          'item': null,
          ApiConstants.messageKey: 'User not authenticated',
          ApiConstants.errorKey: 'Authentication Error',
        };
      }
      
      // Add item ID and user ID first
      formFields['id'] = itemId.toString();
      formFields['user_id'] = currentUserId.toString();
      
      print('🔍 [DEBUG] Item ID being sent: ${formFields['id']} (Type: ${formFields['id'].runtimeType})');
      
      // Add basic fields
      if (itemName != null) formFields['item_name'] = itemName;
      if (itemDescription != null) formFields['item_description'] = itemDescription;
      if (showOnlineStore != null) formFields['show_online_store'] = showOnlineStore;
      if (itemCategoryId != null) formFields['item_category_id'] = itemCategoryId.toString();
      
      // Add pricing fields
      if (unit != null) formFields['pricings[0][unit]'] = unit;
      if (salesPriceAmount != null) formFields['pricings[0][salesprice_amount]'] = salesPriceAmount;
      if (purchasePriceAmount != null) formFields['pricings[0][purches_price_amount]'] = purchasePriceAmount;
      if (mrpPrice != null) formFields['pricings[0][mrp_price]'] = mrpPrice;
      if (gst != null) formFields['pricings[0][gst]'] = gst;
      
      // Add default tax values (required by API)
      formFields['pricings[0][salesprice_tax]'] = '1';
      formFields['pricings[0][purches_price_tax]'] = '1';
      
      // Add stock fields
      if (openingStock != null) formFields['stocks[0][opening_stock]'] = openingStock.toString();
      if (lowAlertQuantity != null) formFields['stocks[0][low_alert_quantity]'] = lowAlertQuantity.toString();
      if (lowAlertStatus != null) formFields['stocks[0][low_alert_status]'] = lowAlertStatus;
      if (asOfDate != null) formFields['stocks[0][as_of_date]'] = asOfDate;
      
      print('📤 [DEBUG] Form Fields: $formFields');
      print('📤 [DEBUG] Final URL: $url');
      print('📤 [DEBUG] Item ID in form fields: ${formFields['id']}');
      print('📤 [DEBUG] User ID in form fields: ${formFields['user_id']}');

      // Create multipart request for form data (same as create item)
      final request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Add headers (remove Content-Type for multipart request as it's set automatically)
      final headers = Map<String, String>.from(ApiConstants.defaultHeaders);
      headers.remove('Content-Type'); // Let the multipart request set the correct content type
      request.headers.addAll(headers);
      
      // Add form fields
      request.fields.addAll(formFields);
      
      print('📤 [DEBUG] Request URL: ${request.url}');
      print('📤 [DEBUG] Request Fields: ${request.fields}');
      print('📤 [DEBUG] Request Headers: ${request.headers}');

      print('📡 [DEBUG] Sending multipart request...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      print('📥 [DEBUG] Update Item Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: $responseBody');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        print('✅ [DEBUG] Success Response Data: $data');
        
        if (data['data'] != null) {
          final updatedItem = Item.fromJson(data['data']);
          
          print('✅ [DEBUG] Item updated successfully');
          return {
            'success': true,
            'item': updatedItem,
            ApiConstants.messageKey: data['message'] ?? 'Item updated successfully',
          };
        } else {
          print('⚠️ [DEBUG] No data field in response');
          return {
            'success': false,
            'item': null,
            ApiConstants.messageKey: data['message'] ?? 'Item updated but no data returned',
          };
        }
      } else {
        // Handle different status codes
        final errorData = jsonDecode(responseBody);
        print('❌ [DEBUG] Error Response Data: $errorData');
        print('❌ [DEBUG] Error Status Code: ${response.statusCode}');
        
        // Try to extract error message from different possible fields
        String errorMessage = 'Failed to update item';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        } else if (errorData.containsKey('msg')) {
          errorMessage = errorData['msg'];
        }
        
        return {
          'success': false,
          'item': null,
          ApiConstants.messageKey: errorMessage,
          ApiConstants.errorKey: 'HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception occurred: $e');
      print('💥 [DEBUG] Exception type: ${e.runtimeType}');
      print('💥 [DEBUG] Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        'item': null,
        ApiConstants.messageKey: 'Network error: ${e.toString()}',
        ApiConstants.errorKey: 'Exception',
      };
    }
  }

  // Delete Item API
  static Future<Map<String, dynamic>> deleteItem(int itemId) async {
    try {
      final url = '${ApiConstants.baseURL}${ApiConstants.items}/$itemId';
      
      print('🗑️ [DEBUG] Delete Item Request:');
      print('URL: $url');
      print('Item ID: $itemId');
      print('Headers: ${ApiConstants.defaultHeaders}');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: ApiConstants.defaultHeaders,
      );
      
      print('📥 [DEBUG] Delete Item Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [DEBUG] Success Response Data: $data');
        
        if (data['message'] != null && data['message'].toString().contains('deleted successfully')) {
          return {
            'success': true,
            ApiConstants.messageKey: data['message'] ?? 'Item deleted successfully',
          };
        } else {
          return {
            'success': false,
            ApiConstants.messageKey: data['message'] ?? 'Failed to delete item',
          };
        }
      } else {
        // Handle different status codes
        final errorData = jsonDecode(response.body);
        print('❌ [DEBUG] Error Response Data: $errorData');
        print('❌ [DEBUG] Error Status Code: ${response.statusCode}');
        
        // Try to extract error message from different possible fields
        String errorMessage = 'Failed to delete item';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        } else if (errorData.containsKey('msg')) {
          errorMessage = errorData['msg'];
        }
        
        return {
          'success': false,
          ApiConstants.messageKey: errorMessage,
          ApiConstants.errorKey: 'HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception occurred: $e');
      print('💥 [DEBUG] Exception type: ${e.runtimeType}');
      print('💥 [DEBUG] Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        ApiConstants.messageKey: 'Network error: ${e.toString()}',
        ApiConstants.errorKey: 'Exception',
      };
    }
  }

  // Create Invoice API
  static Future<Map<String, dynamic>> createInvoice({
    String? userId,
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
    try {
      final url = '${ApiConstants.baseURL}${ApiConstants.invoices}';
      
      print('🔍 [DEBUG] Create Invoice Request:');
      print('URL: $url');
      print('Headers: ${ApiConstants.defaultHeaders}');
      
      // Validate input data
      if (items.isEmpty) {
        return {
          'success': false,
          ApiConstants.messageKey: 'At least one item is required',
          'invoice': null,
        };
      }

      if (customerName.isEmpty) {
        return {
          'success': false,
          ApiConstants.messageKey: 'Customer name is required',
          'invoice': null,
        };
      }

      if (customerNumber.isEmpty) {
        return {
          'success': false,
          ApiConstants.messageKey: 'Customer phone number is required',
          'invoice': null,
        };
      }

      // Validate phone number format (10 digits)
      if (customerNumber.length != 10 || !RegExp(r'^\d{10}$').hasMatch(customerNumber)) {
        return {
          'success': false,
          ApiConstants.messageKey: 'Phone number must be 10 digits',
          'invoice': null,
        };
      }

      // Validate amounts
      final totalAmountValue = double.tryParse(totalAmount);
      final amountReceivedValue = double.tryParse(amountReceived);
      
      if (totalAmountValue == null || totalAmountValue <= 0) {
        return {
          'success': false,
          ApiConstants.messageKey: 'Invalid total amount',
          'invoice': null,
        };
      }

      if (amountReceivedValue == null || amountReceivedValue < totalAmountValue) {
        return {
          'success': false,
          ApiConstants.messageKey: 'Amount received cannot be less than total amount',
          'invoice': null,
        };
      }

      // Validate discount and roundoff
      final discountPercentValue = double.tryParse(discountPercent);
      final roundOffValue = double.tryParse(roundOff);
      
      if (discountPercentValue != null && (discountPercentValue < 0 || discountPercentValue > 100)) {
        return {
          'success': false,
          ApiConstants.messageKey: 'Discount percentage must be between 0 and 100',
          'invoice': null,
        };
      }

      // Validate payment type
      final validPaymentTypes = ['cash', 'card', 'upi', 'bank_transfer'];
      if (!validPaymentTypes.contains(paymentType.toLowerCase())) {
        return {
          'success': false,
          ApiConstants.messageKey: 'Invalid payment type',
          'invoice': null,
        };
      }

      // Use provided userId or get current user ID
      final currentUserId = userId ?? await getCurrentUserId();
      if (currentUserId == null) {
        return {
          'success': false,
          ApiConstants.messageKey: 'User not authenticated',
          'invoice': null,
        };
      }
      
      // Validate customer ID
      if (customerId.isEmpty) {
        return {
          'success': false,
          ApiConstants.messageKey: 'Customer ID is required',
          'invoice': null,
        };
      }

      // Validate note length
      if (note.length > 500) {
        return {
          'success': false,
          ApiConstants.messageKey: 'Note cannot exceed 500 characters',
          'invoice': null,
        };
      }

      // Prepare the request body according to the API structure
      final Map<String, dynamic> requestBody = {
        'user_id': currentUserId.toString(),
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_number': customerNumber,
        'payment_type': paymentType.toLowerCase(),
        'discount_percent': discountPercent,
        'discount_amount': discountAmount,
        'round_off': roundOff,
        'total_amount': totalAmount,
        'amount_received': amountReceived,
        'note': note,
        'items': items.map((item) {
          final qty = item['qty'] ?? 0;
          final price = item['price'] ?? 0.0;
          final total = qty * price;
          final itemName = item['name'] ?? 'Unknown Item';
          
          // Validate item data
          if (qty <= 0) {
            throw Exception('Item quantity must be greater than 0');
          }
          if (price <= 0) {
            throw Exception('Item price must be greater than 0');
          }
          
          return {
            'item_id': item['id'] ?? DateTime.now().millisecondsSinceEpoch, // Generate temporary ID if none exists
            'quantity': qty,
            'price': price.toString(),
            'total': total.toString(),
          };
        }).toList(),
        'charges': charges.map((charge) {
          final price = charge['price'] ?? 0.0;
          final chargeName = charge['name'] ?? '';
          
          // Validate charge data
          if (chargeName.isEmpty) {
            throw Exception('Charge name cannot be empty');
          }
          if (price < 0) {
            throw Exception('Charge price cannot be negative');
          }
          
          return {
            'charge_name': chargeName,
            'price': price.toString(),
          };
        }).toList(),
      };
      
      print('📤 [DEBUG] Request Body: $requestBody');
      print('📤 [DEBUG] JSON Body: ${jsonEncode(requestBody)}');

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: ApiConstants.defaultHeaders,
          body: jsonEncode(requestBody),
        );

        print('📡 [DEBUG] Create Invoice Response:');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          print('✅ [DEBUG] Success Response Data: $data');
          
          if (data['message'] != null && data['message'].toString().contains('successfully')) {
            return {
              'success': true,
              ApiConstants.messageKey: data['message'] ?? 'Invoice created successfully',
              'invoice': data['data'],
            };
          } else {
            return {
              'success': false,
              ApiConstants.messageKey: data['message'] ?? 'Failed to create invoice',
              'invoice': null,
            };
          }
        } else {
          // Handle different status codes
          final errorData = jsonDecode(response.body);
          print('❌ [DEBUG] Error Response Data: $errorData');
          print('❌ [DEBUG] Error Status Code: ${response.statusCode}');
          
          // Try to extract error message from different possible fields
          String errorMessage = 'Failed to create invoice';
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          } else if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          } else if (errorData.containsKey('msg')) {
            errorMessage = errorData['msg'];
          }
          
          return {
            'success': false,
            ApiConstants.messageKey: errorMessage,
            ApiConstants.errorKey: 'HTTP ${response.statusCode}',
            'invoice': null,
          };
        }
      } catch (e) {
        print('💥 [DEBUG] Exception occurred: $e');
        print('💥 [DEBUG] Exception type: ${e.runtimeType}');
        print('💥 [DEBUG] Stack trace: ${StackTrace.current}');
        return {
          'success': false,
          ApiConstants.messageKey: 'Network error: ${e.toString()}',
          ApiConstants.errorKey: 'Exception',
          'invoice': null,
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Validation Exception: $e');
      return {
        'success': false,
        ApiConstants.messageKey: 'Validation error: ${e.toString()}',
        'invoice': null,
      };
    }
  }

  // Get Transactions API
  static Future<Map<String, dynamic>> getTransactions([int? userId]) async {
    try {
      // Use provided userId or get current user ID
      final currentUserId = userId ?? await getCurrentUserId();
      if (currentUserId == null) {
        return {
          'success': false,
          ApiConstants.messageKey: 'User not authenticated',
          'transactions': [],
        };
      }
      
      final url = '${ApiConstants.baseURL}${ApiConstants.transactions}/$currentUserId';
      
      print('🔍 [DEBUG] Get Transactions Request:');
      print('URL: $url');
      print('Headers: ${ApiConstants.defaultHeaders}');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.defaultHeaders,
      );

      print('📡 [DEBUG] Get Transactions Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [DEBUG] Success Response Data: $data');
        
        if (data is List) {
          // Parse the transactions list from response
          List<Transaction> transactions = [];
          try {
            transactions = data
                .map((transactionJson) => Transaction.fromJson(transactionJson))
                .toList();
            print('✅ [DEBUG] Successfully parsed ${transactions.length} transactions from response');
          } catch (parseError) {
            print('⚠️ [DEBUG] Error parsing transactions from response: $parseError');
            transactions = [];
          }
          
          return {
            'success': true,
            ApiConstants.messageKey: 'Transactions loaded successfully',
            'transactions': transactions,
          };
        } else {
          return {
            'success': true,
            ApiConstants.messageKey: 'No transactions found',
            'transactions': [],
          };
        }
      } else {
        // Handle different status codes
        final errorData = jsonDecode(response.body);
        print('❌ [DEBUG] Error Response Data: $errorData');
        print('❌ [DEBUG] Error Status Code: ${response.statusCode}');
        
        // Try to extract error message from different possible fields
        String errorMessage = 'Failed to load transactions';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        } else if (errorData.containsKey('msg')) {
          errorMessage = errorData['msg'];
        }
        
        return {
          'success': false,
          ApiConstants.messageKey: errorMessage,
          ApiConstants.errorKey: 'HTTP ${response.statusCode}',
          'transactions': [],
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception occurred: $e');
      print('💥 [DEBUG] Exception type: ${e.runtimeType}');
      print('📡 [DEBUG] Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        ApiConstants.messageKey: 'Network error: ${e.toString()}',
        ApiConstants.errorKey: 'Exception',
        'transactions': [],
      };
    }
  }

  // Get Detailed Invoice API
  static Future<Map<String, dynamic>> getDetailedInvoice(int invoiceId) async {
    try {
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null) {
        return {
          'success': false,
          ApiConstants.messageKey: 'User not authenticated',
          'detailedInvoice': null,
        };
      }
      
      // Use the invoices endpoint with user_id parameter
      final url = '${ApiConstants.baseURL}/api/invoices?user_id=$currentUserId';
      
      print('🔍 [DEBUG] Get Detailed Invoice Request:');
      print('URL: $url');
      print('Headers: ${ApiConstants.defaultHeaders}');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.defaultHeaders,
      );

      print('📡 [DEBUG] Get Detailed Invoice Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [DEBUG] Success Response Data: $data');
        
        // Handle different possible response structures
        List<dynamic> invoicesList = [];
        
        if (data['data'] is List) {
          invoicesList = data['data'] as List;
        } else if (data is List) {
          invoicesList = data;
        } else if (data['invoices'] is List) {
          invoicesList = data['invoices'] as List;
        }
        
        if (invoicesList.isNotEmpty) {
          // Find the specific invoice by ID
          final targetInvoice = invoicesList.firstWhere(
            (invoice) => invoice['id'] == invoiceId,
            orElse: () => null,
          );
          
          if (targetInvoice != null) {
            try {
              final detailedInvoice = DetailedInvoice.fromJson(targetInvoice);
              print('✅ [DEBUG] Successfully parsed detailed invoice: ${detailedInvoice.id}');
              
              return {
                'success': true,
                ApiConstants.messageKey: 'Detailed invoice loaded successfully',
                'detailedInvoice': detailedInvoice,
              };
            } catch (parseError) {
              print('⚠️ [DEBUG] Error parsing detailed invoice: $parseError');
              print('⚠️ [DEBUG] Invoice data that failed to parse: $targetInvoice');
              return {
                'success': false,
                ApiConstants.messageKey: 'Error parsing invoice data: $parseError',
                'detailedInvoice': null,
              };
            }
          } else {
            print('⚠️ [DEBUG] Invoice with ID $invoiceId not found in ${invoicesList.length} invoices');
            return {
              'success': false,
              ApiConstants.messageKey: 'Invoice not found',
              'detailedInvoice': null,
            };
          }
        } else {
          print('⚠️ [DEBUG] No invoices found in response. Response structure: ${data.keys.toList()}');
          return {
            'success': false,
            ApiConstants.messageKey: 'No invoices found',
            'detailedInvoice': null,
          };
        }
      } else {
        // Handle different status codes
        final errorData = jsonDecode(response.body);
        print('❌ [DEBUG] Error Response Data: $errorData');
        print('❌ [DEBUG] Error Status Code: ${response.statusCode}');
        
        // Try to extract error message from different possible fields
        String errorMessage = 'Failed to load detailed invoice';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else if (errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'];
        } else if (errorData.containsKey('msg')) {
          errorMessage = errorData['msg'];
        }
        
        return {
          'success': false,
          ApiConstants.messageKey: errorMessage,
          ApiConstants.errorKey: 'HTTP ${response.statusCode}',
          'detailedInvoice': null,
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception occurred: $e');
      print('💥 [DEBUG] Exception type: ${e.runtimeType}');
      print('📡 [DEBUG] Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        ApiConstants.messageKey: 'Network error: ${e.toString()}',
        ApiConstants.errorKey: 'Exception',
        'detailedInvoice': null,
      };
    }
  }
  
  // Alternative method to get invoice data directly from transaction
  static Future<Map<String, dynamic>> getInvoiceDataFromTransaction(Transaction transaction) async {
    try {
      // Since we have the transaction data, we can create a mock detailed invoice
      // This is a fallback when the API doesn't work
      print('🔍 [DEBUG] Creating invoice data from transaction: ${transaction.id}');
      
      // Create a mock detailed invoice from the transaction data
      final mockInvoice = {
        'id': transaction.invoiceId,
        'user_id': transaction.userId,
        'customer_id': transaction.invoice.customerId,
        'customer_name': transaction.customerName,
        'customer_number': transaction.invoice.customerNumber,
        'payment_type': transaction.invoice.paymentType,
        'discount_percent': transaction.invoice.discountPercent,
        'discount_amount': transaction.invoice.discountAmount,
        'round_off': transaction.invoice.roundOff,
        'total_amount': transaction.invoice.totalAmount,
        'amount_received': transaction.invoice.amountReceived,
        'note': transaction.invoice.note,
        'created_at': transaction.createdAt,
        'updated_at': transaction.updatedAt,
        'items': [
          {
            'id': 1,
            'invoice_id': transaction.invoiceId,
            'item_id': 1,
            'quantity': 1,
            'price': transaction.invoice.totalAmount,
            'total': transaction.invoice.totalAmount,
            'created_at': transaction.createdAt,
            'updated_at': transaction.updatedAt,
            'item': {
              'id': 1,
              'item_name': 'Invoice Item',
              'user_id': transaction.userId,
              'created_at': transaction.createdAt,
              'updated_at': transaction.updatedAt,
            }
          }
        ],
        'charges': [],
        'customer': {
          'id': transaction.invoice.customerId,
          'customer_name': transaction.customerName,
          'company_name': '',
          'email': '',
          'phone': transaction.invoice.customerNumber,
          'gst': '',
          'gst_treatment': '',
          'place_of_supply': '',
          'state': '',
          'user_id': transaction.userId,
          'created_at': transaction.createdAt,
          'updated_at': transaction.updatedAt,
        }
      };
      
      try {
        final detailedInvoice = DetailedInvoice.fromJson(mockInvoice);
        print('✅ [DEBUG] Successfully created mock detailed invoice from transaction');
        
        return {
          'success': true,
          ApiConstants.messageKey: 'Invoice data created from transaction',
          'detailedInvoice': detailedInvoice,
        };
      } catch (parseError) {
        print('⚠️ [DEBUG] Error creating mock invoice: $parseError');
        return {
          'success': false,
          ApiConstants.messageKey: 'Error creating invoice data',
          'detailedInvoice': null,
        };
      }
    } catch (e) {
      print('💥 [DEBUG] Exception creating mock invoice: $e');
      return {
        'success': false,
        ApiConstants.messageKey: 'Error creating invoice data: ${e.toString()}',
        'detailedInvoice': null,
      };
    }
  }
}