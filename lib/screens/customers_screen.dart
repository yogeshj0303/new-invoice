import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../utils/auth_utils.dart';

// Custom text input formatter to convert text to uppercase
class UpperCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _placeOfSupplyController = TextEditingController();
  
  String? _selectedGstTreatment;
  String? _selectedState;
  
  @override
  void initState() {
    super.initState();
  }

  bool _isValidGSTNumber(String gstNumber) {
    // GST number format: 15 alphanumeric characters
    // Example: 27AAPFU0939F1Z5
    if (gstNumber.length != 15) return false;
    
    // Check if it contains only alphanumeric characters
    if (!RegExp(r'^[A-Za-z0-9]{15}$').hasMatch(gstNumber)) return false;
    
    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    // Indian phone number validation (10 digits, optionally with +91)
    return RegExp(r'^(\+91)?[6-9]\d{9}$').hasMatch(phone);
  }

  void _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E3085)),
            ),
          );
        },
      );

      try {
        // Get actual user ID from auth service
        final userId = await AuthUtils.getCurrentUserId();
        if (userId == null) {
          Navigator.of(context).pop(); // Hide loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User not authenticated. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Call the API to create customer
        final result = await ApiService.createCustomer(
          userId: userId.toString(),
          customerName: _customerNameController.text.trim(),
          companyName: _companyNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          gst: _gstNumberController.text.trim(),
          gstTreatment: _selectedGstTreatment ?? '',
          placeOfSupply: _placeOfSupplyController.text.trim(),
          state: _selectedState ?? '',
        );

        // Hide loading indicator
        Navigator.of(context).pop();

        if (result['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result[ApiConstants.messageKey] ?? 'Customer saved successfully!',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              margin: EdgeInsets.all(8),
            ),
          );
          
          // Clear form
          _formKey.currentState!.reset();
          setState(() {
            _selectedGstTreatment = null;
            _selectedState = null;
            _placeOfSupplyController.text = '';
            _customerNameController.text = '';
            _companyNameController.text = '';
            _emailController.text = '';
            _phoneController.text = '';
            _gstNumberController.text = '';
          });
          
          // Refresh customers list
          // _loadCustomers(); // This line is removed as per the edit hint
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result[ApiConstants.messageKey] ?? 'Failed to save customer',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              margin: EdgeInsets.all(8),
            ),
          );
        }
      } catch (e) {
        // Hide loading indicator
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'An error occurred: ${e.toString()}',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            margin: EdgeInsets.all(8),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _gstNumberController.dispose();
    _placeOfSupplyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information Section
                _buildSectionHeader('Personal Information'),
                SizedBox(height: 8),
                _buildInputField('Customer Name *', _customerNameController, isRequired: true, validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Customer name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                }),
                SizedBox(height: 12),
                _buildInputField('Company Name', _companyNameController),
                SizedBox(height: 12),
                
                // Contact Information Section
                _buildSectionHeader('Contact Information'),
                SizedBox(height: 8),
                _buildInputField('Email Address *', _emailController, keyboardType: TextInputType.emailAddress, isRequired: true, validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!_isValidEmail(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                }),
                SizedBox(height: 12),
                _buildInputField('Phone Number *', _phoneController, keyboardType: TextInputType.phone, isRequired: true, 
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!_isValidPhone(value)) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Unfocus after 10 digits
                    if (value.length == 10) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
                SizedBox(height: 12),
                
                // GST Information Section
                _buildSectionHeader('GST Information'),
                SizedBox(height: 8),
                _buildInputField('GST Number', _gstNumberController, 
                  hintText: '27AAPFU0939F1Z5', 
                  helperText: 'Format: 15 alphanumeric characters', 
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(15),
                    UpperCaseTextInputFormatter(),
                  ],
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (!_isValidGSTNumber(value)) {
                        return 'Please enter a valid GST number';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Unfocus after 15 characters
                    if (value.length == 15) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
                SizedBox(height: 12),
                _buildDropdownField('GST Treatment *', [
                    'Unregistered Business',
                    'Registered Business',
                  ], _selectedGstTreatment, (value) {
                  setState(() {
                    _selectedGstTreatment = value;
                  });
                }, isRequired: true, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select GST treatment';
                  }
                  return null;
                }),
                SizedBox(height: 12),
                _buildInputField('Place of Supply', _placeOfSupplyController, hintText: 'Enter place of supply'),
                SizedBox(height: 12),
                _buildDropdownField('Place of Supply State *', [
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
                  ], _selectedState, (value) {
                  setState(() {
                    _selectedState = value;
                  });
                }, isRequired: true, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a state';
                  }
                  return null;
                }),
                SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Unfocus from any active text fields
                          FocusScope.of(context).unfocus();
                          _formKey.currentState!.reset();
                          setState(() {
                            _selectedGstTreatment = null;
                            _selectedState = null;
                            _placeOfSupplyController.text = '';
                            _customerNameController.text = '';
                            _companyNameController.text = '';
                            _emailController.text = '';
                            _phoneController.text = '';
                            _gstNumberController.text = '';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Color(0xFF6C757D), width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6C757D),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _saveCustomer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E3085),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Save Customer',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40), // Space for bottom navigation
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton( // This line is removed as per the edit hint
      //   onPressed: _showCustomersList,
      //   backgroundColor: Color(0xFF2E3085),
      //   child: Icon(Icons.people, color: Colors.white),
      //   tooltip: 'View Customers',
      // ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
        ),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Add Customer',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.1,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: Color(0xFF2E3085),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {
    TextInputType? keyboardType,
    String? helperText,
    bool isRequired = false,
    String? Function(String?)? validator,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
          decoration: InputDecoration(
            hintText: hintText ?? 'Enter ${label.toLowerCase().replaceAll(' *', '')}',
            hintStyle: TextStyle(
              color: Color(0xFFADB5BD),
              fontSize: 12,
            ),
            helperText: helperText,
            helperStyle: TextStyle(
              color: Color(0xFF6C757D),
              fontSize: 8.5,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFE9ECEF), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFE9ECEF), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFF2E3085), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFDC3545), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFDC3545), width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
          validator: validator,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value, Function(String?) onChanged, {
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: 'Select ${label.toLowerCase().replaceAll(' *', '')}',
            hintStyle: TextStyle(
              color: Color(0xFFADB5BD),
              fontSize: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFE9ECEF), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFE9ECEF), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFF2E3085), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFDC3545), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Color(0xFFDC3545), width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF6C757D), size: 16),
          dropdownColor: Colors.white,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
} 