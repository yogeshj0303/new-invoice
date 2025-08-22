import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../utils/auth_utils.dart';
import '../models/user.dart';
import 'main_screen.dart'; // Added import for MainScreen

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const OTPVerificationScreen({super.key, required this.phoneNumber});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> with TickerProviderStateMixin {
  // Theme colors matching the app
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);
  static const Color backgroundColor = Color(0xFFFAFBFC);
  static const Color cardColor = Colors.white;

  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isResendEnabled = true;
  int _resendTimer = 30;
  Timer? _timer;
  String _enteredOTP = '';

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
    _startResendTimer();
    
    // Add listener to OTP controller
    otpController.addListener(_onOTPChanged);
  }

  void _onOTPChanged() {
    _enteredOTP = otpController.text;
    
    // Note: Auto-verification is now handled by the Pinput onCompleted callback
    // This prevents duplicate API calls. We only track the OTP text here.
    print('🔐 [DEBUG] OTP text changed to: $_enteredOTP (length: ${_enteredOTP.length})');
  }

  void _startResendTimer() {
    setState(() {
      _isResendEnabled = false;
      _resendTimer = 30;
    });
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _isResendEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  void _resendOTP() async {
    if (!_isResendEnabled) return;
    
    // Prevent multiple simultaneous API calls
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Extract phone number without +91 prefix for API call
      String phoneNumber = widget.phoneNumber;
      if (phoneNumber.startsWith('+91')) {
        phoneNumber = phoneNumber.substring(3); // Remove +91 prefix
      }

      // Call the API to resend OTP
      final result = await ApiService.sendOTP('+91$phoneNumber');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (result[ApiConstants.successKey]) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP resent successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        
        // Reset the timer
        _startResendTimer();
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result[ApiConstants.messageKey]),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // Helper method to check if user profile is complete
  bool _isUserProfileComplete(User user) {
    // Check if all required fields have meaningful values
    bool hasValidName = user.name.trim().isNotEmpty && user.name.trim().length >= 2;
    bool hasValidEmail = user.email.trim().isNotEmpty && user.email.contains('@');
    bool hasValidAddress = user.fullAddress.trim().isNotEmpty && user.fullAddress.trim().length >= 5; // Reduced from 10 to 5
    bool hasValidState = user.state.trim().isNotEmpty;
    bool hasValidDistrict = user.district.trim().isNotEmpty;
    bool hasValidPhone = user.phone.trim().isNotEmpty && user.phone.trim().length >= 10; // Changed from == to >=
    
    print('🔍 [DEBUG] Profile completeness check:');
    print('   Name valid: $hasValidName (${user.name})');
    print('   Email valid: $hasValidEmail (${user.email})');
    print('   Address valid: $hasValidAddress (${user.fullAddress})');
    print('   State valid: $hasValidState (${user.state})');
    print('   District valid: $hasValidDistrict (${user.district})');
    print('   Phone valid: $hasValidPhone (${user.phone})');
    
    // Additional detailed debugging
    print('   Name length: ${user.name.trim().length}');
    print('   Email length: ${user.email.trim().length}');
    print('   Address length: ${user.fullAddress.trim().length}');
    print('   State length: ${user.state.trim().length}');
    print('   District length: ${user.district.trim().length}');
    print('   Phone length: ${user.phone.trim().length}');
    
    bool isComplete = hasValidName && hasValidEmail && hasValidAddress && 
                     hasValidState && hasValidDistrict && hasValidPhone;
    
    print('   Overall profile complete: $isComplete');
    
    // If validation fails, check if we have the minimum required data
    if (!isComplete) {
      print('⚠️ [DEBUG] Strict validation failed, checking minimum requirements...');
      
      // Minimum requirement: at least name, email, and phone
      bool hasMinimumData = hasValidName && hasValidEmail && hasValidPhone;
      print('   Has minimum data: $hasMinimumData');
      
      // If we have minimum data, consider it complete enough
      if (hasMinimumData) {
        print('✅ [DEBUG] Minimum data requirements met, considering profile complete');
        return true;
      }
    }
    
    return isComplete;
  }

  void _verifyOTP() async {
    if (_enteredOTP.length != 4) return;
    
    // Prevent multiple simultaneous API calls
    if (_isLoading) return;

    print('🔐 [DEBUG] Starting OTP verification...');
    print('   Phone: ${widget.phoneNumber}');
    print('   OTP: $_enteredOTP');

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Extract phone number without +91 prefix for API call
      String phoneNumber = widget.phoneNumber;
      if (phoneNumber.startsWith('+91')) {
        phoneNumber = phoneNumber.substring(3); // Remove +91 prefix
      }

      // Call the API to verify OTP
      final result = await ApiService.verifyOTP(phoneNumber, _enteredOTP);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (result[ApiConstants.successKey]) {
        print('✅ [DEBUG] OTP verification successful!');
        print('   Response: $result');
        
        // Check if user information exists in the response
        if (result['user_info'] != null) {
          print('✅ [DEBUG] User information found in response');
          print('   Raw user_info: ${result['user_info']}');
          
          try {
            // Parse user data from the response
            final userData = result['user_info'];
            print('   User data type: ${userData.runtimeType}');
            print('   User data keys: ${userData.keys.toList()}');
            
            final user = User.fromJson(userData);
            
            print('✅ [DEBUG] User data parsed successfully:');
            print('   ID: ${user.id}');
            print('   Name: ${user.name}');
            print('   Email: ${user.email}');
            print('   Phone: ${user.phone}');
            print('   State: ${user.state}');
            print('   District: ${user.district}');
            print('   Address: ${user.fullAddress}');
            
            // Check if user profile is complete
            bool isProfileComplete = _isUserProfileComplete(user);
            
            print('🔍 [DEBUG] Final profile completeness decision: $isProfileComplete');
            
            if (isProfileComplete) {
              print('✅ [DEBUG] User profile is complete, proceeding to main screen');
              
              // Save user as logged in with complete user data
              print('🔄 [DEBUG] Saving user login state and data...');
              bool loginSaved = await AuthUtils.setLoggedIn(
                phone: widget.phoneNumber,
                name: user.name,
                user: user,
              );
              
              print('🔍 [DEBUG] Login save result: $loginSaved');
              
              if (loginSaved) {
                print('✅ [DEBUG] User login state and data saved successfully');
                
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Welcome back, ${user.name}!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
                
                // Navigate directly to main screen since user profile is complete
                if (mounted) {
                  print('🔄 [DEBUG] Navigating to main screen (user profile complete)...');
                  print('   Current route: ${ModalRoute.of(context)?.settings.name}');
                  print('   Can pop: ${Navigator.of(context).canPop()}');
                  
                  // Add a small delay to ensure the success message is shown
                  await Future.delayed(Duration(milliseconds: 500));
                  
                  try {
                    print('🔄 [DEBUG] Attempting navigation with pushReplacementNamed to /main...');
                    Navigator.pushReplacementNamed(context, '/main');
                    print('✅ [DEBUG] Navigation to main screen successful');
                  } catch (e) {
                    print('❌ [ERROR] Navigation failed: $e');
                    print('   Error type: ${e.runtimeType}');
                    // Fallback: try to navigate with MaterialPageRoute
                    try {
                      print('🔄 [DEBUG] Trying fallback navigation with MaterialPageRoute...');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                      );
                      print('✅ [DEBUG] Fallback navigation successful');
                    } catch (e2) {
                      print('❌ [ERROR] Fallback navigation also failed: $e2');
                      print('   Second error type: ${e2.runtimeType}');
                      // Show error message to user
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Login successful! Please restart the app to continue.'),
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  }
                }
              } else {
                print('⚠️ [WARNING] Failed to save login state, but continuing...');
                
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result[ApiConstants.messageKey]),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
                
                // Navigate to main screen anyway
                if (mounted) {
                  print('🔄 [DEBUG] Attempting navigation despite login save failure...');
                  
                  // Add a small delay to ensure the success message is shown
                  await Future.delayed(Duration(milliseconds: 500));
                  
                  try {
                    Navigator.pushReplacementNamed(context, '/main');
                    print('✅ [DEBUG] Navigation to main screen successful');
                  } catch (e) {
                    print('❌ [ERROR] Navigation failed: $e');
                    // Fallback: try to navigate with MaterialPageRoute
                    try {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                      );
                      print('✅ [DEBUG] Fallback navigation successful');
                    } catch (e2) {
                      print('❌ [ERROR] Fallback navigation also failed: $e2');
                      // Show error message to user
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Login successful! Please restart the app to continue.'),
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  }
                }
              }
            } else {
              print('⚠️ [DEBUG] User profile is incomplete, redirecting to complete profile screen');
              
              // Show success message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result[ApiConstants.messageKey]),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
              
              // Navigate to complete profile screen since profile is incomplete
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/complete-profile', arguments: widget.phoneNumber);
              }
            }
          } catch (e) {
            print('❌ [ERROR] Failed to parse user data: $e');
            print('   Error type: ${e.runtimeType}');
            print('   Stack trace: ${StackTrace.current}');
            print('🔄 [DEBUG] Falling back to complete profile flow...');
            
            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result[ApiConstants.messageKey]),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
            
            // Navigate to complete profile screen if user data parsing fails
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/complete-profile', arguments: widget.phoneNumber);
            }
          }
        } else {
          print('ℹ️ [DEBUG] No user information in response, user needs to complete profile');
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result[ApiConstants.messageKey]),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
          
          // Navigate to complete profile screen since no user info exists
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/complete-profile', arguments: widget.phoneNumber);
          }
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result[ApiConstants.messageKey]),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    otpController.dispose();
    otpFocusNode.dispose();
    super.dispose();
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
                          Icons.verified_user_outlined,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'OTP Verification',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Enter the 4-digit code sent to',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                                             Text(
                         widget.phoneNumber,
                         style: theme.textTheme.bodyMedium?.copyWith(
                           color: Colors.white,
                           fontWeight: FontWeight.w600,
                         ),
                       ),
                    ],
                  ),
                ),
              ),
              
              // OTP Form Section
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
                        padding: EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              
                                                             // OTP Input Field using Pinput
                               Center(
                                 child: Pinput(
                                   controller: otpController,
                                   focusNode: otpFocusNode,
                                   length: 4,
                                   defaultPinTheme: PinTheme(
                                     width: 60,
                                     height: 60,
                                     textStyle: theme.textTheme.titleLarge?.copyWith(
                                       fontWeight: FontWeight.w700,
                                       color: Colors.black87,
                                     ),
                                     decoration: BoxDecoration(
                                       border: Border.all(color: Colors.grey[300]!),
                                       borderRadius: BorderRadius.circular(12),
                                       color: Colors.grey[50],
                                     ),
                                   ),
                                   focusedPinTheme: PinTheme(
                                     width: 60,
                                     height: 60,
                                     textStyle: theme.textTheme.titleLarge?.copyWith(
                                       fontWeight: FontWeight.w700,
                                       color: Colors.black87,
                                     ),
                                     decoration: BoxDecoration(
                                       border: Border.all(color: primaryColor, width: 2),
                                       borderRadius: BorderRadius.circular(12),
                                       color: Colors.white,
                                     ),
                                   ),
                                   submittedPinTheme: PinTheme(
                                     width: 60,
                                     height: 60,
                                     textStyle: theme.textTheme.titleLarge?.copyWith(
                                       fontWeight: FontWeight.w700,
                                       color: Colors.black87,
                                     ),
                                     decoration: BoxDecoration(
                                       border: Border.all(color: primaryColor),
                                       borderRadius: BorderRadius.circular(12),
                                       color: Colors.white,
                                     ),
                                   ),
                                   pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                                   showCursor: true,
                                   onCompleted: (pin) {
                                     print('🔐 [DEBUG] Pinput onCompleted triggered with pin: $pin');
                                     _enteredOTP = pin;
                                     _verifyOTP();
                                   },
                                 ),
                               ),
                              SizedBox(height: 30),
                              
                              // Verify Button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: (_isLoading || _enteredOTP.length != 4) ? null : () {
                                    print('🔐 [DEBUG] Verify button pressed manually');
                                    _verifyOTP();
                                  },
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
                                          'Verify OTP',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 20),
                              
                              // Resend OTP Section
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "Didn't receive the code?",
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Resend in ',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (!_isResendEnabled)
                                          Text(
                                            '$_resendTimer s',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        if (_isResendEnabled)
                                          TextButton(
                                            onPressed: _isLoading ? null : () {
                                              print('🔐 [DEBUG] Resend OTP button pressed');
                                              _resendOTP();
                                            },
                                            child: Text(
                                              'Resend OTP',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
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