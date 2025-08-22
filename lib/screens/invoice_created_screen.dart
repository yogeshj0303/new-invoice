import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'invoice_template_screen.dart';
import 'create_invoice.dart';

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
    this.customerName = '',
    this.customerPhone = '',
    this.notes = '',
    this.paymentType = 'Cash',
    this.amountReceived = 0,
  });

  @override
  State<InvoiceCreatedScreen> createState() => _InvoiceCreatedScreenState();
}

class _InvoiceCreatedScreenState extends State<InvoiceCreatedScreen> {
  bool showColorPalette = false;
  Color selectedColor = Colors.indigo; // Default color



  Widget _buildColorOption(Color color, String label) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
          showColorPalette = false; // Hide palette after selection
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                color: isSelected ? Colors.black : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

                // _navigateToEditInvoice();
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
  }

  void _navigateToEditInvoice() {
    // Navigate to create invoice screen with current invoice data for editing
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreateInvoiceScreen(
          cartItems: widget.items,
          itemQuantities: null, // We'll handle quantities in the items themselves
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
    // Default tax rate if not specified
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
    final pdf = pw.Document();
    
    // Create PDF content that matches the InvoiceTemplate layout
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header - matching InvoiceTemplate
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
                            color: PdfColor.fromHex(selectedColor.value.toRadixString(16).substring(2)),
                          ),
                        ),
                        pw.Text(
                          'Professional Business Solutions',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text('Block no 9, South Avenue, Shahpura'),
                        pw.Text('Bhopal, Madhya Pradesh 462039, India'),
                        pw.Text('Mobile: +91 9826000000'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text('Invoice No: ${widget.invoiceNumber}'),
                        pw.Text('Date: ${_formatDate(widget.date)}'),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 20),
                
                // Customer Info
                if (widget.customerName.isNotEmpty) ...[
                  pw.Text(
                    'Bill To:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(widget.customerName),
                  if (widget.customerPhone.isNotEmpty) pw.Text(widget.customerPhone),
                  pw.SizedBox(height: 20),
                ],
                
                // Items Table - matching InvoiceTemplate structure
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Text('S.NO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('ITEMS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('QTY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('RATE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('GST', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('AMOUNT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    ...widget.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final itemTotal = item['qty'] * item['price'];
                      final gstValue = item['gst'] != null ? double.tryParse(item['gst'].toString()) ?? 0.0 : 0.0;
                      final itemTax = itemTotal * gstValue / 100;
                      final itemTotalWithTax = itemTotal + itemTax;
                      
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: index.isEven ? PdfColors.grey50 : PdfColors.white,
                        ),
                        children: [
                          pw.Text('${index + 1}'),
                          pw.Text(item['name']),
                          pw.Text('${item['qty']}'),
                          pw.Text('Rs. ${_formatPrice(item['price'])}'),
                          pw.Text('Rs. ${_formatPrice(itemTax)} (${gstValue.toStringAsFixed(1)}%)'),
                          pw.Text(
                            'Rs. ${_formatPrice(itemTotalWithTax)}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                
                // Additional Charges Table (if any)
                if (widget.additionalCharges.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey100),
                        children: [
                          pw.Text('S.NO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Additional Charges', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      ...widget.additionalCharges.asMap().entries.map((entry) {
                        final index = entry.key;
                        final charge = entry.value;
                        
                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: index.isEven ? PdfColors.grey50 : PdfColors.white,
                          ),
                          children: [
                            pw.Text('${index + 1}'),
                            pw.Text(charge['name']),
                            pw.Text('Rs. ${_formatPrice(charge['price'])}'),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
                
                pw.SizedBox(height: 20),
                
                // GST Breakdown - matching InvoiceTemplate
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Text('HSN/SAC', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Taxable Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('CGST', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('SGST', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Total GST', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Text('GST'),
                        pw.Text('Rs. ${_formatPrice(_calculateSubtotal())}'),
                        pw.Text('${(_getTaxRate() / 2).toStringAsFixed(1)}%\nRs. ${_formatPrice(_calculateCGST())}'),
                        pw.Text('${(_getTaxRate() / 2).toStringAsFixed(1)}%\nRs. ${_formatPrice(_calculateSGST())}'),
                        pw.Text(
                          'Rs. ${_formatPrice(_calculateTotalTax())}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 20),
                
                // Summary - matching InvoiceTemplate
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                                              pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('Rs. ${_formatPrice(_calculateSubtotal())}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      if (widget.additionalCharges.isNotEmpty) ...[
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Additional Charges:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('Rs. ${_formatPrice(widget.additionalChargesTotal)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ],
                      if (widget.discount > 0) ...[
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Discount:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('- Rs. ${_formatPrice(widget.discount)}', style: pw.TextStyle(color: PdfColors.red600)),
                          ],
                        ),
                      ],
                      if (widget.roundoff != 0) ...[
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Roundoff (Decimal):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                              widget.roundoff > 0
                                  ? '+ Rs. ${_formatPrice(widget.roundoff)}'
                                  : '- Rs. ${_formatPrice(widget.roundoff * -1)}',
                              style: pw.TextStyle(
                                color: widget.roundoff > 0 ? PdfColors.green600 : PdfColors.red600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      pw.SizedBox(height: 10),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 5),
                        decoration: pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'TOTAL:',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex(selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)),
                              ),
                            ),
                            pw.Text(
                              'Rs. ${_formatPrice(widget.total)}',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex(selectedColor.value.toRadixString(16).substring(2)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.amountReceived > 0) ...[
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('RECEIVED:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('Rs. ${_formatPrice(widget.amountReceived)}', style: pw.TextStyle(color: PdfColors.green600)),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('BALANCE:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('Rs. ${_formatPrice(widget.amountReceived - widget.total)}', style: pw.TextStyle(color: PdfColors.blue600)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Amount in Words
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Amount in Words:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        _amountInWords(widget.total),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColor.fromHex(selectedColor.value.toRadixString(16).substring(2)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Terms
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Terms:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text('1. Goods once sold will not be taken back or exchanged'),
                      pw.Text('2. All disputes are subject to local jurisdiction only'),
                    ],
                  ),
                ),
                
                // Footer
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Thank you for your business!',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex(selectedColor.value.toRadixString(16).substring(2)),
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'ACT T CONNECT',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Invoice created using ACT T Connect',
                              style: pw.TextStyle(
                                fontStyle: pw.FontStyle.italic,
                                color: PdfColors.grey600,
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
      ),
    );
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _shareInvoice(BuildContext context) async {
    try {
      final pdf = pw.Document();
      
      // Create PDF content that matches the InvoiceTemplate layout (same as preview)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header - matching InvoiceTemplate
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
                              color: PdfColor.fromHex(selectedColor.value.toRadixString(16).substring(2)),
                            ),
                          ),
                          pw.Text(
                            'Professional Business Solutions',
                            style: pw.TextStyle(fontSize: 14),
                          ),
                          pw.Text('Block no 9, South Avenue, Shahpura'),
                          pw.Text('Bhopal, Madhya Pradesh 462039, India'),
                          pw.Text('Mobile: +91 9826000000'),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'INVOICE',
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text('Invoice No: ${widget.invoiceNumber}'),
                          pw.Text('Date: ${_formatDate(widget.date)}'),
                        ],
                      ),
                    ],
                  ),
                  
                  pw.SizedBox(height: 20),
                  
                  // Customer Info
                  if (widget.customerName.isNotEmpty) ...[
                    pw.Text(
                      'Bill To:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(widget.customerName),
                    if (widget.customerPhone.isNotEmpty) pw.Text(widget.customerPhone),
                    pw.SizedBox(height: 20),
                  ],
                  
                  // Items Table - matching InvoiceTemplate structure
                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey100),
                        children: [
                          pw.Text('S.NO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('ITEMS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('QTY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('RATE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('GST', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('AMOUNT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      ...widget.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final itemTotal = item['qty'] * item['price'];
                        final gstValue = item['gst'] != null ? double.tryParse(item['gst'].toString()) ?? 0.0 : 0.0;
                        final itemTax = itemTotal * gstValue / 100;
                        final itemTotalWithTax = itemTotal + itemTax;
                        
                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: index.isEven ? PdfColors.grey50 : PdfColors.white,
                          ),
                          children: [
                            pw.Text('${index + 1}'),
                            pw.Text(item['name']),
                            pw.Text('${item['qty']}'),
                            pw.Text('Rs. ${_formatPrice(item['price'])}'),
                            pw.Text('Rs. ${_formatPrice(itemTax)} (${gstValue.toStringAsFixed(1)}%)'),
                            pw.Text(
                              'Rs. ${_formatPrice(itemTotalWithTax)}',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                  
                  // Additional Charges Table (if any)
                  if (widget.additionalCharges.isNotEmpty) ...[
                    pw.SizedBox(height: 20),
                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColors.grey100),
                          children: [
                            pw.Text('S.NO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('Additional Charges', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                        ...widget.additionalCharges.asMap().entries.map((entry) {
                          final index = entry.key;
                          final charge = entry.value;
                          
                          return pw.TableRow(
                            decoration: pw.BoxDecoration(
                              color: index.isEven ? PdfColors.grey50 : PdfColors.white,
                            ),
                            children: [
                              pw.Text('${index + 1}'),
                              pw.Text(charge['name']),
                              pw.Text('Rs. ${_formatPrice(charge['price'])}'),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                  
                  pw.SizedBox(height: 20),
                  
                  // GST Breakdown - matching InvoiceTemplate
                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey100),
                        children: [
                          pw.Text('HSN/SAC', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Taxable Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('CGST', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('SGST', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Total GST', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text('GST'),
                          pw.Text('Rs. ${_formatPrice(_calculateSubtotal())}'),
                          pw.Text('${(_getTaxRate() / 2).toStringAsFixed(1)}%\nRs. ${_formatPrice(_calculateCGST())}'),
                          pw.Text('${(_getTaxRate() / 2).toStringAsFixed(1)}%\nRs. ${_formatPrice(_calculateSGST())}'),
                          pw.Text(
                            'Rs. ${_formatPrice(_calculateTotalTax())}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  pw.SizedBox(height: 20),
                  
                  // Summary - matching InvoiceTemplate
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('Rs. ${_formatPrice(_calculateSubtotal())}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                        if (widget.additionalCharges.isNotEmpty) ...[
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Additional Charges:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text('Rs. ${_formatPrice(widget.additionalChargesTotal)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ],
                        if (widget.discount > 0) ...[
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Discount:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text('- Rs. ${_formatPrice(widget.discount)}', style: pw.TextStyle(color: PdfColors.red600)),
                            ],
                          ),
                        ],
                        if (widget.roundoff != 0) ...[
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Roundoff (Decimal):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text(
                                widget.roundoff > 0
                                    ? '+ Rs. ${_formatPrice(widget.roundoff)}'
                                    : '- Rs. ${_formatPrice(widget.roundoff * -1)}',
                                style: pw.TextStyle(
                                  color: widget.roundoff > 0 ? PdfColors.green600 : PdfColors.red600,
                                ),
                              ),
                            ],
                          ),
                        ],
                        pw.SizedBox(height: 10),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 5),
                          decoration: pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
                          ),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'TOTAL:',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex(selectedColor.value.toRadixString(16).substring(2)),
                                ),
                              ),
                              pw.Text(
                                'Rs. ${_formatPrice(widget.total)}',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex(selectedColor.value.toRadixString(16).substring(2)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.amountReceived > 0) ...[
                          pw.SizedBox(height: 10),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('RECEIVED:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text('Rs. ${_formatPrice(widget.amountReceived)}', style: pw.TextStyle(color: PdfColors.green600)),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('BALANCE:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text('Rs. ${_formatPrice(widget.amountReceived - widget.total)}', style: pw.TextStyle(color: PdfColors.blue600)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Amount in Words
                  pw.SizedBox(height: 20),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Amount in Words:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          _amountInWords(widget.total),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColor.fromHex(selectedColor.value.toRadixString(16).substring(2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Terms
                  pw.SizedBox(height: 20),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Terms:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text('1. Goods once sold will not be taken back or exchanged'),
                        pw.Text('2. All disputes are subject to local jurisdiction only'),
                      ],
                    ),
                  ),
                  
                  // Footer
                  pw.SizedBox(height: 20),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Thank you for your business!',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex(selectedColor.value.toRadixString(16).substring(2)),
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                'ACT T CONNECT',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                'Invoice created using ACT T Connect',
                                style: pw.TextStyle(
                                  fontStyle: pw.FontStyle.italic,
                                  color: PdfColors.grey600,
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
        ),
      );
      
      final bytes = await pdf.save();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/invoice_${widget.invoiceNumber}.pdf');
      await file.writeAsBytes(bytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Invoice ${widget.invoiceNumber} from ACT T CONNECT',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing invoice: $e')),
      );
    }
  }
}
