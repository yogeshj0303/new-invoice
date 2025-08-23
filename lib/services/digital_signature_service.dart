import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DigitalSignatureService extends ChangeNotifier {
  static final DigitalSignatureService _instance = DigitalSignatureService._internal();
  factory DigitalSignatureService() => _instance;
  DigitalSignatureService._internal();

  static const String _signatureKey = 'digital_signature';
  static const String _signatureTypeKey = 'signature_type';

  Uint8List? _signature;
  String _signatureType = 'none'; // 'none', 'hand', 'camera', 'gallery'

  Uint8List? get signature => _signature;
  String get signatureType => _signatureType;
  bool get hasSignature => _signature != null;

  String get displayText {
    switch (_signatureType) {
      case 'hand':
        return 'Hand-drawn Signature';
      case 'camera':
        return 'Camera Import';
      case 'gallery':
        return 'Gallery Import';
      default:
        return 'No Signature';
    }
  }

  String get description {
    switch (_signatureType) {
      case 'hand':
        return 'Signature created by hand drawing';
      case 'camera':
        return 'Signature imported from camera';
      case 'gallery':
        return 'Signature imported from gallery';
      default:
        return 'No digital signature added';
    }
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final signatureData = prefs.getString(_signatureKey);
    final signatureTypeData = prefs.getString(_signatureTypeKey);
    
    if (signatureData != null) {
      _signature = base64Decode(signatureData);
    }
    if (signatureTypeData != null) {
      _signatureType = signatureTypeData;
    }
  }

  Future<void> updateSignature(Uint8List signature, String type) async {
    _signature = signature;
    _signatureType = type;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_signatureKey, base64Encode(signature));
    await prefs.setString(_signatureTypeKey, type);
    
    notifyListeners();
  }

  Future<void> removeSignature() async {
    _signature = null;
    _signatureType = 'none';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_signatureKey);
    await prefs.remove(_signatureTypeKey);
    
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    await removeSignature();
  }
}

class DigitalSignatureConstants {
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color borderColor = Color(0xFFE9ECEF);
}
