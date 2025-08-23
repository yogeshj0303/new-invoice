import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceNumberingService extends ChangeNotifier {
  static final InvoiceNumberingService _instance = InvoiceNumberingService._internal();
  factory InvoiceNumberingService() => _instance;
  InvoiceNumberingService._internal();

  // Default invoice number prefix
  static const String defaultPrefix = 'INV';
  static const String defaultSeparator = '-';
  static const int defaultStartNumber = 1;
  static const int defaultPadding = 6;

  String _prefix = defaultPrefix;
  String _separator = defaultSeparator;
  int _startNumber = defaultStartNumber;
  int _padding = defaultPadding;
  int _currentNumber = defaultStartNumber;

  // Getters
  String get prefix => _prefix;
  String get separator => _separator;
  int get startNumber => _startNumber;
  int get padding => _padding;
  int get currentNumber => _currentNumber;

  // Get formatted invoice number
  String get formattedInvoiceNumber {
    return '$_prefix$_separator${_currentNumber.toString().padLeft(_padding, '0')}';
  }

  // Get next invoice number (without incrementing - for preview)
  String get nextInvoiceNumber {
    return '$_prefix$_separator${_currentNumber.toString().padLeft(_padding, '0')}';
  }

  // Get next invoice number (increments counter)
  String getNextInvoiceNumber() {
    final number = _currentNumber;
    _currentNumber++;
    _saveCurrentNumber();
    return '$_prefix$_separator${number.toString().padLeft(_padding, '0')}';
  }

  // Get invoice number with custom number
  String getInvoiceNumberWithCustomNumber(int customNumber) {
    return '$_prefix$_separator${customNumber.toString().padLeft(_padding, '0')}';
  }

  // Update prefix
  Future<void> updatePrefix(String newPrefix) async {
    if (newPrefix.trim().isNotEmpty) {
      _prefix = newPrefix.trim().toUpperCase();
      await _saveSettings();
      notifyListeners();
    }
  }

  // Update separator
  Future<void> updateSeparator(String newSeparator) async {
    if (newSeparator.trim().isNotEmpty) {
      _separator = newSeparator.trim();
      await _saveSettings();
      notifyListeners();
    }
  }

  // Update start number
  Future<void> updateStartNumber(int newStartNumber) async {
    if (newStartNumber > 0) {
      _startNumber = newStartNumber;
      _currentNumber = newStartNumber;
      await _saveSettings();
      await _saveCurrentNumber();
      notifyListeners();
    }
  }

  // Update padding
  Future<void> updatePadding(int newPadding) async {
    if (newPadding >= 1 && newPadding <= 10) {
      _padding = newPadding;
      await _saveSettings();
      notifyListeners();
    }
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    _prefix = defaultPrefix;
    _separator = defaultSeparator;
    _startNumber = defaultStartNumber;
    _padding = defaultPadding;
    _currentNumber = defaultStartNumber;
    
    await _saveSettings();
    await _saveCurrentNumber();
    notifyListeners();
  }

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefix = prefs.getString('invoice_prefix') ?? defaultPrefix;
      _separator = prefs.getString('invoice_separator') ?? defaultSeparator;
      _startNumber = prefs.getInt('invoice_start_number') ?? defaultStartNumber;
      _padding = prefs.getInt('invoice_padding') ?? defaultPadding;
      _currentNumber = prefs.getInt('invoice_current_number') ?? defaultStartNumber;
      notifyListeners();
    } catch (e) {
      print('Error loading invoice numbering settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('invoice_prefix', _prefix);
      await prefs.setString('invoice_separator', _separator);
      await prefs.setInt('invoice_start_number', _startNumber);
      await prefs.setInt('invoice_padding', _padding);
    } catch (e) {
      print('Error saving invoice numbering settings: $e');
    }
  }

  // Save current number to SharedPreferences
  Future<void> _saveCurrentNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('invoice_current_number', _currentNumber);
    } catch (e) {
      print('Error saving current invoice number: $e');
    }
  }

  // Initialize the service
  Future<void> initialize() async {
    await loadSettings();
  }
}
