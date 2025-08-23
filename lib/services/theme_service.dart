import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  // Default colors
  static const Color defaultPrimaryColor = Color(0xFF2E3085);
  static const Color defaultSecondaryColor = Color(0xFF4E4AA8);
  static const Color defaultAccentColor = Color(0xFF4CAF50);

  // Current colors
  Color _primaryColor = defaultPrimaryColor;
  Color _secondaryColor = defaultSecondaryColor;
  Color _accentColor = defaultAccentColor;

  // Getters
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get accentColor => _accentColor;

  // Available color palettes
  static const List<Color> primaryColors = [
    Color(0xFF2E3085), // Blue
    Color(0xFFD32F2F), // Red
    Color(0xFF388E3C), // Green
    Color(0xFFF57C00), // Orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFF1976D2), // Light Blue
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
  ];

  static const List<Color> secondaryColors = [
    Color(0xFF4E4AA8), // Blue
    Color(0xFFEF5350), // Red
    Color(0xFF66BB6A), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF42A5F5), // Light Blue
    Color(0xFFEC407A), // Pink
    Color(0xFF8D6E63), // Brown
  ];

  static const List<Color> accentColors = [
    Color(0xFF4CAF50), // Green
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF2196F3), // Blue
    Color(0xFFFFC107), // Amber
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF9800), // Orange
    Color(0xFF607D8B), // Blue Grey
  ];

  @override
  void initState() {
    _loadColors();
  }

  // Load saved colors from SharedPreferences
  Future<void> _loadColors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final primaryColorValue = prefs.getInt('primaryColor') ?? defaultPrimaryColor.value;
      final secondaryColorValue = prefs.getInt('secondaryColor') ?? defaultSecondaryColor.value;
      final accentColorValue = prefs.getInt('accentColor') ?? defaultAccentColor.value;

      _primaryColor = Color(primaryColorValue);
      _secondaryColor = Color(secondaryColorValue);
      _accentColor = Color(accentColorValue);
      
      notifyListeners();
    } catch (e) {
      print('Error loading colors: $e');
    }
  }

  // Save colors to SharedPreferences
  Future<void> _saveColors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('primaryColor', _primaryColor.value);
      await prefs.setInt('secondaryColor', _secondaryColor.value);
      await prefs.setInt('accentColor', _accentColor.value);
    } catch (e) {
      print('Error saving colors: $e');
    }
  }

  // Update primary color
  Future<void> updatePrimaryColor(Color color) async {
    _primaryColor = color;
    await _saveColors();
    notifyListeners();
  }

  // Update secondary color
  Future<void> updateSecondaryColor(Color color) async {
    _secondaryColor = color;
    await _saveColors();
    notifyListeners();
  }

  // Update accent color
  Future<void> updateAccentColor(Color color) async {
    _accentColor = color;
    await _saveColors();
    notifyListeners();
  }

  // Update all colors at once
  Future<void> updateColors({
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
  }) async {
    if (primaryColor != null) _primaryColor = primaryColor;
    if (secondaryColor != null) _secondaryColor = secondaryColor;
    if (accentColor != null) _accentColor = accentColor;
    
    await _saveColors();
    notifyListeners();
  }

  // Reset to default colors
  Future<void> resetToDefaults() async {
    _primaryColor = defaultPrimaryColor;
    _secondaryColor = defaultSecondaryColor;
    _accentColor = defaultAccentColor;
    
    await _saveColors();
    notifyListeners();
  }

  // Get color scheme for Material Design
  ColorScheme get colorScheme => ColorScheme.light(
    primary: _primaryColor,
    secondary: _secondaryColor,
    surface: Colors.white,
    background: const Color(0xFFFAFBFC),
  );

  // Get primary swatch for Material Design
  MaterialColor get primarySwatch => MaterialColor(_primaryColor.value, {
    50: _primaryColor.withOpacity(0.1),
    100: _primaryColor.withOpacity(0.2),
    200: _primaryColor.withOpacity(0.3),
    300: _primaryColor.withOpacity(0.4),
    400: _primaryColor.withOpacity(0.5),
    500: _primaryColor,
    600: _secondaryColor,
    700: _secondaryColor.withOpacity(0.8),
    800: _secondaryColor.withOpacity(0.6),
    900: _secondaryColor.withOpacity(0.4),
  });
}
