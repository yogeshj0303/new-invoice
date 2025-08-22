import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../utils/location_data.dart';
import '../utils/auth_utils.dart';
import '../models/user.dart';
import '../screens/main_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String phoneNumber;
  
  const CompleteProfileScreen({super.key, required this.phoneNumber});

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> with TickerProviderStateMixin {
  // Theme colors matching the app
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);
  static const Color backgroundColor = Color(0xFFFAFBFC);
  static const Color cardColor = Colors.white;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode addressFocusNode = FocusNode();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // State and District data
  String? _selectedState;
  String? _selectedDistrict;
  
  // Get states and districts from location utility
  List<String> get _states => IndianLocation.states;
  List<String> get _districts => _selectedState != null ? IndianLocation.getDistricts(_selectedState!) : [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    addressFocusNode.dispose();
    super.dispose();
  }

  void _handleCompleteProfile() async {
    if (!_formKey.currentState!.validate()) return;

    print('🚀 [DEBUG] Starting profile completion process...');
    print('   Phone: ${widget.phoneNumber}');
    print('   Name: ${nameController.text}');
    print('   Email: ${emailController.text}');

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Call the API to update user profile
      print('📞 [DEBUG] Calling ApiService.updateUserProfile...');
      final result = await ApiService.updateUserProfile(
        phoneNumber: widget.phoneNumber,
        name: nameController.text,
        email: emailController.text,
        state: _selectedState ?? '',
        district: _selectedDistrict ?? '',
        fullAddress: addressController.text,
      );
      
      print('📱 [DEBUG] API Response received:');
      print('   Result: $result');
      print('   Success: ${result[ApiConstants.successKey]}');
      print('   Message: ${result[ApiConstants.messageKey]}');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (result[ApiConstants.successKey]) {
        print('✅ [DEBUG] Profile updated successfully!');
        
        // Extract user data from the response
        User? user;
        if (result['user'] != null) {
          try {
            user = User.fromJson(result['user']);
            print('✅ [DEBUG] User data parsed successfully: ${user.toString()}');
          } catch (e) {
            print('⚠️ [WARNING] Failed to parse user data: $e');
            user = null;
          }
        }
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result[ApiConstants.messageKey]),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        
        // Set user as logged in and save complete user data
        if (mounted) {
          print('🔄 [DEBUG] Setting user as logged in and saving user data...');
          
          // Save login state and user data
          bool loginSaved = false;
          try {
            loginSaved = await AuthUtils.setLoggedIn(
              phone: widget.phoneNumber,
              name: nameController.text,
              user: user, // Pass the complete user data
            );
            print('✅ [DEBUG] Login state and user data save result: $loginSaved');
            
            // Also store user data separately for easy access
            if (user != null) {
              await AuthUtils.storeUserData(user);
              print('✅ [DEBUG] User data stored separately');
            }
          } catch (e) {
            print('⚠️ [WARNING] Failed to save login state or user data: $e');
            print('🔄 [DEBUG] Continuing with navigation anyway...');
          }
          
          print('✅ [DEBUG] User logged in successfully, attempting navigation...');
          
          // Add a small delay to ensure the success message is shown
          await Future.delayed(Duration(milliseconds: 500));
          
          // Try the most direct navigation approach first
          print('🔄 [DEBUG] Attempting direct navigation to main screen...');
          try {
            // Use pushReplacement with MaterialPageRoute for most reliable navigation
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
            print('✅ [DEBUG] Direct navigation to MainScreen completed successfully!');
            return; // Exit early if navigation succeeds
          } catch (e) {
            print('❌ [DEBUG] Direct navigation failed: $e');
          }
          
          // Fallback: Try named route navigation
          print('🔄 [DEBUG] Trying named route navigation...');
          try {
            Navigator.pushReplacementNamed(context, '/main');
            print('✅ [DEBUG] Named route navigation completed');
            return;
          } catch (e) {
            print('❌ [DEBUG] Named route navigation failed: $e');
          }
          
          // Final fallback: Show dialog with manual navigation option
          if (mounted) {
            print('🔄 [DEBUG] All navigation methods failed, showing fallback dialog...');
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Profile Completed Successfully! 🎉'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your profile has been updated successfully!'),
                      SizedBox(height: 8),
                      if (user != null) ...[
                        Text('User ID: ${user.id}'),
                        Text('Name: ${user.name}'),
                        Text('Email: ${user.email}'),
                        SizedBox(height: 8),
                      ],
                      Text(
                        'Note: There was a minor issue with navigation, but your profile is saved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        // Try to go back to previous screen
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text('Go Back'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        // Try one more time with a simple approach
                        try {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => MainScreen()),
                          );
                        } catch (e) {
                          print('❌ [DEBUG] Final navigation attempt failed: $e');
                          // Show instructions to user
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please manually navigate to the main screen or restart the app.'),
                              duration: Duration(seconds: 5),
                            ),
                          );
                        }
                      },
                      child: Text('Continue to Main Screen'),
                    ),
                  ],
                );
              },
            );
          }
        }
      } else {
        print('❌ [DEBUG] Profile update failed!');
        print('   Error message: ${result[ApiConstants.messageKey]}');
        print('   Error type: ${result[ApiConstants.errorKey]}');
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result[ApiConstants.messageKey]),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('💥 [DEBUG] Exception in _handleCompleteProfile:');
      print('   Error: $e');
      print('   Error type: ${e.runtimeType}');
      print('   Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                height: size.height * 0.25,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      secondaryColor,
                    ],
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.person_add_outlined,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Complete Your Profile',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tell us a bit about yourself',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Profile Form Section
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Information',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Please provide your details to complete the setup',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 20),
                              
                              // Phone Number Display (Read-only)
                              // Container(
                              //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              //   decoration: BoxDecoration(
                              //     color: Colors.grey[100],
                              //     borderRadius: BorderRadius.circular(10),
                              //     border: Border.all(color: Colors.grey[300]!),
                              //   ),
                              //   child: Row(
                              //     children: [
                              //       Icon(Icons.phone_outlined, color: primaryColor, size: 20),
                              //       SizedBox(width: 12),
                              //       Text(
                              //         'Phone: ${widget.phoneNumber}',
                              //         style: theme.textTheme.bodyMedium?.copyWith(
                              //           color: Colors.grey[700],
                              //           fontWeight: FontWeight.w500,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // SizedBox(height: 20),
                              
                              // Full Name Field
                              TextFormField(
                                controller: nameController,
                                focusNode: nameFocusNode,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  if (value.trim().length > 50) {
                                    return 'Name must be less than 50 characters';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Full Name *',
                                  hintText: 'Enter your full name',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.red[300]!),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              // Email Field
                              TextFormField(
                                controller: emailController,
                                focusNode: emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email address';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  if (value.length > 100) {
                                    return 'Email must be less than 100 characters';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Email Address *',
                                  hintText: 'Enter your email address',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.red[300]!),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              // State Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedState,
                                decoration: InputDecoration(
                                  labelText: 'State *',
                                  hintText: 'Select your state',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_on_outlined,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.red[300]!),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                                items: _states.map((String state) {
                                  return DropdownMenuItem<String>(
                                    value: state,
                                    child: Text(state),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedState = newValue;
                                    _selectedDistrict = null; // Reset district when state changes
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your state';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              
                              // District Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedDistrict,
                                decoration: InputDecoration(
                                  labelText: 'District *',
                                  hintText: _selectedState == null 
                                      ? 'Select state first' 
                                      : 'Select your district',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_city_outlined,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.red[300]!),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                                items: _districts.map((String district) {
                                  return DropdownMenuItem<String>(
                                    value: district,
                                    child: Text(district),
                                  );
                                }).toList(),
                                onChanged: _selectedState == null ? null : (String? newValue) {
                                  setState(() {
                                    _selectedDistrict = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your district';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              
                              // Full Address Field
                              TextFormField(
                                controller: addressController,
                                focusNode: addressFocusNode,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.done,
                                maxLines: 3,
                                minLines: 2,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your full address';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'Address must be at least 10 characters';
                                  }
                                  if (value.trim().length > 200) {
                                    return 'Address must be less than 200 characters';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Full Address *',
                                  hintText: 'Enter your complete address (street, city, PIN code)',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.home_outlined,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.red[300]!),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  alignLabelWithHint: true,
                                ),
                              ),
                              SizedBox(height: 24),
                              
                              // Complete Profile Button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleCompleteProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    shadowColor: primaryColor.withOpacity(0.3),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Complete Profile',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              // Skip for now option
                              Center(
                                child: TextButton.icon(
                                  onPressed: _isLoading ? null : () {
                                    if (mounted) {
                                      Navigator.pushReplacementNamed(context, '/main');
                                    }
                                  },
                                  icon: Icon(Icons.skip_next, size: 16),
                                  label: Text(
                                    'Skip for now',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 