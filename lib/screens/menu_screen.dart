import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../models/business_profile.dart';
import '../utils/auth_utils.dart';
import '../services/api_service.dart';
import '../screens/recover_deleted_invoices_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);

  // User and business data
  User? _currentUser;
  BusinessProfile? _businessProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh data if we don't have user data yet and not currently loading
    if (_currentUser == null && !_isLoading) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    // Don't show loading if we already have user data
    if (_currentUser != null && _businessProfile != null) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Load current user data
      final user = await AuthUtils.getCurrentUser();
      setState(() {
        _currentUser = user;
      });

      // Load business profile data
      final businessResult = await ApiService.getBusinessProfile();
      if (businessResult['success'] == true && businessResult['businessProfile'] != null) {
        setState(() {
          _businessProfile = businessResult['businessProfile'];
        });
      }
      
      // Only add delay if we're actually loading from scratch
      if (_currentUser == null) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Public method to refresh business profile data
  Future<void> refreshBusinessProfile() async {
    try {
      final businessResult = await ApiService.getBusinessProfile();
      if (businessResult['success'] == true && businessResult['businessProfile'] != null) {
        setState(() {
          _businessProfile = businessResult['businessProfile'];
        });
      }
    } catch (e) {
      print('Error refreshing business profile: $e');
    }
  }

  // Silent refresh method for when returning from other screens
  Future<void> silentRefresh() async {
    if (_currentUser == null) return;
    
    try {
      // Refresh business profile data silently
      final businessResult = await ApiService.getBusinessProfile();
      if (businessResult['success'] == true && businessResult['businessProfile'] != null) {
        setState(() {
          _businessProfile = businessResult['businessProfile'];
        });
      }
    } catch (e) {
      print('Error during silent refresh: $e');
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        await AuthUtils.logout();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error during logout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: (_isLoading && _currentUser == null)
              ? _buildLoadingScreen(key: const ValueKey('loading'))
              : RefreshIndicator(
                onRefresh: _loadUserData,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildBusinessNameSection(),
                        const SizedBox(height: 12),
                        _buildBusinessProfileSection(),
                        const SizedBox(height: 12),
                        _buildSubscriptionSection(),
                        const SizedBox(height: 12),
                        _buildInviteEarnSection(),
                        const SizedBox(height: 16),
                        _buildSettingsSection(),
                        if (_currentUser == null) ...[
                          const SizedBox(height: 20),
                          _buildLoginPrompt(),
                        ],
                        const SizedBox(height: 80), // Space for bottom navigation
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildLoadingScreen({Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading Menu...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we load your information',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF4E4AA8),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.login,
            color: Color(0xFF4E4AA8),
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            'Welcome to Invoice App',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Login to access all features and manage your business efficiently',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E4AA8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Login Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessNameSection() {
    if (_currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFFFE082),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.business,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Login to setup your business profile',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final businessName = _businessProfile?.businessName ?? 'Business Name';
    final businessInitial = businessName.isNotEmpty ? businessName[0].toUpperCase() : 'B';
    final hasBusinessProfile = _businessProfile != null;
    
    return Column(
      children: [
        // Business Name with Company Letter Avatar
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  businessInitial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    businessName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (!hasBusinessProfile) ...[
                    const SizedBox(height: 4),
                    Text(
                      'No business profile set up',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Business & GST Settings Button
        InkWell(
          onTap: () async {
            final result = await Navigator.pushNamed(context, '/business-profile');
            // If we get a result back, refresh the business profile data
            if (result == true) {
              // Show loading indicator
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Refreshing business profile...'),
                      ],
                    ),
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              
              // Refresh the data
              await _loadUserData();
              
              // Show success message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Business profile updated successfully!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: hasBusinessProfile ? Colors.grey[50] : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: hasBusinessProfile ? Colors.grey[300]! : const Color(0xFFFFE082),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasBusinessProfile ? Icons.business : Icons.add_business,
                  color: hasBusinessProfile ? Colors.grey[700] : const Color(0xFFFFD700),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  hasBusinessProfile ? 'BUSINESS PROFILE' : 'SETUP BUSINESS PROFILE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: hasBusinessProfile ? Colors.grey[700] : const Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: primaryColor,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessProfileSection() {
    if (_currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFFFE082),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Not Logged In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Please login to view your profile',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final userName = _currentUser?.name ?? 'User Name';
    final userEmail = _currentUser?.email ?? 'user@example.com';
    final userPhone = _currentUser?.phone ?? '';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    userInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // if (userPhone.isNotEmpty) ...[
                    //   const SizedBox(height: 2),
                    //   Text(
                    //     userPhone,
                    //     style: TextStyle(
                    //       fontSize: 12,
                    //       color: Colors.grey[500],
                    //       fontWeight: FontWeight.w400,
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ),
            ],
          ),
          if (_currentUser != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE9ECEF)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_currentUser!.district}, ${_currentUser!.state}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection() {
    if (_currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          border: Border.all(
            color: const Color(0xFFFFE082),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.workspace_premium,
              color: Color(0xFFFFD700),
              size: 20,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Login to view subscription',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: primaryColor,
              size: 14,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/subscription'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1), // Light yellow background
          border: Border.all(
            color: const Color(0xFFFFE082), // Light yellow border
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.workspace_premium,
              color: Color(0xFFFFD700),
              size: 20,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Business Subscription Plan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: primaryColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteEarnSection() {
    if (_currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE9ECEF),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_add,
              color: Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Login to invite & earn',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 14,
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/invite-earn'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE9ECEF),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_add,
              color: primaryColor,
              size: 20,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Invite & Earn',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: primaryColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildSettingsSection() {
    if (_currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE9ECEF),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.login,
                    color: Colors.grey[400],
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Login to access settings',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE9ECEF),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              _buildSettingsListTileWithBadge(
                'Invoice Settings',
                Icons.receipt_long,
                'NEW',
                () {
                  Navigator.pushNamed(context, '/invoice-settings');
                },
              ),
              const Divider(height: 1, color: Color(0xFFE9ECEF)),
              _buildSettingsListTile(
                'Manage Companies',
                Icons.business_center,
                () {
                  Navigator.pushNamed(context, '/manage-companies');
                },
              ),
              const Divider(height: 1, color: Color(0xFFE9ECEF)),
              _buildSettingsListTile(
                'Account Settings',
                Icons.person_outline,
                () {
                  Navigator.pushNamed(context, '/account-settings');
                },
              ),
              // const Divider(height: 1, color: Color(0xFFE9ECEF)),
              // _buildSettingsListTile(
              //   'Reminder Settings',
              //   Icons.notifications_outlined,
              //   () {
              //     Navigator.pushNamed(context, '/reminder-settings');
              //   },
              // ),
              const Divider(height: 1, color: Color(0xFFE9ECEF)),
              _buildSettingsListTile(
                'About',
                Icons.info_outline,
                () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
              const Divider(height: 1, color: Color(0xFFE9ECEF)),
              _buildSettingsListTile(
                'Rate this app',
                Icons.star_outline,
                () {
                  _rateApp();
                },
              ),
              const Divider(height: 1, color: Color(0xFFE9ECEF)),
              _buildSettingsListTile(
                'Recover Deleted Invoices',
                Icons.delete_outline,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecoverDeletedInvoicesScreen(
                        businessProfile: _businessProfile,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsListTile(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: primaryColor,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsListTileWithBadge(
    String title,
    IconData icon,
    String badge,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: primaryColor,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }



  void _rateApp() async {
    // For Android - Play Store
    const String androidUrl = 'https://play.google.com/store/apps/details?id=com.example.invoice_app';
    // For iOS - App Store (replace with actual bundle ID when available)
    const String iosUrl = 'https://apps.apple.com/app/id123456789';
    
    final Uri url = Uri.parse(Theme.of(context).platform == TargetPlatform.iOS ? iosUrl : androidUrl);
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: show a dialog with the URL
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Rate this app'),
              content: const Text('Please visit the app store to rate this app.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }
}

