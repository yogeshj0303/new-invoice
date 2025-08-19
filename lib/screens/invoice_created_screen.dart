import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';

class InvoiceCreatedScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double discount;
  final double tax;
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
    required this.total,
    required this.invoiceNumber,
    required this.date,
    this.customerName = '',
    this.customerPhone = '',
    this.notes = '',
    this.paymentType = 'Cash',
    this.amountReceived = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Theme colors matching the app
    const Color primaryColor = Color(0xFF2E3085);
    const Color secondaryColor = Color(0xFF4E4AA8);
    const Color backgroundColor = Color(0xFFFAFBFC);
    const Color cardColor = Colors.white;
    const Color successColor = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Invoice Created',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate back to create invoice screen to edit
              Navigator.pop(context);
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Edit Invoice',
          ),
                     IconButton(
                           onPressed: () {
                // Navigate to invoice settings screen
                Navigator.pushNamed(context, '/invoice-settings');
              },
             icon: const Icon(Icons.settings, color: Colors.white),
             tooltip: 'Invoice Settings',
           ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(2),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
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
                          bottom: BorderSide(color: Colors.grey[300]!, width: 0.3),
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
                                        color: primaryColor,
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
                                            color: primaryColor,
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
                                  border: Border.all(color: Colors.grey[300]!),
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
                                      invoiceNumber,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
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
                                      _formatDate(date),
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
                          bottom: BorderSide(color: Colors.grey[300]!, width: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Table Header - Ultra-Compact
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border.all(color: Colors.grey[400]!, width: 0.3),
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      'TAX',
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
                          ...items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final itemTotal = item['qty'] * item['price'];
                            final itemTax = itemTotal * (item['taxRate'] ?? 0) / 100;
                            final itemTotalWithTax = itemTotal + itemTax;
                            
                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: index.isEven ? Colors.grey[50] : Colors.white,
                                border: Border(
                                  top: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                          right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                          right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                          right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                          right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                          right: BorderSide(color: Colors.grey[400]!, width: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                                                                 'Rs. ${_formatPrice(itemTax)} (${(item['taxRate'] ?? 0).toStringAsFixed(1)}%)',
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
                                          color: primaryColor,
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
                          bottom: BorderSide(color: Colors.grey[300]!, width: 0.3),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tax (${_getTaxRate().toStringAsFixed(1)}%):',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                                                       'Rs. ${_formatPrice(_calculateTotalTax())}',
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
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey[300]!, width: 0.3),
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
                                    color: primaryColor,
                                  ),
                                ),
                                Text(
                                  'Rs. ${_formatPrice(_calculateSubtotal() + _calculateTotalTax())}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (amountReceived > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'RECEIVED:',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                                                     'Rs. ${_formatPrice(amountReceived)}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'BALANCE:',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                                                     'Rs. ${_formatPrice(amountReceived - (_calculateSubtotal() + _calculateTotalTax()))}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Ultra-Compact Tax Breakdown
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!, width: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Table Header - Ultra-Compact
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border.all(color: Colors.grey[400]!, width: 0.3),
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      'Taxable Value',
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                      'Total Tax',
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
                                top: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${(_getTaxRate() / 2).toStringAsFixed(1)}%',
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
                                        right: BorderSide(color: Colors.grey[400]!, width: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${(_getTaxRate() / 2).toStringAsFixed(1)}%',
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
                                        color: primaryColor,
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
                    
                    // Ultra-Compact Amount in Words
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!, width: 0.3),
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
                              color: primaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Ultra-Compact Terms
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!, width: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms:',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '1. Goods once sold will not be taken back or exchanged',
                            style: TextStyle(
                              fontSize: 6,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '2. All disputes are subject to local jurisdiction only',
                            style: TextStyle(
                              fontSize: 6,
                              color: Colors.grey[700],
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
                                    color: primaryColor,
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
        ),
      ),
      
      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8),
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
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _shareInvoice(context),
                icon: const Icon(Icons.share, size: 20),
                label: const Text('Share', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                child: const Text('Done', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, [Color? valueColor, bool isTotal = false]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '01', '02', '03', '04', '05', '06',
      '07', '08', '09', '10', '11', '12'
    ];
    return '${date.day.toString().padLeft(2, '0')}/${months[date.month - 1]}/${date.year}';
  }

  String _amountInWords(double amount) {
    // Simple implementation for amount in words
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

  double _calculateSubtotal() {
    double subtotal = 0;
    for (var item in items) {
      subtotal += (item['qty'] * item['price']);
    }
    return subtotal;
  }

  double _calculateTotalTax() {
    double totalTax = 0;
    for (var item in items) {
      final itemTotal = item['qty'] * item['price'];
      final itemTax = itemTotal * (item['taxRate'] ?? 0) / 100;
      totalTax += itemTax;
    }
    return totalTax;
  }

  double _getTaxRate() {
    if (items.isEmpty) return 0;
    // Get the tax rate from the first item, assuming all items have the same tax rate
    return items.first['taxRate'] ?? 0;
  }

  String _formatPrice(double price) {
    if (price == price.floor()) {
      return price.floor().toString();
    } else {
      return price.toStringAsFixed(2);
    }
  }

  String _formatCurrency(double amount) {
    // Use "Rs." instead of "₹" for better PDF compatibility
    return 'Rs. ${_formatPrice(amount)}';
  }

  double _calculateCGST() {
    return _calculateTotalTax() / 2;
  }

  double _calculateSGST() {
    return _calculateTotalTax() / 2;
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
    
    return number.toString();
  }

  // Preview functionality
  Future<void> _previewInvoice(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Generating PDF preview...'),
            ],
          ),
        );
      },
    );

    try {
      final pdf = await _generatePDF();
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf,
          name: 'Invoice_$invoiceNumber',
        );
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice preview opened successfully!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error previewing invoice: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _previewInvoice(context),
            ),
          ),
        );
      }
    }
  }

  // Share functionality
  Future<void> _shareInvoice(BuildContext context) async {
  CircularProgressIndicator();

    try {
      final pdf = await _generatePDF();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Invoice_$invoiceNumber.pdf');
      await file.writeAsBytes(pdf);
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Invoice $invoiceNumber from ACT T CONNECT',
          subject: 'Invoice $invoiceNumber',
        );
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing invoice: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _shareInvoice(context),
            ),
          ),
        );
      }
    }
  }

  // Generate PDF
  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();
    
        pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ACT T CONNECT',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          'Professional Business Solutions',
                          style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Block no 9, South Avenue, Shahpura',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Bhopal, Madhya Pradesh 462039, India',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Mobile: +1 (555) 123-4567',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(15),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey400),
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Column(
                            children: [
                              pw.Text(
                                'Invoice No.',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                invoiceNumber,
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue900,
                                ),
                              ),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                'Invoice Date',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                _formatDate(date),
                                style: pw.TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Customer Info
                if (customerName.isNotEmpty || customerPhone.isNotEmpty) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Bill To:',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (customerName.isNotEmpty)
                          pw.Text('Name: $customerName', style: pw.TextStyle(fontSize: 14)),
                        if (customerPhone.isNotEmpty)
                          pw.Text('Phone: $customerPhone', style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],
                
                // Items Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('S.No', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Rate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Tax', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Items
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final itemTotal = item['qty'] * item['price'];
                      final itemTax = itemTotal * (item['taxRate'] ?? 0) / 100;
                      final itemTotalWithTax = itemTotal + itemTax;
                      
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('${index + 1}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item['name']),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('${item['qty']}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Rs. ${_formatPrice(item['price'])}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Rs. ${_formatPrice(itemTax)}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Rs. ${_formatPrice(itemTotalWithTax)}'),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                
                pw.SizedBox(height: 20),
                
                // Summary
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Subtotal:', style: pw.TextStyle(fontSize: 16)),
                                                     pw.Text('Rs. ${_formatPrice(_calculateSubtotal())}', style: pw.TextStyle(fontSize: 16)),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Tax (${_getTaxRate().toStringAsFixed(1)}%):', style: pw.TextStyle(fontSize: 16)),
                                                     pw.Text('Rs. ${_formatPrice(_calculateTotalTax())}', style: pw.TextStyle(fontSize: 16)),
                        ],
                      ),
                      pw.Divider(),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'TOTAL:',
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                                                               'Rs. ${_formatPrice(_calculateSubtotal() + _calculateTotalTax())}',
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                        ],
                      ),
                      if (amountReceived > 0) ...[
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Amount Received:', style: pw.TextStyle(fontSize: 16)),
                            pw.Text('Rs. ${_formatPrice(amountReceived)}', style: pw.TextStyle(fontSize: 16)),
                          ],
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Balance:', style: pw.TextStyle(fontSize: 16)),
                            pw.Text('Rs. ${_formatPrice(amountReceived - (_calculateSubtotal() + _calculateTotalTax()))}', style: pw.TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Amount in Words
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Amount in Words:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        _amountInWords(_calculateSubtotal() + _calculateTotalTax()),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Terms
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Terms:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text('1. Goods once sold will not be taken back or exchanged'),
                      pw.Text('2. All disputes are subject to local jurisdiction only'),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Payment Information
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Payment Information:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Payment Method:', style: pw.TextStyle(fontSize: 14)),
                          pw.Text(paymentType, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Due Date:', style: pw.TextStyle(fontSize: 14)),
                          pw.Text(_formatDate(date.add(const Duration(days: 30))), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      if (notes.isNotEmpty) ...[
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Notes:',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(notes, style: pw.TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Payment QR Code Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Digital Payment Options',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Scan QR code to pay digitally',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        width: 100,
                        height: 100,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey400),
                          color: PdfColors.white,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'QR\nCODE',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'UPI ID: acttconnect@upi',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 30),
                
                // Footer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Thank you for your business!',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      'ACT T CONNECT',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    
    return pdf.save();
  }
}
