import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/business_profile.dart';
import 'dart:io'; // Added for File

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
} 