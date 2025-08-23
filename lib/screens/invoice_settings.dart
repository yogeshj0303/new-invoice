import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:invoice_app/screens/gst_settings_screen.dart';
import 'package:invoice_app/screens/contact_information_screen.dart';
import 'package:invoice_app/screens/terms_conditions_screen.dart';
import 'package:invoice_app/screens/invoice_numbering_screen.dart';
import 'package:invoice_app/screens/discount_settings_screen.dart';
import 'package:invoice_app/screens/digital_signature_screen.dart';
import 'package:invoice_app/services/discount_settings_service.dart';
import 'package:invoice_app/services/digital_signature_service.dart';

class InvoiceSettingsScreen extends StatelessWidget {
  const InvoiceSettingsScreen({super.key});

  // Theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);
  static const Color borderColor = Color(0xFFE9ECEF);

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.arrow_back, color: primaryColor, size: 18),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(32, 32),
            ),
          ),
        ),
        title: Text(
          'Invoice Settings',
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
          child: Container(height: 1, color: borderColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Premium Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Custom Invoice Theme',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Create your own professional theme',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 12),

                // GST Features Section
                // Container(
                //   padding: const EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //     border: Border.all(color: borderColor, width: 1),
                //     borderRadius: BorderRadius.circular(6),
                //   ),
                //   child: Row(
                //     children: [
                //       Container(
                //         width: 36,
                //         height: 36,
                //         decoration: BoxDecoration(
                //           color: primaryColor.withOpacity(0.1),
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //         child: Icon(
                //           Icons.receipt_long,
                //           color: primaryColor,
                //           size: 18,
                //         ),
                //       ),
                //       const SizedBox(width: 12),
                //       Expanded(
                //         child: GestureDetector(
                //           onTap: () {
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                 builder: (context) => const GSTSettingsScreen(),
                //               ),
                //             );
                //           },
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               const Text(
                //                 'GST e-Invoice & e-Way Bill',
                //                 style: TextStyle(
                //                   fontSize: 14,
                //                   fontWeight: FontWeight.w600,
                //                   color: Colors.black87,
                //                 ),
                //               ),
                //               const SizedBox(height: 2),
                //               Text(
                //                 'Generate compliant GST documents',
                //                 style: TextStyle(
                //                   fontSize: 12,
                //                   color: Colors.grey[600],
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //       Icon(
                //         Icons.arrow_forward_ios,
                //         color: Colors.grey[600],
                //         size: 14,
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 12),

                // Settings Section
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GSTSettingsScreen(),
                            ),
                          );
                        },
                        icon: Icons.palette_outlined,
                        title: 'Theme & Colors',
                        description: 'Customize invoice appearance',
                      ),
                      const Divider(height: 1, color: borderColor),
                      _buildSettingItem(
                        icon: Icons.format_list_numbered,
                        title: 'Invoice Numbering',
                        description: 'Set prefix and sequence',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InvoiceNumberingScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: borderColor),
                                             _buildSettingItem(
                         icon: Icons.phone_outlined,
                         title: 'Contact Information',
                         description: 'Phone, email & business details',
                         onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => const ContactInformationScreen(),
                             ),
                           );
                         },
                       ),
                      const Divider(height: 1, color: borderColor),
                      _buildSettingItem(
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        description: 'Add custom terms',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TermsConditionsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: borderColor),
                      Consumer<DigitalSignatureService>(
                        builder: (context, signatureService, child) {
                          return _buildSettingItem(
                            icon: Icons.draw_outlined,
                            title: 'Digital Signature',
                            description: signatureService.displayText,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DigitalSignatureScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const Divider(height: 1, color: borderColor),
                      _buildSettingItem(
                        icon: Icons.account_balance_outlined,
                        title: 'Bank Details',
                        description: 'Display account information',
                      ),
                      const Divider(height: 1, color: borderColor),
                      Consumer<DiscountSettingsService>(
                        builder: (context, discountService, child) {
                          return _buildSettingItem(
                            icon: Icons.percent_outlined,
                            title: 'Discount Settings',
                            description: discountService.displayText,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DiscountSettingsScreen(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80), // Space for bottom navigation
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: primaryColor, size: 12),
          ],
        ),
      ),
    );
  }
}
