import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/contact_service.dart';
import '../services/theme_service.dart';
import 'contact_information_screen.dart';

class InvoicePhoneSettingsScreen extends StatefulWidget {
  const InvoicePhoneSettingsScreen({super.key});

  @override
  State<InvoicePhoneSettingsScreen> createState() => _InvoicePhoneSettingsScreenState();
}

class _InvoicePhoneSettingsScreenState extends State<InvoicePhoneSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect to the comprehensive contact information screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ContactInformationScreen(),
        ),
      );
    });
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
              'Contact Settings',
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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 64,
                  color: themeService.primaryColor.withOpacity(0.6),
                ),
                const SizedBox(height: 24),
                Text(
                  'Redirecting to Contact Information...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: GoogleFonts.openSans().fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'You are being redirected to the comprehensive\nContact Information screen where you can manage\nall your business details in one place.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: GoogleFonts.openSans().fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const ContactInformationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeService.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Go to Contact Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
}
