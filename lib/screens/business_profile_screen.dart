import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../models/business_profile.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../utils/auth_utils.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen>
    with SingleTickerProviderStateMixin {
  // Theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);

  // Tab controller
  late TabController _tabController;

  // Signature controller
  late SignatureController _signatureController;

  // Business profile data
  BusinessProfile? _businessProfile;
  bool _isLoadingProfile = false;

  // Form controllers
  final _basicFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController(text: 'Business Name');
  final _businessIdController = TextEditingController();
  final _gstinController = TextEditingController(text: 'GSTIN123456789');
  final _phone1Controller = TextEditingController(text: '+91 98765 43210');
  final _phone2Controller = TextEditingController();
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _businessEmailController = TextEditingController();
  final _businessAddressController = TextEditingController(
    text: '123 Business Street, Andheri West',
  );
  final _pincodeController = TextEditingController(text: '400001');
  final _businessDescriptionController = TextEditingController(
    text: 'We provide high-quality services to our customers.',
  );
  final _ownerNameController = TextEditingController(text: 'John Doe');
  final _gstNumberController = TextEditingController(text: '22AAAAA0000A1Z5');
  final _panNumberController = TextEditingController(text: 'AAAAA0000A');
  final _websiteController = TextEditingController(text: 'www.business.com');

  // Dropdown values
  String? _selectedState;
  String? _selectedBusinessType;
  String? _selectedBusinessCategory;

  // Business signature
  bool _hasBusinessSignature = false;
  String? _businessSignaturePath;
  late SignatureController _businessSignatureController;

  bool _isLoading = false;
  bool _hasSignature = false;
  String? _signaturePath;
  
  // Track if any changes were made
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Add listener to update IndexedStack when tab changes
    _tabController.addListener(() {
      setState(() {});
    });
    
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: primaryColor,
      exportBackgroundColor: Colors.white,
    );
    _businessSignatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: primaryColor,
      exportBackgroundColor: Colors.white,
    );
    
    // Load business profile data
    _loadBusinessProfile();
    
    // Add listeners to track changes
    _addChangeListeners();
  }

  // Add listeners to track changes in form fields
  void _addChangeListeners() {
    _businessNameController.addListener(_onFieldChanged);
    _gstinController.addListener(_onFieldChanged);
    _phone1Controller.addListener(_onFieldChanged);
    _phone2Controller.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _businessEmailController.addListener(_onFieldChanged);
    _businessAddressController.addListener(_onFieldChanged);
    _pincodeController.addListener(_onFieldChanged);
    _businessDescriptionController.addListener(_onFieldChanged);
    _websiteController.addListener(_onFieldChanged);
  }
  
  // Called when any form field changes
  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }
  
  // Show dialog when user tries to leave with unsaved changes
  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('You have unsaved changes. Are you sure you want to leave without saving?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Don't navigate back, stay on the screen
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(false); // Go back without saving
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  // Load business profile from API
  Future<void> _loadBusinessProfile() async {
    if (_isLoadingProfile) return;

    setState(() {
      _isLoadingProfile = true;
    });

    try {
      // Get actual user ID from auth service
      final userId = await AuthUtils.getCurrentUserId();
      if (userId == null) {
        setState(() {
          _isLoadingProfile = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User not authenticated. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final result = await ApiService.getBusinessProfile(userId);
      
      if (result['success'] == true && result['businessProfile'] != null) {
        setState(() {
          _businessProfile = result['businessProfile'];
        });
        
        // Populate form fields with loaded data
        _populateFormFields();
        
        // Ensure forms are built by triggering a rebuild
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      } else if (result['notFound'] == true) {
        // Handle 404 - show form with empty fields for creating new profile
        setState(() {
          _businessProfile = null;
        });
        
        // Clear form fields to show empty form
        _clearFormFields();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Business profile not found. You can create one below.'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        setState(() {
          _businessProfile = null;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'No business profile found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _businessProfile = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading business profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  // Refresh business profile after update
  Future<void> _refreshBusinessProfile() async {
    print('🔄 [DEBUG] Refreshing business profile...');
    await _loadBusinessProfile();
  }

  // Reset dropdown values if they're invalid
  void _resetInvalidDropdownValues() {
    // Define the valid values for each dropdown
    final validStates = [
      'Andhra Pradesh',
      'Arunachal Pradesh',
      'Assam',
      'Bihar',
      'Chhattisgarh',
      'Goa',
      'Gujarat',
      'Haryana',
      'Himachal Pradesh',
      'Jharkhand',
      'Karnataka',
      'Kerala',
      'Madhya Pradesh',
      'Maharashtra',
      'Manipur',
      'Meghalaya',
      'Mizoram',
      'Nagaland',
      'Odisha',
      'Punjab',
      'Rajasthan',
      'Sikkim',
      'Tamil Nadu',
      'Telangana',
      'Tripura',
      'Uttar Pradesh',
      'Uttarakhand',
      'West Bengal',
      'Delhi',
      'Jammu and Kashmir',
      'Ladakh',
      'Chandigarh',
      'Dadra and Nagar Haveli and Daman and Diu',
      'Lakshadweep',
      'Puducherry',
      'Andaman and Nicobar Islands',
    ];

    final validBusinessTypes = [
      'New Business',
      'Sole Proprietorship',
      'Partnership',
      'Limited Liability Partnership (LLP)',
      'Private Limited Company',
      'Public Limited Company',
      'One Person Company (OPC)',
      'Cooperative Society',
      'Trust',
      'Society',
      'Other',
    ];

    final validBusinessCategories = [
      'New Business',
      'Manufacturing',
      'Trading',
      'Services',
      'Retail',
      'Wholesale',
      'E-commerce',
      'Food & Beverage',
      'Healthcare',
      'Education',
      'Technology',
      'Finance',
      'Real Estate',
      'Transportation',
      'Entertainment',
      'Agriculture',
      'Construction',
      'Consulting',
      'Other',
    ];

    // Reset invalid values
    if (_selectedState != null && !validStates.contains(_selectedState)) {
      print('⚠️ [DEBUG] Resetting invalid state value: "$_selectedState"');
      _selectedState = null;
    }
    
    if (_selectedBusinessType != null && !validBusinessTypes.contains(_selectedBusinessType)) {
      print('⚠️ [DEBUG] Resetting invalid business type value: "$_selectedBusinessType"');
      _selectedBusinessType = null;
    }
    
    if (_selectedBusinessCategory != null && !validBusinessCategories.contains(_selectedBusinessCategory)) {
      print('⚠️ [DEBUG] Resetting invalid business category value: "$_selectedBusinessCategory"');
      _selectedBusinessCategory = null;
    }
  }

  // Populate form fields with loaded business profile data
  void _populateFormFields() {
    if (_businessProfile == null) return;

    print('🔍 [DEBUG] Populating form fields with business profile:');
    print('   Business Name: ${_businessProfile!.businessName}');
    print('   Business State: ${_businessProfile!.businessState}');
    print('   Business Type: ${_businessProfile!.businessType}');
    print('   Business Category: ${_businessProfile!.businessCategory}');

    // Reset any invalid dropdown values first
    _resetInvalidDropdownValues();

    // Basic details - use actual business name from API
    _businessNameController.text = _businessProfile!.businessName;
    _businessIdController.text = _businessProfile!.businessId;
    _gstinController.text = _businessProfile!.gstNo;
    _phone1Controller.text = _businessProfile!.phoneNoFirst;
    _phone2Controller.text = _businessProfile!.phoneNoSecond;
    _emailController.text = _businessProfile!.email;
    _businessEmailController.text = _businessProfile!.businessEmail;
    _businessAddressController.text = _businessProfile!.businessAddress;
    _pincodeController.text = _businessProfile!.pincode;
    _businessDescriptionController.text = _businessProfile!.businessDesc;
    _websiteController.text = _businessProfile!.website;

    print('✅ [DEBUG] Form fields populated:');
    print('   Business Name: ${_businessNameController.text}');
    print('   Business ID: ${_businessIdController.text}');
    print('   GST Number: ${_gstinController.text}');
    print('   Primary Phone: ${_phone1Controller.text}');
    print('   Secondary Phone: ${_phone2Controller.text}');
    print('   Email: ${_emailController.text}');
    print('   Business Email: ${_businessEmailController.text}');
    print('   Address: ${_businessAddressController.text}');
    print('   Pincode: ${_pincodeController.text}');
    print('   Description: ${_businessDescriptionController.text}');
    print('   Website: ${_websiteController.text}');

    // Business details - map API values to dropdown options
    final mappedState = _mapStateValue(_businessProfile!.businessState);
    final mappedBusinessType = _mapBusinessTypeValue(_businessProfile!.businessType);
    final mappedBusinessCategory = _mapBusinessCategoryValue(_businessProfile!.businessCategory);

    // Only set dropdown values if they are not null and the business profile is loaded
    if (mappedState != null && _businessProfile != null) {
      _selectedState = mappedState;
      print('✅ [DEBUG] Set selected state to: $_selectedState');
    } else {
      print('⚠️ [DEBUG] Could not set selected state. Mapped value: $mappedState, Business profile: ${_businessProfile != null}');
    }
    
    if (mappedBusinessType != null && _businessProfile != null) {
      _selectedBusinessType = mappedBusinessType;
      print('✅ [DEBUG] Set selected business type to: $_selectedBusinessType');
    } else {
      print('⚠️ [DEBUG] Could not set selected business type. Mapped value: $mappedBusinessType, Business profile: ${_businessProfile != null}');
    }
    
    if (mappedBusinessCategory != null && _businessProfile != null) {
      _selectedBusinessCategory = mappedBusinessCategory;
      print('✅ [DEBUG] Set selected business category to: $_selectedBusinessCategory');
    } else {
      print('⚠️ [DEBUG] Could not set selected business category. Mapped value: $mappedBusinessCategory, Business profile: ${_businessProfile != null}');
    }

         print('🔍 [DEBUG] Final dropdown values:');
     print('   Selected State: $_selectedState');
     print('   Selected Business Type: $_selectedBusinessType');
     print('   Selected Business Category: $_selectedBusinessCategory');
     
     // Debug signature information
     print('🔍 [DEBUG] Signature information from API:');
     print('   Digital Signature: ${_businessProfile!.digitalSign}');
     print('   Business Signature: ${_businessProfile!.businessSignature}');
     print('   Has Digital Signature: $_hasSignature');
     print('   Has Business Signature: $_hasBusinessSignature');
     print('   Digital Signature Path: $_signaturePath');
     print('   Business Signature Path: $_businessSignaturePath');

         // Check if signatures exist and set their paths
     if (_businessProfile!.digitalSign != null && _businessProfile!.digitalSign!.isNotEmpty) {
       _hasSignature = true;
       _signaturePath = _businessProfile!.digitalSign;
       print('✅ [DEBUG] Digital signature path set: $_signaturePath');
     }
     if (_businessProfile!.businessSignature != null && _businessProfile!.businessSignature!.isNotEmpty) {
       _hasBusinessSignature = true;
       _businessSignaturePath = _businessProfile!.businessSignature;
       print('✅ [DEBUG] Business signature path set: $_businessSignaturePath');
     }

         setState(() {
       _hasChanges = false; // Reset changes flag when loading existing profile
     });
     // Debug signature state after populating form fields
     _debugSignatureState();
  }

  // Clear form fields to show empty form for creating new profile
  void _clearFormFields() {
    print('🔍 [DEBUG] Clearing form fields for new profile creation');
    
    // Clear all text controllers
    _businessNameController.clear();
    _businessIdController.clear();
    _gstinController.clear();
    _phone1Controller.clear();
    _phone2Controller.clear();
    _emailController.clear();
    _businessEmailController.clear();
    _businessAddressController.clear();
    _pincodeController.clear();
    _businessDescriptionController.clear();
    _websiteController.clear();
    
    // Reset dropdown selections
    _selectedState = null;
    _selectedBusinessType = null;
    _selectedBusinessCategory = null;
    
    // Reset signature states
    _hasSignature = false;
    _hasBusinessSignature = false;
    _signaturePath = null;
    _businessSignaturePath = null;
    
         setState(() {
       _hasChanges = false; // Reset changes flag when clearing fields
     });
     print('✅ [DEBUG] Form fields cleared successfully');
  }

  // Map API state values to dropdown options
  String? _mapStateValue(String apiState) {
    print('🔍 [DEBUG] Mapping state value: "$apiState"');
    final stateMap = {
      'mp': 'Madhya Pradesh',
      'ap': 'Andhra Pradesh',
      'ar': 'Arunachal Pradesh',
      'as': 'Assam',
      'br': 'Bihar',
      'ct': 'Chhattisgarh',
      'ga': 'Goa',
      'gj': 'Gujarat',
      'hr': 'Haryana',
      'hp': 'Himachal Pradesh',
      'jh': 'Jharkhand',
      'ka': 'Karnataka',
      'kl': 'Kerala',
      'mh': 'Maharashtra',
      'mn': 'Manipur',
      'ml': 'Meghalaya',
      'mz': 'Mizoram',
      'nl': 'Nagaland',
      'or': 'Odisha',
      'pb': 'Punjab',
      'rj': 'Rajasthan',
      'sk': 'Sikkim',
      'tn': 'Tamil Nadu',
      'ts': 'Telangana',
      'tr': 'Tripura',
      'up': 'Uttar Pradesh',
      'ut': 'Uttarakhand',
      'wb': 'West Bengal',
      'dl': 'Delhi',
      'jk': 'Jammu and Kashmir',
      'la': 'Ladakh',
      'ch': 'Chandigarh',
      'dn': 'Dadra and Nagar Haveli and Daman and Diu',
      'ld': 'Lakshadweep',
      'py': 'Puducherry',
      'an': 'Andaman and Nicobar Islands',
    };
    final mappedValue = stateMap[apiState.toLowerCase()];
    print('🔍 [DEBUG] Mapped state "$apiState" to "$mappedValue"');
    return mappedValue;
  }

  // Map API business type values to dropdown options
  String? _mapBusinessTypeValue(String apiType) {
    print('🔍 [DEBUG] Mapping business type value: "$apiType"');
    final typeMap = {
      'new': 'New Business',
      'sole_proprietorship': 'Sole Proprietorship',
      'partnership': 'Partnership',
      'llp': 'Limited Liability Partnership (LLP)',
      'private_limited': 'Private Limited Company',
      'public_limited': 'Public Limited Company',
      'opc': 'One Person Company (OPC)',
      'cooperative': 'Cooperative Society',
      'trust': 'Trust',
      'society': 'Society',
      'other': 'Other',
    };
    final mappedValue = typeMap[apiType.toLowerCase()];
    print('🔍 [DEBUG] Mapped business type "$apiType" to "$mappedValue"');
    return mappedValue;
  }

  // Map API business category values to dropdown options
  String? _mapBusinessCategoryValue(String apiCategory) {
    print('🔍 [DEBUG] Mapping business category value: "$apiCategory"');
    final categoryMap = {
      'new': 'New Business',
      'manufacturing': 'Manufacturing',
      'trading': 'Trading',
      'services': 'Services',
      'retail': 'Retail',
      'wholesale': 'Wholesale',
      'ecommerce': 'E-commerce',
      'food_beverage': 'Food & Beverage',
      'healthcare': 'Healthcare',
      'education': 'Education',
      'technology': 'Technology',
      'finance': 'Finance',
      'real_estate': 'Real Estate',
      'transportation': 'Transportation',
      'entertainment': 'Entertainment',
      'agriculture': 'Agriculture',
      'construction': 'Construction',
      'consulting': 'Consulting',
      'other': 'Other',
    };
    final mappedValue = categoryMap[apiCategory.toLowerCase()];
    print('🔍 [DEBUG] Mapped business category "$apiCategory" to "$mappedValue"');
    return mappedValue;
  }

  // Validate dropdown value exists in items list
  String? _validateDropdownValue(String? value, List<String> items) {
    if (value == null) return null;
    if (items.contains(value)) {
      return value;
    }
    print('⚠️ [WARNING] Dropdown value "$value" not found in items list: $items');
    return null;
  }

  // Ensure dropdown items are unique
  List<String> _ensureUniqueItems(List<String> items) {
    final uniqueItems = <String>[];
    for (final item in items) {
      if (!uniqueItems.contains(item)) {
        uniqueItems.add(item);
      } else {
        print('⚠️ [WARNING] Duplicate dropdown item found: "$item"');
      }
    }
    return uniqueItems;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signatureController.dispose();
    _businessSignatureController.dispose();
    _businessNameController.dispose();
    _businessIdController.dispose();
    _gstinController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _emailController.dispose();
    _businessEmailController.dispose();
    _businessAddressController.dispose();
    _pincodeController.dispose();
    _businessDescriptionController.dispose();
    _ownerNameController.dispose();
    _gstNumberController.dispose();
    _panNumberController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If there are unsaved changes, show confirmation dialog
        if (_hasChanges) {
          _showUnsavedChangesDialog();
          return false; // Don't pop yet
        }
        return true; // Allow pop
      },
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(),
          body: _isLoadingProfile 
            ? _buildLoadingBody() 
            : _buildBody(), // Always show the form body, whether profile exists or not
        ),
      ),
    );
  }

  Widget _buildLoadingBody() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Loading business profile...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1A1A1A),
            size: 18,
          ),
          onPressed: () {
            // If there are unsaved changes, show confirmation dialog
            if (_hasChanges) {
              _showUnsavedChangesDialog();
            } else {
              // No changes, just go back
              Navigator.of(context).pop(false);
            }
          },
          padding: const EdgeInsets.all(8),
        ),
      ),
      title: Text(
        _businessProfile == null ? 'Create Business Profile' : 'Business Profile',
        style: TextStyle(
          color: const Color(0xFF1A1A1A),
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.openSans().fontFamily,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _isLoadingProfile ? null : _loadBusinessProfile,
          icon: _isLoadingProfile
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                )
              : const Icon(Icons.refresh, color: primaryColor, size: 24),
        ),
        IconButton(
          onPressed: _isLoading ? null : _saveProfile,
          icon:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                  : const Icon(Icons.save, color: primaryColor, size: 24),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          // Show header message when creating new profile
          if (_businessProfile == null) _buildCreateProfileHeader(),
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: _tabController.index,
              children: [
                _buildBasicDetailsTab(),
                _buildBusinessDetailsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Your Business Profile',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in the details below to set up your business profile. You can edit this information later.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 12),
                  SizedBox(width: 4),
                  Text('Basic',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_outlined, size: 12),
                  SizedBox(width: 4),
                  Text('Business',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicDetailsTab() {
    return Form(
      key: _basicFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBusinessBasicFields(),
            const SizedBox(height: 12),
            _buildContactFields(),
            const SizedBox(height: 12),
            _buildAddressFields(),
            const SizedBox(height: 12),
            _buildSignatureSection(),
            const SizedBox(height: 80), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessDetailsTab() {
    return Form(
      key: _businessFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBusinessFields(),
            const SizedBox(height: 12),
            _buildBusinessSignatureSection(),
            const SizedBox(height: 80), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessBasicFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _businessNameController,
          hint: _businessProfile == null ? 'Enter your business name (e.g., ABC Company)' : 'Enter business name',
          label: 'Business Name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Business name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Business ID',
          controller: _businessIdController,
          hint: _businessProfile == null ? 'Will be auto-generated after creation' : 'Business ID (Auto-generated)',
          enabled: false,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'GSTIN',
          controller: _gstinController,
          hint: _businessProfile == null ? 'Enter your 15-digit GSTIN (e.g., 22AAAAA0000A1Z5)' : 'Enter GSTIN number',
          textCapitalization: TextCapitalization.characters,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'GSTIN is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Primary Phone Number',
          controller: _phone1Controller,
          hint: _businessProfile == null ? 'Enter your primary business phone number' : 'Enter primary phone number',
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Primary phone number is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Secondary Phone Number (Optional)',
          controller: _phone2Controller,
          hint: _businessProfile == null ? 'Enter secondary phone number if available' : 'Enter secondary phone number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Email Address',
          controller: _emailController,
          hint: _businessProfile == null ? 'Enter your business email address' : 'Enter email address',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Business Email (Optional)',
          controller: _businessEmailController,
          hint: _businessProfile == null ? 'Enter separate business email if different' : 'Enter business email address',
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Business Address',
          controller: _businessAddressController,
          hint: _businessProfile == null ? 'Enter your complete business address' : 'Enter complete business address',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Business address is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Pincode',
          controller: _pincodeController,
          hint: _businessProfile == null ? 'Enter 6-digit pincode' : 'Enter pincode',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pincode is required';
            }
            if (value.length != 6) {
              return 'Pincode must be 6 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Business Description',
          controller: _businessDescriptionController,
          hint: _businessProfile == null ? 'Describe what your business does (e.g., We provide IT services...)' : 'Describe your business activities',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Business description is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    // Debug signature state when building the section
    _debugSignatureState();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Digital Signature', Icons.draw),
        if (_businessProfile == null) ...[
          const SizedBox(height: 8),
          Text(
            'Add your digital signature for invoices and documents',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child:
              _hasSignature
                  ? Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Your Signature',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: _signaturePath != null && _signaturePath!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: _buildSignatureImage(_signaturePath!),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Signature added successfully',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.draw, color: Colors.grey[400], size: 32),
                      const SizedBox(height: 8),
                      Text(
                        _businessProfile == null 
                          ? 'Create or upload your digital signature'
                          : 'Create or upload your signature',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
        ),
        const SizedBox(height: 12),
        _hasSignature
            ? Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showSignatureDialog();
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Signature'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _removeSignature();
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Remove'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            )
            : Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showSignatureDialog();
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(
                      'Create Signature',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _uploadSignature();
                    },
                    icon: const Icon(Icons.upload, size: 18),
                    label: Text(
                      'Upload Signature',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      ],
    );
  }

  void _showSignatureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.maxFinite,
            height: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Create Signature',
                        style: TextStyle(
                          color: const Color(0xFF1A1A1A), 
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Signature(
                      controller: _signatureController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Clear signature
                          _signatureController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.grey[700],
                        ),
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Save signature
                          try {
                            final signature =
                                await _signatureController.toPngBytes();
                            if (signature != null) {
                              // Save signature to temporary file
                              final tempDir = Directory.systemTemp;
                              final tempFile = File('${tempDir.path}/digital_signature_${DateTime.now().millisecondsSinceEpoch}.png');
                              await tempFile.writeAsBytes(signature);
                              
                                                             setState(() {
                                 _hasSignature = true;
                                 _signaturePath = tempFile.path;
                                 _hasChanges = true;
                               });

                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Signature created successfully!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to create signature'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _uploadSignature() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Opening gallery...',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (image != null) {
                 setState(() {
           _hasSignature = true;
           _signaturePath = image.path;
           _hasChanges = true;
           // Here you would process and save the uploaded signature
         });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Signature uploaded successfully: ${image.name}',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to upload signature: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _removeSignature() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Signature'),
          content: const Text(
            'Are you sure you want to remove your signature? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                                 setState(() {
                   _hasSignature = false;
                   _signaturePath = null;
                   _hasChanges = true;
                   // Here you would also remove the signature from storage
                 });

                Navigator.of(context).pop();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Signature removed successfully'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBusinessFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Business Information', Icons.business),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: _selectedState,
          items: [
            'Andhra Pradesh',
            'Arunachal Pradesh',
            'Assam',
            'Bihar',
            'Chhattisgarh',
            'Goa',
            'Gujarat',
            'Haryana',
            'Himachal Pradesh',
            'Jharkhand',
            'Karnataka',
            'Kerala',
            'Madhya Pradesh',
            'Maharashtra',
            'Manipur',
            'Meghalaya',
            'Mizoram',
            'Nagaland',
            'Odisha',
            'Punjab',
            'Rajasthan',
            'Sikkim',
            'Tamil Nadu',
            'Telangana',
            'Tripura',
            'Uttar Pradesh',
            'Uttarakhand',
            'West Bengal',
            'Delhi',
            'Jammu and Kashmir',
            'Ladakh',
            'Chandigarh',
            'Dadra and Nagar Haveli and Daman and Diu',
            'Lakshadweep',
            'Puducherry',
            'Andaman and Nicobar Islands',
          ],
                     onChanged: (value) {
             print('🔍 [DEBUG] State dropdown changed to: "$value"');
             setState(() {
               _selectedState = value;
               _hasChanges = true;
             });
           },
          hint: _businessProfile == null ? 'Select the state where your business operates' : 'Select State',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'State is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: _selectedBusinessType,
          items: [
            'New Business',
            'Sole Proprietorship',
            'Partnership',
            'Limited Liability Partnership (LLP)',
            'Private Limited Company',
            'Public Limited Company',
            'One Person Company (OPC)',
            'Cooperative Society',
            'Trust',
            'Society',
            'Other',
          ],
                     onChanged: (value) {
             print('🔍 [DEBUG] Business type dropdown changed to: "$value"');
             setState(() {
               _selectedBusinessType = value;
               _hasChanges = true;
             });
           },
          hint: _businessProfile == null ? 'Select your business structure type' : 'Select Business Type',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Business type is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          value: _selectedBusinessCategory,
          items: [
            'New Business',
            'Manufacturing',
            'Trading',
            'Services',
            'Retail',
            'Wholesale',
            'E-commerce',
            'Food & Beverage',
            'Healthcare',
            'Education',
            'Technology',
            'Finance',
            'Real Estate',
            'Transportation',
            'Entertainment',
            'Agriculture',
            'Construction',
            'Consulting',
            'Other',
          ],
                     onChanged: (value) {
             print('🔍 [DEBUG] Business category dropdown changed to: "$value"');
             setState(() {
               _selectedBusinessCategory = value;
               _hasChanges = true;
             });
           },
          hint: _businessProfile == null ? 'Select the category that best describes your business' : 'Select Business Category',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Business category is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Website (Optional)',
          controller: _websiteController,
          hint: _businessProfile == null ? 'Enter your business website URL if you have one' : 'Enter website URL',
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: primaryColor, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
    String? Function(String?)? validator,
  }) {
    // Ensure items are unique
    final uniqueItems = _ensureUniqueItems(items);
    
    // Validate the value exists in the items list
    final validatedValue = _validateDropdownValue(value, uniqueItems);
    
    print('🔍 [DEBUG] Building dropdown for "$hint":');
    print('   Original value: "$value"');
    print('   Validated value: "$validatedValue"');
    print('   Original items count: ${items.length}');
    print('   Unique items count: ${uniqueItems.length}');
    print('   Items: $uniqueItems');
    
    return DropdownButtonFormField<String>(
      value: validatedValue,
      isExpanded: true,
      style: TextStyle(
        fontSize: 11,
        color: const Color(0xFF1A1A1A),
        fontWeight: FontWeight.w500,
        fontFamily: GoogleFonts.openSans().fontFamily,
      ),
      items:
          uniqueItems.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: GoogleFonts.openSans().fontFamily,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
    );
  }

  Widget _buildBusinessSignatureSection() {
    // Debug signature state when building the section
    _debugSignatureState();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Business Signature', Icons.draw),
        if (_businessProfile == null) ...[
          const SizedBox(height: 8),
          Text(
            'Add your business signature for official documents',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child:
              _hasBusinessSignature
                  ? Column(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Business Signature',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: _businessSignaturePath != null && _businessSignaturePath!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: _buildSignatureImage(_businessSignaturePath!),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Business signature added',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.draw, color: Colors.grey[400], size: 32),
                      const SizedBox(height: 8),
                      Text(
                        _businessProfile == null
                          ? 'Create or upload business signature'
                          : 'Create or upload business signature',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.openSans().fontFamily,
                        ),
                      ),
                    ],
                  ),
        ),
        const SizedBox(height: 12),
        _hasBusinessSignature
            ? Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showBusinessSignatureDialog();
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Signature'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _removeBusinessSignature();
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Remove'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            )
            : Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showBusinessSignatureDialog();
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(
                      'Create Signature',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _uploadBusinessSignature();
                    },
                    icon: const Icon(Icons.upload, size: 18),
                    label: Text(
                      'Upload Signature',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      ],
    );
  }

  void _showBusinessSignatureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.maxFinite,
            height: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: const Text(
                        'Create Business Signature',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Signature(
                      controller: _businessSignatureController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _businessSignatureController.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.grey[700],
                        ),
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final signature =
                                await _businessSignatureController.toPngBytes();
                            if (signature != null) {
                              // Save signature to temporary file
                              final tempDir = Directory.systemTemp;
                              final tempFile = File('${tempDir.path}/business_signature_${DateTime.now().millisecondsSinceEpoch}.png');
                              await tempFile.writeAsBytes(signature);
                              
                                                             setState(() {
                                 _hasBusinessSignature = true;
                                 _businessSignaturePath = tempFile.path;
                                 _hasChanges = true;
                               });

                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Business signature created successfully!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to create business signature',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _uploadBusinessSignature() async {
    try {
      final ImagePicker picker = ImagePicker();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Opening gallery...',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (image != null) {
                 setState(() {
           _hasBusinessSignature = true;
           _businessSignaturePath = image.path;
           _hasChanges = true;
         });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Business signature uploaded: ${image.name}'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to upload business signature: ${e.toString()}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _removeBusinessSignature() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Business Signature'),
          content: const Text(
            'Are you sure you want to remove your business signature? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                                 setState(() {
                   _hasBusinessSignature = false;
                   _businessSignaturePath = null;
                   _hasChanges = true;
                 });

                Navigator.of(context).pop();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Business signature removed successfully'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignatureImage(String signaturePath) {
    print('🔍 [DEBUG] Building signature image for path: $signaturePath');
    
    // Check if it's a file path
    if (signaturePath.startsWith('/') || signaturePath.contains('\\')) {
      print('🔍 [DEBUG] Treating as file path');
      return Image.file(
        File(signaturePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('❌ [ERROR] Failed to load file image: $error');
          return _buildSignatureFallback('File signature');
        },
      );
    }
    
    // Check if it's a URL
    if (signaturePath.startsWith('http://') || signaturePath.startsWith('https://')) {
      print('🔍 [DEBUG] Treating as URL');
      return Image.network(
        signaturePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('❌ [ERROR] Failed to load network image: $error');
          return _buildSignatureFallback('URL signature');
        },
      );
    }
    
    // Check if it's base64 data
    if (signaturePath.startsWith('data:image/') || signaturePath.length > 100) {
      print('🔍 [DEBUG] Treating as base64 data');
      try {
        // Remove data:image/...;base64, prefix if present
        String base64String = signaturePath;
        if (signaturePath.contains(';base64,')) {
          base64String = signaturePath.split(';base64,')[1];
        }
        
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            print('❌ [ERROR] Failed to load base64 image: $error');
            return _buildSignatureFallback('Base64 signature');
          },
        );
      } catch (e) {
        print('❌ [ERROR] Failed to decode base64: $e');
        return _buildSignatureFallback('Base64 signature');
      }
    }
    
    // Default fallback
    print('⚠️ [WARNING] Unknown signature format, using fallback');
    return _buildSignatureFallback('Unknown format');
  }

  Widget _buildSignatureFallback(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 32),
          const SizedBox(height: 8),
          Text(
            'Signature added successfully',
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '($type)',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _debugSignatureState() {
    print('🔍 [DEBUG] Current signature state:');
    print('   _hasSignature: $_hasSignature');
    print('   _hasBusinessSignature: $_hasBusinessSignature');
    print('   _signaturePath: $_signaturePath');
    print('   _businessSignaturePath: $_businessSignaturePath');
    if (_businessProfile != null) {
      print('   API Digital Signature: ${_businessProfile!.digitalSign}');
      print('   API Business Signature: ${_businessProfile!.businessSignature}');
    } else {
      print('   Business Profile: null');
    }
  }



  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    required String label,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      validator: validator,
      enabled: enabled,
      style: TextStyle(
        fontSize: 12,
        color: const Color(0xFF1A1A1A),
        fontWeight: FontWeight.w500,
        fontFamily: GoogleFonts.openSans().fontFamily,
      ),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 10),
        labelStyle: TextStyle(fontSize: 11, color: const Color(0xFF1A1A1A)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
    );
  }

  // Ensure both forms are properly initialized
  bool _ensureFormsInitialized() {
    print('🔍 [DEBUG] Checking form initialization...');
    
    if (_basicFormKey.currentState == null) {
      print('❌ [DEBUG] Basic form not initialized');
      return false;
    }
    
    if (_businessFormKey.currentState == null) {
      print('❌ [DEBUG] Business form not initialized');
      return false;
    }
    
    print('✅ [DEBUG] Both forms are properly initialized');
    return true;
  }

  Future<void> _saveProfile() async {
    print('🔍 [DEBUG] _saveProfile method called');
    print('🔍 [DEBUG] _basicFormKey: $_basicFormKey');
    print('🔍 [DEBUG] _businessFormKey: $_businessFormKey');
    print('🔍 [DEBUG] _basicFormKey.currentState: ${_basicFormKey.currentState}');
    print('🔍 [DEBUG] _businessFormKey.currentState: ${_businessFormKey.currentState}');
    
    // Ensure both forms are initialized
    if (!_ensureFormsInitialized()) {
      print('❌ [DEBUG] Forms not properly initialized, cannot proceed with validation');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please ensure all form fields are loaded before saving'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    // Validate basic form first
    print('🔍 [DEBUG] About to validate basic form...');
    if (!_basicFormKey.currentState!.validate()) {
      print('❌ [DEBUG] Basic form validation failed');
      return;
    }
    print('✅ [DEBUG] Basic form validation passed');
    
    // Validate business form
    print('🔍 [DEBUG] About to validate business form...');
    if (!_businessFormKey.currentState!.validate()) {
      print('❌ [DEBUG] Business form validation failed');
      return;
    }
    print('✅ [DEBUG] Business form validation passed');

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 [DEBUG] Starting business profile ${_businessProfile == null ? 'creation' : 'update'}...');
      print('🔍 [DEBUG] Form validation passed successfully');
      
      // Map dropdown values back to API format
      final apiState = _mapStateToApi(_selectedState);
      final apiBusinessType = _mapBusinessTypeToApi(_selectedBusinessType);
      final apiBusinessCategory = _mapBusinessCategoryToApi(_selectedBusinessCategory);
      
      print('🔍 [DEBUG] Mapped values for API:');
      print('   State: $_selectedState -> $apiState');
      print('   Business Type: $_selectedBusinessType -> $apiBusinessType');
      print('   Business Category: $_selectedBusinessCategory -> $apiBusinessCategory');

      // Debug: Print all form values before API call
      print('🔍 [DEBUG] Form values being sent to API:');
      print('   Business Name: ${_businessNameController.text.trim()}');
      print('   GST Number: ${_gstinController.text.trim()}');
      print('   Primary Phone: ${_phone1Controller.text.trim()}');
      print('   Secondary Phone: ${_phone2Controller.text.trim().isEmpty ? null : _phone2Controller.text.trim()}');
      print('   Email: ${_emailController.text.trim()}');
      print('   Business Email: ${_businessEmailController.text.trim().isEmpty ? null : _businessEmailController.text.trim()}');
      print('   Address: ${_businessAddressController.text.trim()}');
      print('   Pincode: ${_pincodeController.text.trim()}');
      print('   Description: ${_businessDescriptionController.text.trim()}');
      print('   Website: ${_websiteController.text.trim().isEmpty ? null : _websiteController.text.trim()}');
      print('   Digital Signature Path: $_signaturePath');
      print('   Business Signature Path: $_businessSignaturePath');

      // Get current user ID from auth service
      final currentUserId = await AuthUtils.getCurrentUserId();
      if (currentUserId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not authenticated. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Call the update API (it handles both create and update)
      print('🔍 [DEBUG] Calling ApiService.updateBusinessProfile with userId: $currentUserId');
      final result = await ApiService.updateBusinessProfile(
        userId: currentUserId,
        businessName: _businessNameController.text.trim(),
        gstNo: _gstinController.text.trim(),
        phoneNoFirst: _phone1Controller.text.trim(),
        phoneNoSecond: _phone2Controller.text.trim().isEmpty ? null : _phone2Controller.text.trim(),
        email: _emailController.text.trim(),
        businessEmail: _businessEmailController.text.trim().isEmpty ? null : _businessEmailController.text.trim(),
        businessAddress: _businessAddressController.text.trim(),
        pincode: _pincodeController.text.trim(),
        businessDesc: _businessDescriptionController.text.trim(),
        businessCategory: apiBusinessCategory ?? 'new',
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        businessState: apiState ?? 'mp',
        businessType: apiBusinessType ?? 'new',
        digitalSign: _signaturePath,
        businessSignature: _businessSignaturePath,
      );

      print('🔍 [DEBUG] API call completed. Result: $result');
      print('🔍 [DEBUG] Result type: ${result.runtimeType}');
      print('🔍 [DEBUG] Result keys: ${result.keys.toList()}');

      if (result['success'] == true) {
        print('✅ [DEBUG] Business profile ${_businessProfile == null ? 'created' : 'updated'} successfully');
        
        // Update the local business profile with the response data
        if (result['businessProfile'] != null) {
          print('✅ [DEBUG] Updating local business profile with response data');
          setState(() {
            _businessProfile = result['businessProfile'];
          });
        } else {
          print('⚠️ [DEBUG] No business profile data in response, skipping local update');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _businessProfile == null 
                  ? 'Business profile created successfully!' 
                  : (result[ApiConstants.messageKey] ?? 'Business profile updated successfully!')
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Reset the changes flag since profile was saved successfully
          setState(() {
            _hasChanges = false;
          });
          
          // Refresh the profile data to show updated information
          print('🔄 [DEBUG] Refreshing business profile...');
          _refreshBusinessProfile();
          
          // Return true to indicate successful update/creation
          // This will trigger the callback in the menu screen
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        }
      } else {
        print('❌ [DEBUG] Failed to ${_businessProfile == null ? 'create' : 'update'} business profile: ${result[ApiConstants.messageKey]}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result[ApiConstants.messageKey] ?? 'Failed to ${_businessProfile == null ? 'create' : 'update'} profile. Please try again.'
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('💥 [ERROR] Exception during profile ${_businessProfile == null ? 'creation' : 'update'}: $e');
      print('💥 [ERROR] Exception type: ${e.runtimeType}');
      print('💥 [ERROR] Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_businessProfile == null ? 'create' : 'update'} profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('🔍 [DEBUG] Profile ${_businessProfile == null ? 'creation' : 'update'} completed, loading state set to false');
      }
    }
  }

  // Map dropdown display values back to API format
  String? _mapStateToApi(String? displayState) {
    if (displayState == null) return null;
    
    final stateMap = {
      'Madhya Pradesh': 'mp',
      'Andhra Pradesh': 'ap',
      'Arunachal Pradesh': 'ar',
      'Assam': 'as',
      'Bihar': 'br',
      'Chhattisgarh': 'ct',
      'Goa': 'ga',
      'Gujarat': 'gj',
      'Haryana': 'hr',
      'Himachal Pradesh': 'hp',
      'Jharkhand': 'jh',
      'Karnataka': 'ka',
      'Kerala': 'kl',
      'Madhya Pradesh': 'mh',
      'Maharashtra': 'mh',
      'Manipur': 'mn',
      'Meghalaya': 'ml',
      'Mizoram': 'mz',
      'Nagaland': 'nl',
      'Odisha': 'or',
      'Punjab': 'pb',
      'Rajasthan': 'rj',
      'Sikkim': 'sk',
      'Tamil Nadu': 'tn',
      'Telangana': 'ts',
      'Tripura': 'tr',
      'Uttar Pradesh': 'up',
      'Uttarakhand': 'ut',
      'West Bengal': 'wb',
      'Delhi': 'dl',
      'Jammu and Kashmir': 'jk',
      'Ladakh': 'la',
      'Chandigarh': 'ch',
      'Dadra and Nagar Haveli and Daman and Diu': 'dn',
      'Lakshadweep': 'ld',
      'Puducherry': 'py',
      'Andaman and Nicobar Islands': 'an',
    };
    
    return stateMap[displayState];
  }

  String? _mapBusinessTypeToApi(String? displayType) {
    if (displayType == null) return null;
    
    final typeMap = {
      'New Business': 'new',
      'Sole Proprietorship': 'sole_proprietorship',
      'Partnership': 'partnership',
      'Limited Liability Partnership (LLP)': 'llp',
      'Private Limited Company': 'private_limited',
      'Public Limited Company': 'public_limited',
      'One Person Company (OPC)': 'opc',
      'Cooperative Society': 'cooperative',
      'Trust': 'trust',
      'Society': 'society',
      'Other': 'other',
    };
    
    return typeMap[displayType];
  }

  String? _mapBusinessCategoryToApi(String? displayCategory) {
    if (displayCategory == null) return null;
    
    final categoryMap = {
      'New Business': 'new',
      'Manufacturing': 'manufacturing',
      'Trading': 'trading',
      'Services': 'services',
      'Retail': 'retail',
      'Wholesale': 'wholesale',
      'E-commerce': 'ecommerce',
      'Food & Beverage': 'food_beverage',
      'Healthcare': 'healthcare',
      'Education': 'education',
      'Technology': 'technology',
      'Finance': 'finance',
      'Real Estate': 'real_estate',
      'Transportation': 'transportation',
      'Entertainment': 'entertainment',
      'Agriculture': 'agriculture',
      'Construction': 'construction',
      'Consulting': 'consulting',
      'Other': 'other',
    };
    
    return categoryMap[displayCategory];
  }
}


