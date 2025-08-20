import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);

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
                  const SizedBox(height: 80), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessNameSection() {
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
              child: const Center(
                child: Text(
                  'B',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Business Name',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Business & GST Settings Button
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/business-profile'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'BUSINESS PROFILE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
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
      child: Row(
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
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'john.doe@example.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
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

  Widget _buildSubscriptionSection() {
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
              const Divider(height: 1, color: Color(0xFFE9ECEF)),
              _buildSettingsListTile(
                'Reminder Settings',
                Icons.notifications_outlined,
                () {
                  Navigator.pushNamed(context, '/reminder-settings');
                },
              ),
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
                () {},
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

