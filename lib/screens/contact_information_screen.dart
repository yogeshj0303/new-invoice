import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/contact_service.dart';
import '../services/theme_service.dart';

class ContactInformationScreen extends StatefulWidget {
  const ContactInformationScreen({super.key});

  @override
  State<ContactInformationScreen> createState() => _ContactInformationScreenState();
}

class _ContactInformationScreenState extends State<ContactInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final _companyNameController = TextEditingController();
  final _companyDescController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _gstController = TextEditingController();
  final _panController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize form with current contact service data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contactService = Provider.of<ContactService>(context, listen: false);
      contactService.initialize().then((_) {
        _loadContactData(contactService);
      });
    });
  }

  void _loadContactData(ContactService contactService) {
    setState(() {
      _companyNameController.text = contactService.companyName;
      _companyDescController.text = contactService.companyDescription;
      _address1Controller.text = contactService.address1;
      _address2Controller.text = contactService.address2;
      _phoneController.text = contactService.phone;
      _emailController.text = contactService.email;
      _websiteController.text = contactService.website;
      _gstController.text = contactService.gstNumber;
      _panController.text = contactService.panNumber;
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyDescController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _gstController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _saveContactInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final contactService = Provider.of<ContactService>(context, listen: false);
      
      await contactService.updateAllContactInfo(
        companyName: _companyNameController.text,
        companyDescription: _companyDescController.text,
        address1: _address1Controller.text,
        address2: _address2Controller.text,
        phone: _phoneController.text,
        email: _emailController.text,
        website: _websiteController.text,
        gstNumber: _gstController.text,
        panNumber: _panController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact information saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back after a short delay to show the SnackBar
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving contact information: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPhonePresets() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Select Phone',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ContactService.phonePresets.map((phone) {
                return Consumer<ThemeService>(
                  builder: (context, themeService, child) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _phoneController.text = phone;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: themeService.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: themeService.primaryColor),
                        ),
                        child: Text(
                          phone,
                          style: TextStyle(
                            fontSize: 12,
                            color: themeService.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEmailPresets() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Select Email',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ContactService.emailPresets.map((email) {
                return Consumer<ThemeService>(
                  builder: (context, themeService, child) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _emailController.text = email;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: themeService.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: themeService.primaryColor),
                        ),
                        child: Text(
                          email,
                          style: TextStyle(
                            fontSize: 12,
                            color: themeService.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ContactService, ThemeService>(
      builder: (context, contactService, themeService, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
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
                icon: Icon(Icons.arrow_back, color: themeService.primaryColor, size: 18),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(32, 32),
                ),
              ),
            ),
            title: Text(
              'Contact Information',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: GoogleFonts.openSans().fontFamily,
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: Colors.grey[200]),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Information Section
                        _buildSectionHeader('Company Information', Icons.business),
                        const SizedBox(height: 12),
                        
                        _buildTextField(
                          controller: _companyNameController,
                          label: 'Company Name',
                          hint: 'Enter company name',
                          icon: Icons.business_center,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Company name is required';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _companyDescController,
                          label: 'Company Description',
                          hint: 'Enter company description',
                          icon: Icons.description,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Address Section
                        _buildSectionHeader('Address', Icons.location_on),
                        const SizedBox(height: 12),
                        
                        _buildTextField(
                          controller: _address1Controller,
                          label: 'Address Line 1',
                          hint: 'Street address, building name',
                          icon: Icons.home,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _address2Controller,
                          label: 'Address Line 2',
                          hint: 'City, state, postal code, country',
                          icon: Icons.location_city,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Contact Details Section
                        _buildSectionHeader('Contact Details', Icons.contact_phone),
                        const SizedBox(height: 12),
                        
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: 'Enter phone number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.list, color: themeService.primaryColor),
                            onPressed: _showPhonePresets,
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty && !contactService.isValidPhone(value)) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'Enter email address',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.list, color: themeService.primaryColor),
                            onPressed: _showEmailPresets,
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty && !contactService.isValidEmail(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _websiteController,
                          label: 'Website',
                          hint: 'Enter website URL',
                          icon: Icons.language,
                          keyboardType: TextInputType.url,
                          validator: (value) {
                            if (value != null && value.isNotEmpty && !contactService.isValidWebsite(value)) {
                              return 'Please enter a valid website URL';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Legal Information Section
                        _buildSectionHeader('Legal Information', Icons.gavel),
                        const SizedBox(height: 12),
                        
                        _buildTextField(
                          controller: _gstController,
                          label: 'GST Number',
                          hint: 'Enter GST number (optional)',
                          icon: Icons.receipt_long,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value != null && value.isNotEmpty && !contactService.isValidGstNumber(value)) {
                              return 'Please enter a valid GST number';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _panController,
                          label: 'PAN Number',
                          hint: 'Enter PAN number (optional)',
                          icon: Icons.credit_card,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value != null && value.isNotEmpty && !contactService.isValidPanNumber(value)) {
                              return 'Please enter a valid PAN number';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                
                // Save Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveContactInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeService.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Row(
          children: [
            Icon(icon, color: themeService.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeService.primaryColor,
                fontFamily: GoogleFonts.openSans().fontFamily,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization? textCapitalization,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: themeService.primaryColor),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: themeService.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        );
      },
    );
  }
}
