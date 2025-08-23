import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscountSettingsService extends ChangeNotifier {
  static final DiscountSettingsService _instance = DiscountSettingsService._internal();
  factory DiscountSettingsService() => _instance;
  DiscountSettingsService._internal();

  static const String _discountTypeKey = 'discount_type';
  
  // Default to discount after tax (current behavior)
  String _discountType = 'after_tax';
  
  String get discountType => _discountType;
  
  bool get isDiscountAfterTax => _discountType == 'after_tax';
  bool get isDiscountBeforeTax => _discountType == 'before_tax';
  
  String get displayText {
    switch (_discountType) {
      case 'after_tax':
        return 'Discount After Tax';
      case 'before_tax':
        return 'Discount Before Tax';
      default:
        return 'Discount After Tax';
    }
  }
  
  String get description {
    switch (_discountType) {
      case 'after_tax':
        return 'Discount is applied after calculating tax on subtotal';
      case 'before_tax':
        return 'Discount is applied before calculating tax on subtotal';
      default:
        return 'Discount is applied after calculating tax on subtotal';
    }
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _discountType = prefs.getString(_discountTypeKey) ?? 'after_tax';
    notifyListeners();
  }

  Future<void> updateDiscountType(String type) async {
    if (type != 'after_tax' && type != 'before_tax') {
      throw ArgumentError('Invalid discount type. Must be "after_tax" or "before_tax"');
    }
    
    _discountType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_discountTypeKey, type);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _discountType = 'after_tax';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_discountTypeKey);
    notifyListeners();
  }

  // Helper method to calculate total based on discount type
  double calculateTotal({
    required double subtotal,
    required double discount,
    required double tax,
    double additionalCharges = 0,
    double roundoff = 0,
  }) {
    if (isDiscountBeforeTax) {
      // Discount before tax: (subtotal - discount) + tax + additional charges + roundoff
      return (subtotal - discount) + tax + additionalCharges + roundoff;
    } else {
      // Discount after tax: subtotal + tax - discount + additional charges + roundoff
      return subtotal + tax - discount + additionalCharges + roundoff;
    }
  }

  // Helper method to calculate tax based on discount type
  double calculateTax({
    required double subtotal,
    required double discount,
    required double taxRate,
  }) {
    if (isDiscountBeforeTax) {
      // Tax is calculated on (subtotal - discount)
      return (subtotal - discount) * taxRate / 100;
    } else {
      // Tax is calculated on subtotal (current behavior)
      return subtotal * taxRate / 100;
    }
  }
}
