import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../models/business_profile.dart';
import '../models/detailed_invoice.dart';
import '../services/api_service.dart';
import '../services/theme_service.dart';
import '../services/invoice_numbering_service.dart';
import 'package:provider/provider.dart';
import 'invoice_template_screen.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;
  final BusinessProfile? businessProfile;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    this.businessProfile,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  DetailedInvoice? _detailedInvoice;
  bool _isLoading = true;
  String? _error;
  late ThemeService _themeService;
  Color selectedColor = const Color(0xFF2E3085);

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    // Initialize with current theme color
    selectedColor = _themeService.primaryColor;
    _loadDetailedInvoice();
  }

  Future<void> _loadDetailedInvoice() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First try to get detailed invoice from API
      final result = await ApiService.getDetailedInvoice(widget.transaction.invoiceId);
      
      if (result['success'] == true && result['detailedInvoice'] != null) {
        setState(() {
          _detailedInvoice = result['detailedInvoice'];
          _isLoading = false;
        });
      } else {
        // If API fails, try to create invoice data from transaction
        print('⚠️ [DEBUG] API failed, trying fallback method');
        final fallbackResult = await ApiService.getInvoiceDataFromTransaction(widget.transaction);
        
        if (fallbackResult['success'] == true && fallbackResult['detailedInvoice'] != null) {
          setState(() {
            _detailedInvoice = fallbackResult['detailedInvoice'];
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Using transaction data (API unavailable)'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          setState(() {
            _error = 'Failed to load invoice details';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading invoice details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              color: selectedColor,
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
          'Invoice Details',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showDeleteConfirmation,
            icon: Icon(
              Icons.delete,
              color: Colors.red,
              size: 20,
            ),
            tooltip: 'Delete Invoice',
          ),
        ],
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading invoice details...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading invoice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDetailedInvoice,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_detailedInvoice == null) {
      return const Center(
        child: Text('No invoice data available'),
      );
    }

    return SingleChildScrollView(
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
            child: _buildSharedInvoiceTemplate(),
          ),
        ),
      ),
    );
  }

  Widget _buildSharedInvoiceTemplate() {
    // Convert detailed invoice data to the format expected by InvoiceTemplate
    final items = _detailedInvoice!.items.map((item) => {
      'name': item.item.itemName,
      'qty': item.quantity,
      'price': double.parse(item.price),
      'gst': 18.0, // Default GST rate, you can modify this based on your logic
    }).toList();

    final additionalCharges = _detailedInvoice!.charges.map((charge) => {
      'name': charge.chargeName,
      'price': double.parse(charge.price),
    }).toList();

    final additionalChargesTotal = _calculateChargesTotal();
    final subtotal = _calculateSubtotal();
    final total = subtotal + additionalChargesTotal;

    return InvoiceTemplate(
      items: items,
      subtotal: subtotal,
      discount: double.parse(_detailedInvoice!.discountAmount),
      tax: 0.0, // This will be calculated by the template
      additionalCharges: additionalCharges,
      additionalChargesTotal: additionalChargesTotal,
      roundoff: double.parse(_detailedInvoice!.roundOff),
      total: total,
      invoiceNumber: _getFormattedInvoiceNumber(),
      date: DateTime.parse(_detailedInvoice!.createdAt),
      customerName: _detailedInvoice!.customerName,
      customerPhone: _detailedInvoice!.customerNumber,
      notes: _detailedInvoice!.note,
      paymentType: _detailedInvoice!.paymentType.isNotEmpty ? _detailedInvoice!.paymentType : 'Cash',
      amountReceived: double.parse(_detailedInvoice!.amountReceived),
      primaryColor: selectedColor,
    );
  }

  Widget _buildBottomActions() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
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
                onPressed: _downloadInvoice,
                icon: Icon(Icons.download, size: 18, color: selectedColor),
                label: Text(
                  'Download',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selectedColor),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: selectedColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
                         Expanded(
               child: ElevatedButton.icon(
                 onPressed: _shareInvoice,
                 icon: Icon(
                   Icons.share,
                   size: 18,
                   color: Colors.white,
                 ),
                 label: Text(
                   'Share',
                   style: TextStyle(
                     fontSize: 14,
                     fontWeight: FontWeight.w600,
                     color: Colors.white,
                   ),
                 ),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: selectedColor,
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
    );
  }

  void _showDeleteConfirmation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Warning icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 32,
                    color: Colors.red[600],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                const Text(
                  'Delete Invoice',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Description
                const Text(
                  'Choose how you want to delete this invoice:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Delete options
                Column(
                  children: [
                    // Temporary delete option
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deleteInvoice();
                        },
                        icon: Icon(Icons.delete_outline, color: Colors.orange[600]),
                        label: Text(
                          'Temporarily Delete (Move to Trash)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[600],
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.orange[300]!, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    // Permanent delete option
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showPermanentDeleteConfirmation();
                        },
                        icon: Icon(Icons.delete_forever, color: Colors.red[600]),
                        label: Text(
                          'Permanently Delete (Cannot Recover)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[600],
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.red[300]!, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPermanentDeleteConfirmation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Warning icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_forever,
                    size: 32,
                    color: Colors.red[600],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                const Text(
                  'Permanently Delete Invoice',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Description
                const Text(
                  'Are you absolutely sure you want to permanently delete this invoice? This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deleteInvoice(isPermanent: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete Permanently',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteInvoice({bool isPermanent = false}) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = isPermanent 
          ? await ApiService.permanentDeleteInvoice(widget.transaction.invoiceId)
          : await ApiService.deleteInvoice(widget.transaction.invoiceId);
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPermanent ? 'Invoice permanently deleted' : 'Invoice temporarily deleted'),
            backgroundColor: isPermanent ? Colors.red : Colors.green,
          ),
        );
        
        // Navigate back to previous screen with result to refresh transactions
        Navigator.of(context).pop({'refresh': true, 'deletedInvoiceId': widget.transaction.invoiceId});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to delete invoice'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadInvoice() async {
    if (_detailedInvoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice data not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Generate PDF
      final pdf = await _generateInvoicePDF();
      
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Invoice_${_getFormattedInvoiceNumber()}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      
      // Write PDF to file
      await file.writeAsBytes(pdf);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice downloaded to: ${file.path}'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  Future<void> _shareInvoice() async {
    if (_detailedInvoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice data not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Generate PDF on-the-fly
      final pdf = await _generateInvoicePDF();
      
      // Get temporary directory for sharing
      final directory = await getTemporaryDirectory();
      final fileName = 'Invoice_${_getFormattedInvoiceNumber()}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      
      // Write PDF to temporary file
      await file.writeAsBytes(pdf);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Invoice ${_getFormattedInvoiceNumber()}',
        subject: 'Invoice from ${widget.businessProfile?.businessName ?? 'Business'}',
      );
      
      // Clean up the temporary file
      await file.delete();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Uint8List> _generateInvoicePDF() async {
    final pdf = pw.Document();
    
    // Add invoice content
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Invoice #: ${_getFormattedInvoiceNumber()}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Business Info
              if (widget.businessProfile != null) ...[
                pw.Text(
                  widget.businessProfile!.businessName,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(widget.businessProfile!.businessAddress),
                pw.Text('Phone: ${widget.businessProfile!.phoneNoFirst}'),
                pw.SizedBox(height: 20),
              ],
              
              // Customer Info
              pw.Text(
                'Bill To:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Name: ${_detailedInvoice!.customerName}'),
              pw.Text('Phone: ${_detailedInvoice!.customerNumber}'),
              pw.SizedBox(height: 20),
              
              // Date
              pw.Text(
                'Date: ${DateTime.parse(_detailedInvoice!.createdAt).toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),
              
              // Items Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Header row
                  pw.TableRow(
                    children: [
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
                        child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Item rows
                  ..._detailedInvoice!.items.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item.item.itemName),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item.quantity.toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('₹${item.price}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('₹${(item.quantity * double.parse(item.price)).toStringAsFixed(2)}'),
                      ),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Additional Charges
              if (_detailedInvoice!.charges.isNotEmpty) ...[
                pw.Text(
                  'Additional Charges:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                ..._detailedInvoice!.charges.map((charge) => pw.Text(
                  '${charge.chargeName}: ₹${charge.price}',
                )),
                pw.SizedBox(height: 10),
              ],
              
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: ₹${_calculateSubtotal().toStringAsFixed(2)}'),
                      pw.Text('Discount: ₹${_detailedInvoice!.discountAmount}'),
                      pw.Text('Round Off: ₹${_detailedInvoice!.roundOff}'),
                      pw.Text(
                        'Total: ₹${(_calculateSubtotal() + _calculateChargesTotal()).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Payment Info
              pw.SizedBox(height: 20),
              pw.Text('Payment Type: ${_detailedInvoice!.paymentType.isNotEmpty ? _detailedInvoice!.paymentType : 'Cash'}'),
              pw.Text('Amount Received: ₹${_detailedInvoice!.amountReceived}'),
              
              // Notes
              if (_detailedInvoice!.note.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'Notes:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(_detailedInvoice!.note),
              ],
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }

  double _calculateSubtotal() {
    return _detailedInvoice!.items.fold(
      0.0,
      (sum, item) => sum + (item.quantity * double.parse(item.price)),
    );
  }

  double _calculateChargesTotal() {
    return _detailedInvoice!.charges.fold(
      0.0,
      (sum, charge) => sum + double.parse(charge.price),
    );
  }

  String _getFormattedInvoiceNumber() {
    final invoiceNumberingService = Provider.of<InvoiceNumberingService>(context, listen: false);
    return invoiceNumberingService.getInvoiceNumberWithCustomNumber(_detailedInvoice!.id);
  }
}
