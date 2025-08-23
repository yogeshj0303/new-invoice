import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/contact_service.dart';
import '../services/terms_service.dart';
import '../services/invoice_numbering_service.dart';
import '../services/discount_settings_service.dart';
import '../services/digital_signature_service.dart';

class InvoiceTemplate extends StatelessWidget {
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
  final Color primaryColor;

  const InvoiceTemplate({
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
    this.customerName = '',
    this.customerPhone = '',
    this.notes = '',
    this.paymentType = 'Cash',
    this.amountReceived = 0,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer4<ContactService, TermsService, InvoiceNumberingService, DigitalSignatureService>(
      builder: (context, contactService, termsService, invoiceNumberingService, digitalSignatureService, child) {
        return Container(
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
                                contactService.companyName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                contactService.companyDescription,
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
                      if (contactService.address1.isNotEmpty)
                        Text(
                          contactService.address1,
                          style: TextStyle(
                            fontSize: 7,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (contactService.address2.isNotEmpty)
                        Text(
                          contactService.address2,
                          style: TextStyle(
                            fontSize: 7,
                            color: Colors.grey[700],
                          ),
                        ),
                      if (contactService.phone.isNotEmpty)
                        Text(
                          'Mobile: ${contactService.phone}',
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
                              invoiceNumber.isNotEmpty 
                                  ? '${invoiceNumberingService.prefix}${invoiceNumberingService.separator}${invoiceNumber}'
                                  : '${invoiceNumberingService.prefix}${invoiceNumberingService.separator}${invoiceNumberingService.currentNumber}',
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
                ...items.asMap().entries.map((entry) {
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
                              'Rs. ${_formatPrice(itemTax)} (${_getItemGSTRate(item).toStringAsFixed(1)}%)',
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

          // Additional Charges Table (if any)
          if (additionalCharges.isNotEmpty) ...[
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
                  // Additional Charges Header
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
                          flex: 4,
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
                              'Additional Charges',
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
                              'Amount',
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
                  // Additional Charges Rows
                  ...additionalCharges.asMap().entries.map((entry) {
                    final index = entry.key;
                    final charge = entry.value;

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
                            flex: 4,
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
                                charge['name'],
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
                              child: Text(
                                'Rs. ${_formatPrice(charge['price'])}',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
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
          ],

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
                              right: BorderSide(
                                color: Colors.grey[400]!,
                                width: 0.3,
                              ),
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
                          child: Consumer<DiscountSettingsService>(
                            builder: (context, discountService, child) {
                              final calculatedTax = discountService.isDiscountBeforeTax 
                                ? _calculateTotalTaxOnAmount(_calculateSubtotal() - discount)
                                : _calculateTotalTax();
                              return Text(
                                'Rs. ${_formatPrice(calculatedTax)}',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
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
                if (additionalCharges.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Additional Charges:',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        'Rs. ${_formatPrice(additionalChargesTotal)}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
                if (discount > 0) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discount:',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '- Rs. ${_formatPrice(discount)}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ],
                if (roundoff != 0) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Roundoff (Decimal):',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        roundoff > 0
                            ? '+ Rs. ${_formatPrice(roundoff)}'
                            : '- Rs. ${_formatPrice(roundoff * -1)}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: roundoff > 0 ? Colors.green[600] : Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ],
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
                          color: primaryColor,
                        ),
                      ),
                      Consumer<DiscountSettingsService>(
                        builder: (context, discountService, child) {
                          final calculatedTax = discountService.isDiscountBeforeTax 
                            ? _calculateTotalTaxOnAmount(_calculateSubtotal() - discount)
                            : _calculateTotalTax();
                          return Text(
                            'Rs. ${_formatPrice(discountService.calculateTotal(
                              subtotal: _calculateSubtotal(),
                              discount: discount,
                              tax: calculatedTax,
                              additionalCharges: additionalChargesTotal,
                              roundoff: roundoff,
                            ))}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          );
                        },
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
                      Consumer<DiscountSettingsService>(
                        builder: (context, discountService, child) {
                          final calculatedTax = discountService.isDiscountBeforeTax 
                            ? _calculateTotalTaxOnAmount(_calculateSubtotal() - discount)
                            : _calculateTotalTax();
                          return Text(
                            'Rs. ${_formatPrice(amountReceived - discountService.calculateTotal(
                              subtotal: _calculateSubtotal(),
                              discount: discount,
                              tax: calculatedTax,
                              additionalCharges: additionalChargesTotal,
                              roundoff: roundoff,
                            ))}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
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
                Consumer<DiscountSettingsService>(
                  builder: (context, discountService, child) {
                    final calculatedTax = discountService.isDiscountBeforeTax 
                      ? _calculateTotalTaxOnAmount(_calculateSubtotal() - discount)
                      : _calculateTotalTax();
                    return Text(
                      _amountInWords(
                        discountService.calculateTotal(
                          subtotal: _calculateSubtotal(),
                          discount: discount,
                          tax: calculatedTax,
                          additionalCharges: additionalChargesTotal,
                          roundoff: roundoff,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  },
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
                  'Terms & Conditions:',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                if (termsService.terms.isNotEmpty)
                  ...termsService.terms.map((term) => Text(
                    term,
                    style: TextStyle(
                      fontSize: 6,
                      color: Colors.grey[700],
                    ),
                  )).toList()
                else
                  Text(
                    '1. Goods once sold will not be taken back or exchanged',
                    style: TextStyle(
                      fontSize: 6,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),

          // Ultra-Compact Digital Signature
          if (digitalSignatureService.hasSignature)
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Digital Signature:',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.memory(
                              digitalSignatureService.signature!,
                              fit: BoxFit.contain,
                            ),
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
                          'Authorized Signatory',
                          style: TextStyle(
                            fontSize: 6,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 1,
                          color: Colors.grey[400],
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
                          contactService.companyName,
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
    );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '01', '02', '03', '04', '05', '06',
      '07', '08', '09', '10', '11', '12',
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
      final gstValue = item['gst'] != null ? double.tryParse(item['gst'].toString()) ?? 0.0 : 0.0;
      final itemTax = itemTotal * gstValue / 100;
      totalTax += itemTax;
    }
    return totalTax;
  }

  double _calculateTotalTaxOnAmount(double amount) {
    double totalTax = 0;
    for (var item in items) {
      final itemTotal = item['qty'] * item['price'];
      final gstValue = item['gst'] != null ? double.tryParse(item['gst'].toString()) ?? 0.0 : 0.0;
      // Calculate tax proportionally based on the amount
      final itemTax = (itemTotal / _calculateSubtotal()) * amount * gstValue / 100;
      totalTax += itemTax;
    }
    return totalTax;
  }

  double _getTaxRate() {
    if (items.isEmpty) return 0;
    final gstValue = items.first['gst'] != null ? double.tryParse(items.first['gst'].toString()) ?? 0.0 : 0.0;
    return gstValue > 0 ? gstValue : (items.first['taxRate'] ?? 0);
  }

  double _getItemGSTRate(Map<String, dynamic> item) {
    final gstValue = item['gst'] != null ? double.tryParse(item['gst'].toString()) ?? 0.0 : 0.0;
    return gstValue > 0 ? gstValue : (item['taxRate'] ?? 0);
  }

  String _formatPrice(double price) {
    if (price == price.floor()) {
      return price.floor().toString();
    } else {
      return price.toStringAsFixed(2);
    }
  }

  double _calculateCGST() {
    // This method is used in contexts where we don't have access to DiscountSettingsService
    // The actual tax calculation should be done in the Consumer widgets
    return _calculateTotalTax() / 2;
  }

  double _calculateSGST() {
    // This method is used in contexts where we don't have access to DiscountSettingsService
    // The actual tax calculation should be done in the Consumer widgets
    return _calculateTotalTax() / 2;
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
