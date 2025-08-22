import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AcceptableUsePolicyScreen extends StatefulWidget {
  const AcceptableUsePolicyScreen({super.key});

  @override
  State<AcceptableUsePolicyScreen> createState() => _AcceptableUsePolicyScreenState();
}

class _AcceptableUsePolicyScreenState extends State<AcceptableUsePolicyScreen> {
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
            'Acceptable Use Policy',
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
                    '1. Prohibited Activities',
                    'Users are prohibited from engaging in any illegal, harmful, or inappropriate activities while using the application. This includes but is not limited to fraud, harassment, copyright infringement, and distribution of malicious content.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '2. Business Use Only',
                    'This application is designed for legitimate business purposes. Users must not use the application for personal, non-commercial activities or any activities that violate applicable business regulations.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '3. Data Integrity',
                    'Users must maintain the accuracy and integrity of all data entered into the application. This includes customer information, invoice details, and business records. Falsification of data is strictly prohibited.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '4. Security Requirements',
                    'Users are responsible for maintaining the security of their account credentials and must not share access with unauthorized individuals. Any suspected security breaches must be reported immediately.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '5. Compliance with Laws',
                    'All use of the application must comply with applicable local, state, and federal laws, including but not limited to tax laws, business regulations, and data protection requirements.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '6. Professional Conduct',
                    'Users must maintain professional standards when using the application. This includes respectful communication, accurate record-keeping, and adherence to industry best practices.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '7. Resource Usage',
                    'Users must not engage in activities that could disrupt the application\'s performance or interfere with other users\' access to the service.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '8. Violations and Consequences',
                    'Violations of this policy may result in account suspension, termination, or legal action as appropriate. We reserve the right to take action against any user who violates these terms.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '9. Reporting Violations',
                    'Users are encouraged to report any suspected violations of this policy through the appropriate support channels. All reports will be investigated promptly and confidentially.',
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    '10. Policy Updates',
                    'This acceptable use policy may be updated periodically. Users will be notified of significant changes, and continued use of the application constitutes acceptance of the updated policy.',
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
