import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/invoice_numbering_service.dart';
import '../services/theme_service.dart';
import '../services/terms_service.dart';
import 'invoice_template_screen.dart';

class InvoiceNumberingScreen extends StatefulWidget {
  const InvoiceNumberingScreen({super.key});

  @override
  State<InvoiceNumberingScreen> createState() => _InvoiceNumberingScreenState();
}

class _InvoiceNumberingScreenState extends State<InvoiceNumberingScreen> {
  String currentPrefix = '';
  String currentSeparator = '';
  bool _isInitialLoading = true;
  bool _isSaving = false;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isInitialLoading = true);
    
    try {
      // Initialize with invoice numbering service data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final invoiceNumberingService = Provider.of<InvoiceNumberingService>(context, listen: false);
        setState(() {
          currentPrefix = invoiceNumberingService.prefix;
          currentSeparator = invoiceNumberingService.separator;
          _isInitialLoading = false;
        });
      });
    } catch (e) {
      setState(() => _isInitialLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update local state when dependencies change
    final invoiceNumberingService = Provider.of<InvoiceNumberingService>(context, listen: false);
    setState(() {
      currentPrefix = invoiceNumberingService.prefix;
      currentSeparator = invoiceNumberingService.separator;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<InvoiceNumberingService, ThemeService, TermsService>(
      builder: (context, invoiceNumberingService, themeService, termsService, child) {
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
              'Invoice Numbering',
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
          body: _isInitialLoading
              ? _buildLoadingBody(themeService)
              : RefreshIndicator(
                  onRefresh: _loadInitialData,
                  color: themeService.primaryColor,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Format Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Invoice Number Format',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontFamily: GoogleFonts.openSans().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormatInfo('Prefix', currentPrefix, themeService.primaryColor),
                                  ),
                                  Expanded(
                                    child: _buildFormatInfo('Separator', currentSeparator, themeService.secondaryColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Show example invoice number
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: themeService.primaryColor.withOpacity(0.3), width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Example Invoice Number:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${currentPrefix}${currentSeparator}${invoiceNumberingService.currentNumber}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: themeService.primaryColor,
                                        fontFamily: GoogleFonts.openSans().fontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Invoice Template Preview Section
                        Text(
                          'Invoice Template Preview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: GoogleFonts.openSans().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'See how your invoice numbering will appear in the actual invoice',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: GoogleFonts.openSans().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildInvoiceTemplatePreview(invoiceNumberingService, themeService),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Edit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving || _isResetting 
                                ? null 
                                : () => _showEditBottomSheet(context, invoiceNumberingService, themeService),
                            icon: _isSaving 
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.edit, size: 20),
                            label: Text(
                              _isSaving ? 'Saving...' : 'Edit Invoice Numbering',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeService.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reset Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isSaving || _isResetting 
                                ? null 
                                : () => _showResetDialog(context, invoiceNumberingService),
                            icon: _isResetting 
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                    ),
                                  )
                                : const Icon(Icons.restore, size: 20),
                            label: Text(
                              _isResetting ? 'Resetting...' : 'Reset to Defaults',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red[600],
                              side: BorderSide(color: Colors.red[600]!, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildLoadingBody(ThemeService themeService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(themeService.primaryColor),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading invoice numbering settings...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: GoogleFonts.openSans().fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch your current configuration',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: GoogleFonts.openSans().fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTemplatePreview(InvoiceNumberingService invoiceNumberingService, ThemeService themeService) {
    // Sample data for the invoice template preview
    final sampleItems = [
      {'name': 'Sample Item 1', 'qty': 2, 'price': 150.0, 'gst': 18.0},
      {'name': 'Sample Item 2', 'qty': 1, 'price': 200.0, 'gst': 18.0},
      {'name': 'Sample Item 3', 'qty': 3, 'price': 75.0, 'gst': 18.0},
    ];

    final additionalCharges = [
      {'name': 'Delivery Charge', 'price': 50.0},
      {'name': 'Service Tax', 'price': 25.0},
    ];

    // Pass just the raw number - the InvoiceTemplate will format it
    final currentInvoiceNumber = invoiceNumberingService.currentNumber.toString();

    return Container(
      width: 400,
      child: InvoiceTemplate(
        items: sampleItems,
        subtotal: 650.0,
        discount: 50.0,
        tax: 117.0,
        additionalCharges: additionalCharges,
        additionalChargesTotal: 75.0,
        roundoff: 2.0,
        total: 794.0,
        invoiceNumber: currentInvoiceNumber,
        date: DateTime.now(),
        customerName: 'John Doe',
        customerPhone: '+91 98765 43210',
        notes: 'Thank you for your business!',
        paymentType: 'Cash',
        amountReceived: 800.0,
        primaryColor: themeService.primaryColor,
      ),
    );
  }

  Widget _buildFormatInfo(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: GoogleFonts.openSans().fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: GoogleFonts.openSans().fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context, InvoiceNumberingService invoiceNumberingService, ThemeService themeService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _buildEditBottomSheet(context, invoiceNumberingService, themeService),
      ),
    );
  }

  Widget _buildEditBottomSheet(BuildContext context, InvoiceNumberingService invoiceNumberingService, ThemeService themeService) {
    final TextEditingController prefixController = TextEditingController(text: invoiceNumberingService.prefix);
    final TextEditingController separatorController = TextEditingController(text: invoiceNumberingService.separator);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Edit Invoice Numbering',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: GoogleFonts.openSans().fontFamily,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prefix Field
                  Text(
                    'Invoice Prefix',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontFamily: GoogleFonts.openSans().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: prefixController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'e.g., INV, BILL, RECEIPT',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeService.primaryColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Separator Field
                  Text(
                    'Separator',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontFamily: GoogleFonts.openSans().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: separatorController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'e.g., -, /, #',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: themeService.primaryColor, width: 2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving 
                          ? null 
                          : () async {
                              setState(() => _isSaving = true);
                              
                              try {
                                await invoiceNumberingService.updatePrefix(prefixController.text);
                                await invoiceNumberingService.updateSeparator(separatorController.text);
                                
                                // Update local state immediately after saving
                                setState(() {
                                  currentPrefix = prefixController.text;
                                  currentSeparator = separatorController.text;
                                });
                               
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Invoice numbering settings saved successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  
                                  // Navigate back after a short delay to show the SnackBar
                                  Future.delayed(const Duration(milliseconds: 1500), () {
                                    if (mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  });
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error saving settings: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                setState(() => _isSaving = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeService.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, InvoiceNumberingService invoiceNumberingService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'Are you sure you want to reset all invoice numbering settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _isResetting 
                ? null 
                : () async {
                    Navigator.of(context).pop();
                    setState(() => _isResetting = true);
                    
                    try {
                      await invoiceNumberingService.resetToDefaults();
                      
                      // Update local state after reset
                      setState(() {
                        currentPrefix = invoiceNumberingService.prefix;
                        currentSeparator = invoiceNumberingService.separator;
                      });
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Settings reset to defaults successfully!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error resetting settings: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      setState(() => _isResetting = false);
                    }
                  },
            child: _isResetting 
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  )
                : const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
