import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsService extends ChangeNotifier {
  static final TermsService _instance = TermsService._internal();
  factory TermsService() => _instance;
  TermsService._internal();

  // Default terms and conditions
  static const List<String> defaultTerms = [
    '1. Goods once sold will not be taken back or exchanged',
    '2. All disputes are subject to local jurisdiction only',
    '3. Payment is due within 30 days of invoice date',
  ];

  // Current terms and conditions
  List<String> _terms = List.from(defaultTerms);

  // Getters
  List<String> get terms => List.unmodifiable(_terms);
  String get formattedTerms => _terms.join('\n');

  // Quick terms presets
  static const List<List<String>> termsPresets = [
    [
      '1. Goods once sold will not be taken back or exchanged',
      '2. All disputes are subject to local jurisdiction only',
      '3. Payment is due within 30 days of invoice date',
      '4. Late payments may incur additional charges',
    ],
    [
      '1. All sales are final - no returns or exchanges',
      '2. Payment terms: Net 30 days',
      '3. 2% late fee applies after 30 days',
      '4. Warranty: 90 days from purchase date',
      '5. Shipping charges are additional',
    ],
    [
      '1. Payment due upon receipt',
      '2. Cash, check, or credit card accepted',
      '3. 1.5% monthly interest on overdue accounts',
      '4. Returns accepted within 14 days',
      '5. Restocking fee: 15% of item value',
    ],
    [
      '1. Net payment terms: 15 days',
      '2. 3% discount for payment within 7 days',
      '3. All prices exclude taxes',
      '4. Delivery charges apply',
      '5. Quality guarantee: 30 days',
    ],
  ];

  // Initialize service
  Future<void> initialize() async {
    await _loadTerms();
  }

  // Load saved terms from SharedPreferences
  Future<void> _loadTerms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final termsList = prefs.getStringList('terms') ?? defaultTerms;
      _terms = termsList;
      notifyListeners();
    } catch (e) {
      print('Error loading terms: $e');
      _terms = List.from(defaultTerms);
    }
  }

  // Save terms to SharedPreferences
  Future<void> _saveTerms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('terms', _terms);
    } catch (e) {
      print('Error saving terms: $e');
    }
  }

  // Update terms
  Future<void> updateTerms(List<String> newTerms) async {
    _terms = newTerms.where((term) => term.trim().isNotEmpty).toList();
    await _saveTerms();
    notifyListeners();
  }

  // Add a new term
  Future<void> addTerm(String term) async {
    if (term.trim().isNotEmpty) {
      _terms.add(term.trim());
      await _saveTerms();
      notifyListeners();
    }
  }

  // Update a specific term at index
  Future<void> updateTermAt(int index, String newTerm) async {
    if (index >= 0 && index < _terms.length && newTerm.trim().isNotEmpty) {
      _terms[index] = newTerm.trim();
      await _saveTerms();
      notifyListeners();
    }
  }

  // Remove a term at index
  Future<void> removeTermAt(int index) async {
    if (index >= 0 && index < _terms.length) {
      _terms.removeAt(index);
      await _saveTerms();
      notifyListeners();
    }
  }

  // Reset to default terms
  Future<void> resetToDefaults() async {
    _terms = List.from(defaultTerms);
    await _saveTerms();
    notifyListeners();
  }

  // Get terms for invoice display
  List<String> getInvoiceTerms() {
    return _terms.where((term) => term.trim().isNotEmpty).toList();
  }

  // Check if terms are empty
  bool get isEmpty => _terms.isEmpty || _terms.every((term) => term.trim().isEmpty);

  // Get terms count
  int get count => _terms.where((term) => term.trim().isNotEmpty).length;
}
