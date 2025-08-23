import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static FirebaseMessaging? _messaging;
  static String? _fcmToken;

  // Initialize Firebase and get FCM token
  static Future<String?> initializeAndGetToken() async {
    try {
      // Initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Get FCM instance
      _messaging = FirebaseMessaging.instance;

      // Request permission for notifications
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('🔔 [FCM] Permission granted: ${settings.authorizationStatus}');

      // Get FCM token
      _fcmToken = await _messaging!.getToken();
      
      if (_fcmToken != null) {
        print('🔔 [FCM] Token generated: $_fcmToken');
      } else {
        print('⚠️ [FCM] Failed to get FCM token');
      }

      // Listen for token refresh
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('🔔 [FCM] Token refreshed: $_fcmToken');
      });

      return _fcmToken;
    } catch (e) {
      print('❌ [FCM] Error initializing FCM: $e');
      print('   This might be expected in development or if Firebase is not configured');
      return null;
    }
  }

  // Get current FCM token
  static String? getCurrentToken() {
    return _fcmToken;
  }

  // Refresh FCM token
  static Future<String?> refreshToken() async {
    try {
      if (_messaging != null) {
        _fcmToken = await _messaging!.getToken();
        print('🔔 [FCM] Token refreshed: $_fcmToken');
        return _fcmToken;
      }
      return null;
    } catch (e) {
      print('❌ [FCM] Error refreshing token: $e');
      return null;
    }
  }

  // Generate a mock FCM token for testing when Firebase is not available
  static String _generateMockToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final token = StringBuffer();
    
    for (int i = 0; i < 32; i++) {
      token.write(chars[random % chars.length]);
    }
    
    return 'mock_fcm_token_${token.toString()}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Get FCM token with fallback to mock token for testing
  static Future<String> getTokenWithFallback() async {
    String? token = await initializeAndGetToken();
    if (token == null || token.isEmpty) {
      token = _generateMockToken();
      print('🔔 [FCM] Using mock token for testing: $token');
    }
    return token;
  }
}
