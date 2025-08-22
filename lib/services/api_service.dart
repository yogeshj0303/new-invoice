import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/business_profile.dart';
import '../models/customer.dart';
import 'dart:io'; // Added for File
import '../models/item.dart'; // Added for Item

class ApiService {
  // Send OTP API
  static Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
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
      
      print('🔍 [DEBUG] Send OTP Request:');
      print('   URL: $url');
      print('   Headers: ${ApiConstants.defaultHeaders}');
      print('   Body: $requestBody');
      print('   JSON Body: ${jsonEncode(requestBody)}');
      
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
      // Debug: Print request details
      final url = '${ApiConstants.baseURL}${ApiConstants.verifyOTP}?phone=$phoneNumber&otp=$otp';
      
      print('🔍 [DEBUG] Verify OTP Request:');
      print('   URL: $url');
      print('   Headers: ${ApiConstants.defaultHeaders}');
      print('   Phone: $phoneNumber, OTP: $otp');
      
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
        return {
          ApiConstants.successKey: true,
          ApiConstants.messageKey: data[ApiConstants.messageKey],
        };
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
  static Future<Map<String, dynamic>> getBusinessProfile(int userId) async {
    try {
      final url = '${ApiConstants.baseURL}/api/business-profiles?user_id=$userId';
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
            ApiConstants.messageKey: 'No business profile found',
            'businessProfile': null,
          };
        }
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
    required int userId,
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
      final url = '${ApiConstants.baseURL}/api/business-profiles?user_id=$userId';
      
      // Build query parameters
      final queryParams = <String, String>{
        'user_id': userId.toString(),
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

      if (response.statusCode == 200) {
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
    required String userId,
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
      final url = '${ApiConstants.baseURL}${ApiConstants.customers}';
      
      // Build query parameters
      final queryParams = <String, String>{
        'user_id': userId,
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
  static Future<Map<String, dynamic>> getCustomers(String userId) async {
    try {
      final url = '${ApiConstants.baseURL}${ApiConstants.customers}?user_id=$userId';
      
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
              customers = (data['data'] as List)
                  .map((customerJson) => Customer.fromJson(customerJson))
                  .toList();
              print('✅ [DEBUG] Successfully parsed ${customers.length} customers from response');
            } else {
              print('⚠️ [DEBUG] No data field in response or data is not a list');
            }
          } catch (parseError) {
            print('⚠️ [DEBUG] Error parsing customers from response: $parseError');
            customers = [];
          }
          
          return {
            'success': true,
            ApiConstants.messageKey: data['message'] ?? 'Customers loaded successfully',
            'customers': customers,
          };
        } else {
          return {
            'success': false,
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
          errorMessage = errorData['detail'];
        } else if (errorData.containsKey('msg')) {
          errorMessage = errorData['msg'];
        }
        
        return {
          'success': false,
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
        'success': false,
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
      final url = '${ApiConstants.baseURL}/api/item-categories';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': '1', // TODO: Get actual user ID from auth service
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
  }) async {
    try {
      final url = '${ApiConstants.baseURL}${ApiConstants.items}';
      
      // Build form data fields matching the API structure
      final Map<String, String> formFields = {
        'user_id': userId,
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
      print('Headers: ${ApiConstants.defaultHeaders}');
      print('Form Fields: $formFields');

      // Create multipart request for form data
      final request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Add headers
      request.headers.addAll(ApiConstants.defaultHeaders);
      
      // Add form fields
      request.fields.addAll(formFields);
      
      // Add images if they exist
      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (int i = 0; i < imagePaths.length; i++) {
          final imagePath = imagePaths[i];
          if (imagePath.startsWith('/') || imagePath.contains('\\')) {
            final file = File(imagePath);
            if (await file.exists()) {
              final stream = http.ByteStream(file.openRead());
              final length = await file.length();
              final multipartFile = http.MultipartFile(
                'other_images[$i]',
                stream,
                length,
                filename: file.path.split('/').last,
              );
              request.files.add(multipartFile);
            }
          }
        }
      }

      print('📡 [DEBUG] Sending multipart request...');
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
  static Future<Map<String, dynamic>> getItems(String userId) async {
    try {
      final url = '${ApiConstants.baseURL}${ApiConstants.userItems}?user_id=$userId';
      
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
  }) async {
    try {
      final url = '${ApiConstants.baseURL}${ApiConstants.updateItem}';
      
      print('🔄 [DEBUG] Update Item Request:');
      print('URL: $url');
      print('Item ID: $itemId');
      print('Headers: ${ApiConstants.defaultHeaders}');
      
      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'item_id': itemId,
        'user_id': userId,
      };
      
      // Add optional fields only if they are not null
      if (itemName != null) requestBody['item_name'] = itemName;
      if (unit != null) requestBody['unit'] = unit;
      if (salesPriceAmount != null) requestBody['salesprice_amount'] = salesPriceAmount;
      if (salesPriceTax != null) requestBody['salesprice_tax'] = salesPriceTax;
      if (purchasePriceAmount != null) requestBody['purches_price_amount'] = purchasePriceAmount;
      if (purchasePriceTax != null) requestBody['purches_price_tax'] = purchasePriceTax;
      if (mrpPrice != null) requestBody['mrp_price'] = mrpPrice;
      if (gst != null) requestBody['gst'] = gst;
      if (openingStock != null) requestBody['opening_stock'] = openingStock;
      if (asOfDate != null) requestBody['as_of_date'] = asOfDate;
      if (lowAlertStatus != null) requestBody['low_alert_status'] = lowAlertStatus;
      if (lowAlertQuantity != null) requestBody['low_alert_quantity'] = lowAlertQuantity;
      if (itemCategoryId != null) requestBody['item_category_id'] = itemCategoryId;
      if (itemDescription != null) requestBody['item_description'] = itemDescription;
      if (showOnlineStore != null) requestBody['show_online_store'] = showOnlineStore;
      
      print('📤 [DEBUG] Request Body: $requestBody');
      print('📤 [DEBUG] JSON Body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConstants.defaultHeaders,
        body: jsonEncode(requestBody),
      );
      
      print('📥 [DEBUG] Update Item Response:');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
        final errorData = jsonDecode(response.body);
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
} 