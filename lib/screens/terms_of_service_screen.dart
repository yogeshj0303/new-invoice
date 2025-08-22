import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
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
            'Terms of Service',
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
                    '1. Acceptance of Terms',
                    'By accessing and using this invoice application, you accept and agree to be bound by the terms and provision of this agreement.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '2. Use License',
                    'Permission is granted to temporarily download one copy of the application for personal, non-commercial transitory viewing only.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '3. Disclaimer',
                    'The materials on the application are provided on an \'as is\' basis. The application makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '4. Limitations',
                    'In no event shall the application or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on the application.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '5. Revisions and Errata',
                    'The materials appearing on the application could include technical, typographical, or photographic errors. The application does not warrant that any of the materials on its application are accurate, complete or current.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '6. Links',
                    'The application has not reviewed all of the sites linked to its application and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by the application of the site.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '7. Site Terms of Use Modifications',
                    'The application may revise these terms of use for its application at any time without notice. By using this application you are agreeing to be bound by the then current version of these Terms and Conditions of Use.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '8. Governing Law',
                    'Any claim relating to the application shall be governed by the laws of the jurisdiction in which the application is located without regard to its conflict of law provisions.',
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
