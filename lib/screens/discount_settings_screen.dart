import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:invoice_app/services/discount_settings_service.dart';
import 'package:invoice_app/services/theme_service.dart';
import 'package:invoice_app/screens/invoice_template_screen.dart';

class DiscountSettingsScreen extends StatefulWidget {
  const DiscountSettingsScreen({super.key});

  @override
  State<DiscountSettingsScreen> createState() => _DiscountSettingsScreenState();
}

class _DiscountSettingsScreenState extends State<DiscountSettingsScreen> {
  String _selectedDiscountType = 'after_tax';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final discountService = Provider.of<DiscountSettingsService>(context, listen: false);
      setState(() {
        _selectedDiscountType = discountService.discountType;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final discountService = Provider.of<DiscountSettingsService>(context, listen: false);
    setState(() {
      _selectedDiscountType = discountService.discountType;
    });
  }

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
            icon: Icon(Icons.arrow_back, color: DiscountSettingsConstants.primaryColor, size: 18),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(32, 32),
            ),
          ),
        ),
        title: Text(
          'Discount Settings',
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
          child: Container(height: 1, color: DiscountSettingsConstants.borderColor),
        ),
      ),
      body: SafeArea(
        child: Consumer2<DiscountSettingsService, ThemeService>(
          builder: (context, discountService, themeService, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [themeService.primaryColor, themeService.primaryColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: themeService.primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.percent_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Discount Calculation Method',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: GoogleFonts.openSans().fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Choose how discounts are applied in your invoices',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontFamily: GoogleFonts.openSans().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Options Section
                    Text(
                      'Select Discount Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: GoogleFonts.openSans().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Discount After Tax Option
                    _buildOptionCard(
                      title: 'Discount After Tax',
                      description: 'Discount is applied after calculating tax on subtotal',
                      icon: Icons.trending_down,
                      isSelected: _selectedDiscountType == 'after_tax',
                      onTap: () {
                        setState(() {
                          _selectedDiscountType = 'after_tax';
                        });
                      },
                      themeService: themeService,
                    ),
                    const SizedBox(height: 12),

                    // Discount Before Tax Option
                    _buildOptionCard(
                      title: 'Discount Before Tax',
                      description: 'Discount is applied before calculating tax on subtotal',
                      icon: Icons.trending_up,
                      isSelected: _selectedDiscountType == 'before_tax',
                      onTap: () {
                        setState(() {
                          _selectedDiscountType = 'before_tax';
                        });
                      },
                      themeService: themeService,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showResetDialog(context, discountService),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Reset to Default',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: GoogleFonts.openSans().fontFamily,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _saveChanges(context, discountService),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeService.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: GoogleFonts.openSans().fontFamily,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeService themeService,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? themeService.primaryColor.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? themeService.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? themeService.primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? themeService.primaryColor : Colors.black87,
                      fontFamily: GoogleFonts.openSans().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? themeService.primaryColor.withOpacity(0.8) : Colors.grey[600],
                      fontFamily: GoogleFonts.openSans().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: themeService.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceTemplatePreview(DiscountSettingsService discountService, ThemeService themeService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview_outlined,
                color: themeService.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Invoice Template Preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: GoogleFonts.openSans().fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Show a sample invoice template with the current discount setting
          InvoiceTemplate(
            items: [
              {'name': 'Sample Item 1', 'qty': 2, 'price': 100.0, 'unit': 'PCS'},
              {'name': 'Sample Item 2', 'qty': 1, 'price': 150.0, 'unit': 'PCS'},
            ],
            subtotal: 350.0,
            discount: 35.0, // 10% discount
            tax: 42.0, // 12% GST
            additionalCharges: [],
            additionalChargesTotal: 0.0,
            roundoff: 0.0,
            total: discountService.calculateTotal(
              subtotal: 350.0,
              discount: 35.0,
              tax: 42.0,
              additionalCharges: 0.0,
              roundoff: 0.0,
            ),
            invoiceNumber: '001',
            date: DateTime.now(),
            customerName: 'Sample Customer',
            customerPhone: '+91 98765 43210',
            notes: '',
            paymentType: 'Cash',
            amountReceived: 400.0,
            primaryColor: themeService.primaryColor,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.blue[200]!, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Current setting: ${discountService.displayText}. This affects how totals are calculated in your invoices.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontFamily: GoogleFonts.openSans().fontFamily,
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

  void _saveChanges(BuildContext context, DiscountSettingsService discountService) async {
    try {
      await discountService.updateDiscountType(_selectedDiscountType);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Discount settings updated successfully!'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating discount settings: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showResetDialog(BuildContext context, DiscountSettingsService discountService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reset to Default',
            style: TextStyle(
              fontFamily: GoogleFonts.openSans().fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to reset the discount settings to "Discount After Tax"? This action cannot be undone.',
            style: TextStyle(
              fontFamily: GoogleFonts.openSans().fontFamily,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: GoogleFonts.openSans().fontFamily,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await discountService.resetToDefaults();
                  if (mounted) {
                    setState(() {
                      _selectedDiscountType = discountService.discountType;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Discount settings reset to default!'),
                        backgroundColor: Colors.orange[600],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error resetting discount settings: $e'),
                        backgroundColor: Colors.red[600],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Reset',
                style: TextStyle(
                  color: Colors.red[600],
                  fontFamily: GoogleFonts.openSans().fontFamily,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Static constants
class DiscountSettingsConstants {
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color borderColor = Color(0xFFE9ECEF);
}
