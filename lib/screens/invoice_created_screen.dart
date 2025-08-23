import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/terms_service.dart';
import 'create_invoice.dart';
import '../widgets/edit_bottom_sheet_content.dart';
import 'invoice_template_screen.dart';

class InvoiceCreatedScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double discount;
  final double tax;
  final List<Map<String, dynamic>> additionalCharges;
  final double additionalChargesTotal;
  final double roundoff;
  final double total;
  final String invoiceNumber;
  final DateTime date;
  final String customerName;
  final String customerPhone;
  final String notes;
  final String paymentType;
  final double amountReceived;

  const InvoiceCreatedScreen({
    super.key,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.additionalCharges,
    required this.additionalChargesTotal,
    required this.roundoff,
    required this.total,
    required this.invoiceNumber,
    required this.date,
    required this.customerName,
    required this.customerPhone,
    required this.notes,
    required this.paymentType,
    required this.amountReceived,
  });

  @override
  State<InvoiceCreatedScreen> createState() => _InvoiceCreatedScreenState();
}

class _InvoiceCreatedScreenState extends State<InvoiceCreatedScreen> {
  bool showColorPalette = false;
  Color selectedColor = Colors.indigo;

  @override
  void initState() {
    super.initState();
    // Initialize with theme service color
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeService = Provider.of<ThemeService>(context, listen: false);
      setState(() {
        selectedColor = themeService.primaryColor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TermsService, ThemeService>(
      builder: (context, termsService, themeService, child) {
        final cardColor = Theme.of(context).cardColor;
        final primaryColor = selectedColor;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!, width: 1),
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
            title: Text(
              'Invoice Created',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.edit, color: primaryColor, size: 18),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      showColorPalette = !showColorPalette;
                    });
                  },
                  icon: Icon(Icons.palette, color: primaryColor, size: 18),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ),
            ],
            shape: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          body: Column(
            children: [
              // Color Palette
              if (showColorPalette)
                Container(
                  clipBehavior: Clip.hardEdge,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: cardColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Invoice Color:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.hardEdge,
                        child: Row(
                          children: [
                            _buildColorOption(Colors.indigo, 'Indigo'),
                            _buildColorOption(Colors.blue, 'Blue'),
                            _buildColorOption(Colors.green, 'Green'),
                            _buildColorOption(Colors.orange, 'Orange'),
                            _buildColorOption(Colors.red, 'Red'),
                            _buildColorOption(Colors.purple, 'Purple'),
                            _buildColorOption(Colors.teal, 'Teal'),
                            _buildColorOption(Colors.brown, 'Brown'),
                            _buildColorOption(Colors.pink, 'Pink'),
                            _buildColorOption(Colors.yellow, 'Yellow'),
                            _buildColorOption(Colors.grey, 'Grey'),
                            _buildColorOption(Colors.black, 'Black'),
                            _buildColorOption(Colors.white, 'White'),
                            _buildColorOption(Colors.amber, 'Amber'),
                            _buildColorOption(Colors.cyan, 'Cyan'),
                            _buildColorOption(Colors.deepPurple, 'Deep Purple'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Invoice Preview
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Container(
                        width: 400,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InvoiceTemplate(
                          items: widget.items,
                          subtotal: widget.subtotal,
                          discount: widget.discount,
                          tax: widget.tax,
                          additionalCharges: widget.additionalCharges,
                          additionalChargesTotal: widget.additionalChargesTotal,
                          roundoff: widget.roundoff,
                          total: widget.total,
                          invoiceNumber: widget.invoiceNumber,
                          date: widget.date,
                          customerName: widget.customerName,
                          customerPhone: widget.customerPhone,
                          notes: widget.notes,
                          paymentType: widget.paymentType,
                          amountReceived: widget.amountReceived,
                          primaryColor: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _previewInvoice(context),
                      icon: Icon(Icons.visibility, size: 18, color: selectedColor),
                      label: Text(
                        'Preview',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selectedColor),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _shareInvoice(context),
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text(
                        'Share',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

  Widget _buildColorOption(Color color, String label) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
        // Update theme service
        final themeService = Provider.of<ThemeService>(context, listen: false);
        themeService.updatePrimaryColor(color);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.transparent,
                  width: isSelected ? 3 : 0,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.black : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditInvoice() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreateInvoiceScreen(
          cartItems: widget.items,
          itemQuantities: null,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '01', '02', '03', '04', '05', '06',
      '07', '08', '09', '10', '11', '12'
    ];
    return '${date.day.toString().padLeft(2, '0')}/${months[date.month - 1]}/${date.year}';
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(2);
  }

  double _calculateSubtotal() {
    return widget.items.fold(0.0, (sum, item) => sum + (item['qty'] * item['price']));
  }

  double _calculateTotalTax() {
    return widget.items.fold(0.0, (sum, item) {
      final itemTotal = item['qty'] * item['price'];
      final gstValue = item['gst'] != null ? double.tryParse(item['gst'].toString()) ?? 0.0 : 0.0;
      return sum + (itemTotal * gstValue / 100);
    });
  }

  double _getTaxRate() {
    return 18.0;
  }

  double _getItemGSTRate(Map<String, dynamic> item) {
    return item['gst'] != null ? double.tryParse(item['gst'].toString()) ?? 0.0 : _getTaxRate();
  }

  double _calculateCGST() {
    return _calculateTotalTax() / 2;
  }

  double _calculateSGST() {
    return _calculateTotalTax() / 2;
  }

  String _amountInWords(double amount) {
    return _numberToWords(amount.toInt());
  }

  String _numberToWords(int number) {
    if (number == 0) return 'Zero';
    
    final units = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'];
    final teens = ['Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    
    if (number < 10) return units[number];
    if (number < 20) return teens[number - 10];
    if (number < 100) {
      if (number % 10 == 0) return tens[number ~/ 10];
      return '${tens[number ~/ 10]} ${units[number % 10]}';
    }
    if (number < 1000) {
      if (number % 100 == 0) return '${units[number ~/ 100]} Hundred';
      return '${units[number ~/ 100]} Hundred ${_numberToWords(number % 100)}';
    }
    if (number < 100000) {
      if (number % 1000 == 0) return '${_numberToWords(number ~/ 1000)} Thousand';
      return '${_numberToWords(number ~/ 1000)} Thousand ${_numberToWords(number % 1000)}';
    }
    if (number < 10000000) {
      if (number % 100000 == 0) return '${_numberToWords(number ~/ 100000)} Lakh';
      return '${_numberToWords(number ~/ 100000)} Lakh ${_numberToWords(number % 100000)}';
    }
    if (number % 10000000 == 0) return '${_numberToWords(number ~/ 10000000)} Crore';
    return '${_numberToWords(number ~/ 10000000)} Crore ${_numberToWords(number % 10000000)}';
  }

  Future<void> _previewInvoice(BuildContext context) async {
    // Preview functionality - simplified for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preview functionality coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _shareInvoice(BuildContext context) async {
    // Share functionality - simplified for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
