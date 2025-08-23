import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactService extends ChangeNotifier {
  static final ContactService _instance = ContactService._internal();
  factory ContactService() => _instance;
  ContactService._internal();

  // Default business profile information
  static const String defaultCompanyName = 'ACT T CONNECT';
  static const String defaultCompanyDescription = 'Professional Business Solutions';
  static const String defaultAddress1 = 'Block no 9, South Avenue, Shahpura';
  static const String defaultAddress2 = 'Bhopal, Madhya Pradesh 462039, India';
  static const String defaultPhone = '+91 9826000000';
  static const String defaultEmail = 'info@acttconnect.com';
  static const String defaultWebsite = 'www.acttconnect.com';
  static const String defaultGstNumber = '';
  static const String defaultPanNumber = '';

  // Current business profile
  String _companyName = defaultCompanyName;
  String _companyDescription = defaultCompanyDescription;
  String _address1 = defaultAddress1;
  String _address2 = defaultAddress2;
  String _phone = defaultPhone;
  String _email = defaultEmail;
  String _website = defaultWebsite;
  String _gstNumber = defaultGstNumber;
  String _panNumber = defaultPanNumber;

  // Getters
  String get companyName => _companyName;
  String get companyDescription => _companyDescription;
  String get address1 => _address1;
  String get address2 => _address2;
  String get phone => _phone;
  String get email => _email;
  String get website => _website;
  String get gstNumber => _gstNumber;
  String get panNumber => _panNumber;

  // Get full address
  String get fullAddress => '$_address1\n$_address2';

  // Get formatted contact info
  String get formattedContactInfo {
    List<String> contacts = [];
    if (_phone.isNotEmpty) contacts.add('Mobile: $_phone');
    if (_email.isNotEmpty) contacts.add('Email: $_email');
    if (_website.isNotEmpty) contacts.add('Website: $_website');
    return contacts.join(' | ');
  }

  // Quick phone number presets
  static const List<String> phonePresets = [
    '+91 98765 43210',
    '+91 9876543210',
    '+91 8765432109',
    '+91 7654321098',
    '+91 6543210987',
    '+44 20 7946 0958',
    '+61 2 9876 5432',
    '+86 10 1234 5678',
    '+81 3 1234 5678',
    '+1 555 123 4567',
  ];

  // Email presets
  static const List<String> emailPresets = [
    'info@company.com',
    'contact@business.com',
    'sales@enterprise.com',
    'support@organization.com',
    'admin@company.co.in',
  ];

  // Initialize service
  Future<void> initialize() async {
    await _loadContactInfo();
  }

  // Load saved contact information from SharedPreferences
  Future<void> _loadContactInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _companyName = prefs.getString('companyName') ?? defaultCompanyName;
      _companyDescription = prefs.getString('companyDescription') ?? defaultCompanyDescription;
      _address1 = prefs.getString('address1') ?? defaultAddress1;
      _address2 = prefs.getString('address2') ?? defaultAddress2;
      _phone = prefs.getString('phone') ?? defaultPhone;
      _email = prefs.getString('email') ?? defaultEmail;
      _website = prefs.getString('website') ?? defaultWebsite;
      _gstNumber = prefs.getString('gstNumber') ?? defaultGstNumber;
      _panNumber = prefs.getString('panNumber') ?? defaultPanNumber;
      
      notifyListeners();
    } catch (e) {
      print('Error loading contact info: $e');
    }
  }

  // Save contact information to SharedPreferences
  Future<void> _saveContactInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('companyName', _companyName);
      await prefs.setString('companyDescription', _companyDescription);
      await prefs.setString('address1', _address1);
      await prefs.setString('address2', _address2);
      await prefs.setString('phone', _phone);
      await prefs.setString('email', _email);
      await prefs.setString('website', _website);
      await prefs.setString('gstNumber', _gstNumber);
      await prefs.setString('panNumber', _panNumber);
    } catch (e) {
      print('Error saving contact info: $e');
    }
  }

  // Update company name
  Future<void> updateCompanyName(String name) async {
    _companyName = name.trim();
    await _saveContactInfo();
    notifyListeners();
  }

  // Update company description
  Future<void> updateCompanyDescription(String description) async {
    _companyDescription = description.trim();
    await _saveContactInfo();
    notifyListeners();
  }

  // Update address line 1
  Future<void> updateAddress1(String address) async {
    _address1 = address.trim();
    await _saveContactInfo();
    notifyListeners();
  }

  // Update address line 2
  Future<void> updateAddress2(String address) async {
    _address2 = address.trim();
    await _saveContactInfo();
    notifyListeners();
  }

  // Update phone number
  Future<void> updatePhone(String phone) async {
    _phone = phone.trim();
    await _saveContactInfo();
    notifyListeners();
  }

  // Update email
  Future<void> updateEmail(String email) async {
    _email = email.trim().toLowerCase();
    await _saveContactInfo();
    notifyListeners();
  }

  // Update website
  Future<void> updateWebsite(String website) async {
    _website = website.trim().toLowerCase();
    await _saveContactInfo();
    notifyListeners();
  }

  // Update GST number
  Future<void> updateGstNumber(String gstNumber) async {
    _gstNumber = gstNumber.trim().toUpperCase();
    await _saveContactInfo();
    notifyListeners();
  }

  // Update PAN number
  Future<void> updatePanNumber(String panNumber) async {
    _panNumber = panNumber.trim().toUpperCase();
    await _saveContactInfo();
    notifyListeners();
  }

  // Update all contact information at once
  Future<void> updateAllContactInfo({
    String? companyName,
    String? companyDescription,
    String? address1,
    String? address2,
    String? phone,
    String? email,
    String? website,
    String? gstNumber,
    String? panNumber,
  }) async {
    if (companyName != null) _companyName = companyName.trim();
    if (companyDescription != null) _companyDescription = companyDescription.trim();
    if (address1 != null) _address1 = address1.trim();
    if (address2 != null) _address2 = address2.trim();
    if (phone != null) _phone = phone.trim();
    if (email != null) _email = email.trim().toLowerCase();
    if (website != null) _website = website.trim().toLowerCase();
    if (gstNumber != null) _gstNumber = gstNumber.trim().toUpperCase();
    if (panNumber != null) _panNumber = panNumber.trim().toUpperCase();
    
    await _saveContactInfo();
    notifyListeners();
  }

  // Reset to default values
  Future<void> resetToDefaults() async {
    _companyName = defaultCompanyName;
    _companyDescription = defaultCompanyDescription;
    _address1 = defaultAddress1;
    _address2 = defaultAddress2;
    _phone = defaultPhone;
    _email = defaultEmail;
    _website = defaultWebsite;
    _gstNumber = defaultGstNumber;
    _panNumber = defaultPanNumber;
    
    await _saveContactInfo();
    notifyListeners();
  }

  // Validation methods
  bool isValidEmail(String email) {
    if (email.isEmpty) return true; // Allow empty email
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPhone(String phone) {
    if (phone.isEmpty) return true; // Allow empty phone
    return RegExp(r'^[\+]?[0-9\s\-\(\)]{10,}$').hasMatch(phone);
  }

  bool isValidWebsite(String website) {
    if (website.isEmpty) return true; // Allow empty website
    return RegExp(r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$').hasMatch(website);
  }

  bool isValidGstNumber(String gstNumber) {
    if (gstNumber.isEmpty) return true; // Allow empty GST
    return RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$').hasMatch(gstNumber);
  }

  bool isValidPanNumber(String panNumber) {
    if (panNumber.isEmpty) return true; // Allow empty PAN
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(panNumber);
  }

  // Get formatted display for invoices
  Map<String, String> getInvoiceDisplayInfo() {
    return {
      'companyName': _companyName,
      'companyDescription': _companyDescription,
      'address': fullAddress,
      'phone': _phone.isNotEmpty ? 'Mobile: $_phone' : '',
      'email': _email.isNotEmpty ? 'Email: $_email' : '',
      'website': _website.isNotEmpty ? 'Website: $_website' : '',
      'gstNumber': _gstNumber.isNotEmpty ? 'GST: $_gstNumber' : '',
      'panNumber': _panNumber.isNotEmpty ? 'PAN: $_panNumber' : '',
    };
  }
}
