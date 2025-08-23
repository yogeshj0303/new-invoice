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
                onPressed: () {
                  // TODO: Implement download functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Download functionality coming soon')),
                  );
                },
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
            const SizedBox(height: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share functionality coming soon')),
                  );
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text(
                  'Share',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
