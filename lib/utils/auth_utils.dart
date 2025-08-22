import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'dart:convert';

class AuthUtils {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userPhoneKey = 'userPhone';
  static const String _userNameKey = 'userName';
  static const String _userDataKey = 'userData';
  static const String _userIdKey = 'userId';

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('⚠️ [WARNING] Failed to check login status: $e');
      return false; // Assume not logged in on error
    }
  }

  // Set user as logged in with complete user data
  static Future<bool> setLoggedIn({
    required String phone,
    required String name,
    User? user,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userPhoneKey, phone);
      await prefs.setString(_userNameKey, name);
      
      // Store complete user data if provided
      if (user != null) {
        await prefs.setString(_userDataKey, jsonEncode(user.toJson()));
        await prefs.setInt(_userIdKey, user.id);
        print('✅ [DEBUG] Complete user data saved successfully');
      }
      
      print('✅ [DEBUG] User login state saved successfully');
      return true;
    } catch (e) {
      print('❌ [ERROR] Failed to save login state: $e');
      print('⚠️ [WARNING] Continuing without saving login state...');
      return false; // Return false if saving failed
    }
  }

  // Store complete user data
  static Future<bool> storeUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, jsonEncode(user.toJson()));
      await prefs.setInt(_userIdKey, user.id);
      print('✅ [DEBUG] User data updated successfully');
      return true;
    } catch (e) {
      print('❌ [ERROR] Failed to store user data: $e');
      return false;
    }
  }

  // Get current user data
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      
      if (userDataString != null && userDataString.isNotEmpty) {
        final userData = jsonDecode(userDataString);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('⚠️ [WARNING] Failed to get current user: $e');
      return null;
    }
  }

  // Get current user ID
  static Future<int?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_userIdKey);
    } catch (e) {
      print('⚠️ [WARNING] Failed to get current user ID: $e');
      return null;
    }
  }

  // Logout user
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.remove(_userPhoneKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_userIdKey);
      print('✅ [DEBUG] User logout successful');
      return true;
    } catch (e) {
      print('❌ [ERROR] Failed to logout: $e');
      return false;
    }
  }

  // Get user phone
  static Future<String?> getUserPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userPhoneKey);
    } catch (e) {
      print('⚠️ [WARNING] Failed to get user phone: $e');
      return null;
    }
  }

  // Get user name
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      print('⚠️ [WARNING] Failed to get user name: $e');
      return null;
    }
  }

  // Update user name
  static Future<bool> updateUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name);
      
      // Also update in user data if it exists
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString != null) {
        try {
          final userData = jsonDecode(userDataString);
          userData['name'] = name;
          await prefs.setString(_userDataKey, jsonEncode(userData));
        } catch (e) {
          print('⚠️ [WARNING] Failed to update name in user data: $e');
        }
      }
      
      return true;
    } catch (e) {
      print('❌ [ERROR] Failed to update user name: $e');
      return false;
    }
  }

  // Update user phone
  static Future<bool> updateUserPhone(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userPhoneKey, phone);
      
      // Also update in user data if it exists
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString != null) {
        try {
          final userData = jsonDecode(userDataString);
          userData['phone'] = phone;
          await prefs.setString(_userDataKey, jsonEncode(userData));
        } catch (e) {
          print('⚠️ [WARNING] Failed to update phone in user data: $e');
        }
      }
      
      return true;
    } catch (e) {
      print('❌ [ERROR] Failed to update user phone: $e');
      return false;
    }
  }

  // Check if user data exists
  static Future<bool> hasUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      return userDataString != null && userDataString.isNotEmpty;
    } catch (e) {
      print('⚠️ [WARNING] Failed to check user data: $e');
      return false;
    }
  }
} 