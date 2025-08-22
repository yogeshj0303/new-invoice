import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoicePhoneSettingsScreen extends StatefulWidget {
  const InvoicePhoneSettingsScreen({super.key});

  @override
  State<InvoicePhoneSettingsScreen> createState() => _InvoicePhoneSettingsScreenState();
}

class _InvoicePhoneSettingsScreenState extends State<InvoicePhoneSettingsScreen> {
  String selectedPhoneNumber = '+1 (555) 123-4567';
  final TextEditingController _phoneController = TextEditingController();
  
  // Sample phone numbers for quick selection
  final List<String> samplePhoneNumbers = [
    '+1 (555) 123-4567',
    '+91 98765 43210',
    '+44 20 7946 0958',
    '+61 2 9876 5432',
    '+86 10 1234 5678',
    '+81 3 1234 5678',
  ];

  // Sample data for template preview
  final List<Map<String, dynamic>> sampleItems = [
    {'name': 'Sample Item 1', 'qty': 2, 'price': 100.0, 'gst': 18.0},
    {'name': 'Sample Item 2', 'qty': 1, 'price': 150.0, 'gst': 18.0},
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.text = selectedPhoneNumber;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showPhoneNumberBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customize Phone Number',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: GoogleFonts.openSans().fontFamily,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Custom phone number input
              Text(
                'Enter Custom Phone Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2E3085), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedPhoneNumber = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              // Quick select phone numbers
              Text(
                'Quick Select',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: samplePhoneNumbers.map((phone) {
                  bool isSelected = phone == selectedPhoneNumber;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPhoneNumber = phone;
                        _phoneController.text = phone;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2E3085) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2E3085) : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              
              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3085),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3085), size: 18),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(32, 32),
            ),
          ),
        ),
        title: Text(
          'Phone Settings',
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
                      
                      // Invoice Template Preview
                      Center(
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 3.0,
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
                                                    color: const Color(0xFF2E3085),
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
                                                    const Text(
                                                      'ACT T CONNECT',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF2E3085),
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
                                              'Mobile: $selectedPhoneNumber',
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
                                                const Text(
                                                  'INV-001',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2E3085),
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
                                                      color: const Color(0xFF2E3085),
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
                                                color: const Color(0xFF2E3085),
                                              ),
                                            ),
                                            Text(
                                              'Rs. ${_formatPrice(_calculateSubtotal() + _calculateTotalTax())}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF2E3085),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Ultra-Compact Footer
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
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
                                            const Text(
                                              'Thank you for your business!',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2E3085),
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
                      ),
                      const SizedBox(height: 20),
                      
                      // Phone Number Customization Section
                      Text(
                        'Customize Phone Number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: GoogleFonts.openSans().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Current phone number display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Phone Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: const Color(0xFF2E3085),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  selectedPhoneNumber,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Customize button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showPhoneNumberBottomSheet,
                          icon: const Icon(Icons.edit),
                          label: const Text('Customize Phone Number'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E3085),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Save phone number settings and navigate back
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Phone number settings saved successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Navigate back after a short delay to show the SnackBar
                            Future.delayed(const Duration(milliseconds: 500), () {
                              Navigator.of(context).pop();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E3085),
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
}
