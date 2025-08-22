import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  // Theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color borderColor = Color(0xFFE9ECEF);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: primaryColor,
                size: 18,
              ),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(32, 32),
              ),
            ),
          ),
          title: const Text(
            'Privacy Policy',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: borderColor,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    '1. Information We Collect',
                    'We collect information you provide directly to us, such as when you create an account, create invoices, or contact us for support. This may include your name, email address, business information, and invoice data.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '2. How We Use Your Information',
                    'We use the information we collect to provide, maintain, and improve our services, process transactions, send you technical notices and support messages, and respond to your comments and questions.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '3. Information Sharing',
                    'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy or as required by law.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '4. Data Security',
                    'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '5. Cookies and Tracking',
                    'We may use cookies and similar tracking technologies to enhance your experience on our application, analyze usage patterns, and personalize content.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '6. Third-Party Services',
                    'Our application may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '7. Data Retention',
                    'We retain your personal information for as long as necessary to provide our services and fulfill the purposes outlined in this policy, unless a longer retention period is required by law.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '8. Your Rights',
                    'You have the right to access, update, or delete your personal information. You may also opt out of certain communications or request data portability.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '9. Changes to This Policy',
                    'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the effective date.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '10. Contact Us',
                    'If you have any questions about this privacy policy or our data practices, please contact us through the support channels provided in the application.',
                  ),
                  const SizedBox(height: 80), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
