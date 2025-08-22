import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GSTSettingsScreen extends StatefulWidget {
  const GSTSettingsScreen({super.key});

  @override
  State<GSTSettingsScreen> createState() => _GSTSettingsScreenState();
}

class _GSTSettingsScreenState extends State<GSTSettingsScreen> {
  Color selectedPrimaryColor = const Color(0xFF2E3085);
  Color selectedSecondaryColor = const Color(0xFF4E4AA8);
  Color selectedAccentColor = const Color(0xFF4CAF50);

  final List<Color> primaryColors = [
    const Color(0xFF2E3085), // Blue
    const Color(0xFFD32F2F), // Red
    const Color(0xFF388E3C), // Green
    const Color(0xFFF57C00), // Orange
    const Color(0xFF7B1FA2), // Purple
    const Color(0xFF1976D2), // Light Blue
    const Color(0xFFE91E63), // Pink
    const Color(0xFF795548), // Brown
  ];

  final List<Color> secondaryColors = [
    const Color(0xFF4E4AA8), // Blue
    const Color(0xFFEF5350), // Red
    const Color(0xFF66BB6A), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF42A5F5), // Light Blue
    const Color(0xFFEC407A), // Pink
    const Color(0xFF8D6E63), // Brown
  ];

  final List<Color> accentColors = [
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF2196F3), // Blue
    const Color(0xFFFFC107), // Amber
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFF9800), // Orange
    const Color(0xFF607D8B), // Blue Grey
  ];

  // Sample data for template preview
  final List<Map<String, dynamic>> sampleItems = [
    {'name': 'Sample Item 1', 'qty': 2, 'price': 100.0, 'gst': 18.0},
    {'name': 'Sample Item 2', 'qty': 1, 'price': 150.0, 'gst': 18.0},
  ];

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
            icon: Icon(Icons.arrow_back, color: selectedPrimaryColor, size: 18),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(32, 32),
            ),
          ),
        ),
        title: Text(
          'GST Settings',
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Template Preview Section
                      Text(
                        'Template Preview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: GoogleFonts.openSans().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Invoice Template Preview - Matching InvoiceTemplate structure
                      Center(
                        child: Container(
                          width: 400,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Ultra-Compact Header
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(3),
                                    topRight: Radius.circular(3),
                                  ),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Company Info - Ultra-Compact
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: selectedPrimaryColor,
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                                child: const Icon(
                                                  Icons.business,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'ACT T CONNECT',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: selectedPrimaryColor,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Professional Business Solutions',
                                                    style: TextStyle(
                                                      fontSize: 7,
                                                      color: Colors.grey[700],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Block no 9, South Avenue, Shahpura',
                                            style: TextStyle(
                                              fontSize: 7,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Bhopal, Madhya Pradesh 462039, India',
                                            style: TextStyle(
                                              fontSize: 7,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            'Mobile: +1 (555) 123-4567',
                                            style: TextStyle(
                                              fontSize: 7,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Invoice Details - Ultra-Compact
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(2),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Invoice No.',
                                                style: TextStyle(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Text(
                                                'INV-001',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: selectedPrimaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                'Invoice Date',
                                                style: TextStyle(
                                                  fontSize: 6,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Text(
                                                _formatDate(DateTime.now()),
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Ultra-Compact Items Table
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 0.3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Table Header - Ultra-Compact
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        border: Border.all(
                                          color: Colors.grey[400]!,
                                          width: 0.3,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'S.NO',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'ITEMS',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'QTY',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'RATE',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'GST',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 4,
                                              ),
                                              child: Text(
                                                'AMOUNT',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Table Rows - Ultra-Compact
                                    ...sampleItems.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final item = entry.value;
                                      final itemTotal = item['qty'] * item['price'];
                                      final gstValue = item['gst'] != null ? double.tryParse(item['gst'].toString()) ?? 0.0 : 0.0;
                                      final itemTax = itemTotal * gstValue / 100;
                                      final itemTotalWithTax = itemTotal + itemTax;

                                      return Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: index.isEven ? Colors.grey[50] : Colors.white,
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.grey[400]!,
                                              width: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 3,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(
                                                      color: Colors.grey[400]!,
                                                      width: 0.3,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    fontSize: 7,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 3,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(
                                                      color: Colors.grey[400]!,
                                                      width: 0.3,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  item['name'],
                                                  style: TextStyle(
                                                    fontSize: 7,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 3,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(
                                                      color: Colors.grey[400]!,
                                                      width: 0.3,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  '${item['qty']}',
                                                  style: TextStyle(
                                                    fontSize: 7,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 3,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(
                                                      color: Colors.grey[400]!,
                                                      width: 0.3,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Rs. ${_formatPrice(item['price'])}',
                                                  style: TextStyle(
                                                    fontSize: 7,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 3,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    right: BorderSide(
                                                      color: Colors.grey[400]!,
                                                      width: 0.3,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Rs. ${_formatPrice(itemTax)} (${gstValue.toStringAsFixed(1)}%)',
                                                  style: TextStyle(
                                                    fontSize: 6,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 3,
                                                  vertical: 3,
                                                ),
                                                child: Text(
                                                  'Rs. ${_formatPrice(itemTotalWithTax)}',
                                                  style: TextStyle(
                                                    fontSize: 7,
                                                    fontWeight: FontWeight.bold,
                                                    color: selectedPrimaryColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),

                              // Ultra-Compact GST Breakdown
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 0.3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Table Header - Ultra-Compact
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        border: Border.all(
                                          color: Colors.grey[400]!,
                                          width: 0.3,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'HSN/SAC',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'Taxable Value',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[800],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'CGST',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'SGST',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 4,
                                              ),
                                              child: Text(
                                                'Total GST',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Tax Row - Ultra-Compact
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.grey[400]!,
                                            width: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'GST',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'Rs. ${_formatPrice(_calculateSubtotal())}',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '9.0%',
                                                    style: TextStyle(
                                                      fontSize: 5,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  Text(
                                                    'Rs. ${_formatPrice(_calculateCGST())}',
                                                    style: TextStyle(
                                                      fontSize: 7,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey[400]!,
                                                    width: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '9.0%',
                                                    style: TextStyle(
                                                      fontSize: 5,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  Text(
                                                    'Rs. ${_formatPrice(_calculateSGST())}',
                                                    style: TextStyle(
                                                      fontSize: 7,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                                vertical: 3,
                                              ),
                                              child: Text(
                                                'Rs. ${_formatPrice(_calculateTotalTax())}',
                                                style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: selectedPrimaryColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Ultra-Compact Summary Section
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 0.3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Summary Rows - Ultra-Compact
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Subtotal:',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          'Rs. ${_formatPrice(_calculateSubtotal())}',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.grey[300]!,
                                            width: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'TOTAL:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: selectedPrimaryColor,
                                            ),
                                          ),
                                          Text(
                                            'Rs. ${_formatPrice(_calculateSubtotal() + _calculateTotalTax())}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: selectedPrimaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Ultra-Compact Amount in Words
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                      width: 0.3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Amount in Words:',
                                      style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      _amountInWords(_calculateSubtotal() + _calculateTotalTax()),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: selectedPrimaryColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Ultra-Compact Footer
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(3),
                                    bottomRight: Radius.circular(3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Thank you for your business!',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              color: selectedPrimaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            'ACT T CONNECT',
                                            style: TextStyle(
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Invoice created using ACT T Connect',
                                            style: TextStyle(
                                              fontSize: 5,
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                                             const SizedBox(height: 20),
                       
                       // Color Customization Section
                       Text(
                         'Customize Colors',
                         style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w600,
                           color: Colors.black87,
                           fontFamily: GoogleFonts.openSans().fontFamily,
                         ),
                       ),
                       const SizedBox(height: 12),
                       
                       // Primary Color Palette Only
                       _buildColorPalette(
                         title: 'Primary Color',
                         colors: primaryColors,
                         selectedColor: selectedPrimaryColor,
                         onColorSelected: (color) {
                           setState(() {
                             selectedPrimaryColor = color;
                           });
                         },
                       ),
                       
                       const SizedBox(height: 20),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Save color settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Color settings saved successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette({
    required String title,
    required List<Color> colors,
    required Color selectedColor,
    required Function(Color) onColorSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: colors.map((color) {
                bool isSelected = color == selectedColor;
                return GestureDetector(
                  onTap: () => onColorSelected(color),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 1),
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: isSelected ? 2 : 0,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for calculations
  double _calculateSubtotal() {
    return sampleItems.fold(0.0, (sum, item) => sum + (item['qty'] * item['price']));
  }

  double _calculateTotalTax() {
    return sampleItems.fold(0.0, (sum, item) {
      final itemTotal = item['qty'] * item['price'];
      final gstValue = item['gst'] != null ? double.tryParse(item['gst'].toString()) ?? 0.0 : 0.0;
      return sum + (itemTotal * gstValue / 100);
    });
  }

  double _calculateCGST() {
    return _calculateTotalTax() / 2;
  }

  double _calculateSGST() {
    return _calculateTotalTax() / 2;
  }

  String _formatPrice(double price) {
    if (price == price.floor()) {
      return price.floor().toString();
    } else {
      return price.toStringAsFixed(2);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      '01', '02', '03', '04', '05', '06',
      '07', '08', '09', '10', '11', '12'
    ];
    return '${date.day.toString().padLeft(2, '0')}/${months[date.month - 1]}/${date.year}';
  }

  String _amountInWords(double amount) {
    if (amount == 0) return 'Zero Rupees';

    final rupees = amount.floor();
    final paise = ((amount - rupees) * 100).round();

    String result = '';

    if (rupees > 0) {
      result += '${_numberToWords(rupees)} Rupees';
    }

    if (paise > 0) {
      if (result.isNotEmpty) result += ' and ';
      result += '${_numberToWords(paise)} Paise';
    }

    return result;
  }

  String _numberToWords(int number) {
    if (number == 0) return 'Zero';

    final units = [
      '', 'One', 'Two', 'Three', 'Four', 'Five',
      'Six', 'Seven', 'Eight', 'Nine',
    ];
    final teens = [
      'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen',
      'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen',
    ];
    final tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty',
      'Sixty', 'Seventy', 'Eighty', 'Ninety',
    ];

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

    return number.toString();
  }
}
