import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class EditBottomSheetContent extends StatefulWidget {
  final Item item;

  const EditBottomSheetContent({super.key, required this.item});

  @override
  State<EditBottomSheetContent> createState() => _EditBottomSheetContentState();
}

class _EditBottomSheetContentState extends State<EditBottomSheetContent> {
  int selectedTabIndex = 0; // 0 for Price & Discount, 1 for Other Details
  String selectedTaxRate = 'GST @ 28%'; // Default tax rate
  String selectedDiscountType = 'Percentage'; // Default discount type
  bool _isLoading = false; // Loading state for save operation

  // Controllers for editable fields
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _discountController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with item data
    final pricing = widget.item.pricings.isNotEmpty ? widget.item.pricings.first : null;
    _priceController = TextEditingController(
      text: pricing?.salespriceAmount ?? '0.0',
    );
    _quantityController = TextEditingController(text: '1.0');
    _unitController = TextEditingController(text: pricing?.unit ?? 'PCS');
    _discountController = TextEditingController(text: '0.0');
    _descriptionController = TextEditingController(
      text: widget.item.details.itemDescription ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Save changes to the API
  Future<void> _saveChanges() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current pricing and stock info
      final pricing = widget.item.pricings.isNotEmpty ? widget.item.pricings.first : null;
      final stock = widget.item.stocks.isNotEmpty ? widget.item.stocks.first : null;
      
      // Prepare update data
      final updateData = {
        'itemId': widget.item.id,
        'userId': widget.item.userId.toString(),
        'itemName': widget.item.itemName,
        'unit': _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : null,
        'salesPriceAmount': _priceController.text.trim().isNotEmpty ? _priceController.text.trim() : null,
        'salesPriceTax': 0, // Default tax
        'itemDescription': _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      };

      // Add stock information if available
      if (stock != null) {
        updateData['openingStock'] = stock.openingStock;
        updateData['lowAlertStatus'] = stock.lowAlertStatus;
        updateData['lowAlertQuantity'] = stock.lowAlertQuantity;
      }

      // Add pricing information if available
      if (pricing != null) {
        updateData['mrpPrice'] = pricing.mrpPrice;
        updateData['gst'] = pricing.gst;
        updateData['purchasePriceAmount'] = pricing.purchesPriceAmount;
      }

      // Add category and other details if available
      if (widget.item.details.itemCategoryId != null) {
        updateData['itemCategoryId'] = widget.item.details.itemCategoryId;
      }
      if (widget.item.details.showOnlineStore != null) {
        updateData['showOnlineStore'] = widget.item.details.showOnlineStore;
      }

      print('🔄 Updating item with data: $updateData');

      final result = await ApiService.updateItem(
        itemId: widget.item.id,
        userId: widget.item.userId.toString(),
        itemName: updateData['itemName'] as String?,
        unit: updateData['unit'] as String?,
        salesPriceAmount: updateData['salesPriceAmount'] as String?,
        openingStock: updateData['openingStock'] as int?,
        itemCategoryId: updateData['itemCategoryId'] as int?,
        itemDescription: updateData['itemDescription'] as String?,
        showOnlineStore: updateData['showOnlineStore'] as String?,
      );

      if (result['success'] == true) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result[ApiConstants.messageKey] ?? 'Item updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Close the bottom sheet and return the updated item
        Navigator.of(context).pop(result['item']);
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result[ApiConstants.messageKey] ?? 'Failed to update item'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error updating item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final Map<String, double> taxRateValues = {
    'None': 0.0,
    'Tax Exempted': 0.0,
    'GST @ 0%': 0.0,
    'GST @ 0.1%': 0.1,
    'GST @ 0.25%': 0.25,
    'GST @ 1%': 1.0,
    'GST @ 3%': 3.0,
    'GST @ 5%': 5.0,
    'GST @ 6%': 6.0,
    'GST @ 12%': 12.0,
    'GST @ 13.8%': 13.8,
    'GST @ 14%': 14.0,
    'GST @ 14% + Cess @ 12%': 26.0,
    'GST @ 18%': 18.0,
    'GST @ 28%': 28.0,
    'GST @ 28% + Cess @ 5%': 33.0,
    'GST @ 28% + Cess @ 12%': 40.0,
    'GST @ 28% + Cess @ 36%': 64.0,
    'GST @ 28% + Cess @ 60%': 88.0,
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 2),
              width: 28,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(1),
              ),
            ),

            // Header with back arrow and item name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey[100]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.itemName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Edit Item Details',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      'Price & Discount',
                      selectedTabIndex == 0,
                      () {
                        setState(() {
                          selectedTabIndex = 0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton(
                      'Other Details',
                      selectedTabIndex == 1,
                      () {
                        setState(() {
                          selectedTabIndex = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Content based on selected tab
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child:
                    selectedTabIndex == 0
                        ? _buildPriceAndDiscountContent(widget.item)
                        : _buildOtherDetailsContent(widget.item),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                                     Expanded(
                     flex: 2,
                     child: ElevatedButton(
                       onPressed: _isLoading ? null : _saveChanges,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF2E3085),
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(vertical: 10),
                         elevation: 0,
                         shadowColor: const Color(0xFF2E3085).withOpacity(0.3),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(6),
                         ),
                       ),
                       child: _isLoading
                           ? const SizedBox(
                               width: 16,
                               height: 16,
                               child: CircularProgressIndicator(
                                 strokeWidth: 2,
                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                               ),
                             )
                           : const Text(
                               'Save Changes',
                               style: TextStyle(
                                 fontSize: 12,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color:
              isActive
                  ? const Color(0xFF2E3085).withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF2E3085) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? const Color(0xFF2E3085) : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceAndDiscountContent(Item item) {
    // Get values from controllers
    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    final newPrice = double.tryParse(_priceController.text) ?? 200.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;

    final taxRate = taxRateValues[selectedTaxRate] ?? 28.0;

    final taxExclusivePrice = newPrice * quantity;
    final discountAmount =
        selectedDiscountType == 'Percentage'
            ? (taxExclusivePrice * discount / 100)
            : discount;
    final taxAmount = (taxExclusivePrice * taxRate / 100);
    final totalAmount = taxExclusivePrice + taxAmount;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // New Price (Without Tax) Section
          const Text(
            'New Price (Without Tax)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: SizedBox(
              height: 20, // Match the height of the original text
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[50]!),
                  ),
                  hintText: '0.0',
                  hintStyle: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                  ),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    // Trigger rebuild to update calculations
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Quantity and Unit Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SizedBox(
                        height: 20, // Match the height of the original text
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '1.0',
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[50]!),
                            ),
                            hintStyle: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 12,
                            ),
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onChanged: (value) {
                            setState(() {
                              // Trigger rebuild to update calculations
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 20, // Match the height of the original text
                              child: Text(
                                _unitController.text,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.lock,
                            color: Colors.grey[400],
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Discount Section
          const Text(
            'Discount',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 20, // Match the height of the original text
                    child: TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.0',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[50]!),
                        ),
                        hintStyle: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                        ),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          // Trigger rebuild to update calculations
                        });
                      },
                    ),
                  ),
                ),
                Text(
                  selectedDiscountType == 'Percentage' ? '%' : '₹',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedDiscountType,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  itemBuilder:
                      (context) =>
                          ['Percentage', 'Amount'].map((String type) {
                            return PopupMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            );
                          }).toList(),
                  onSelected: (String newValue) {
                    setState(() {
                      selectedDiscountType = newValue;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tax Rate Section
          const Text(
            'Tax Rate',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTaxRate,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                  itemBuilder:
                      (context) =>
                          taxRateValues.keys.map((String rate) {
                            return PopupMenuItem<String>(
                              value: rate,
                              child: Text(
                                rate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            );
                          }).toList(),
                  onSelected: (String newValue) {
                    setState(() {
                      selectedTaxRate = newValue;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Price Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildFinancialRow(
                  'Tax Exclusive Price * Qty',
                  '₹ ${taxExclusivePrice.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 6),
                _buildFinancialRow(
                  'Discount',
                  selectedDiscountType == 'Percentage'
                      ? '(${discount.toStringAsFixed(1)}%) ₹ ${discountAmount.toStringAsFixed(1)}'
                      : '₹ ${discountAmount.toStringAsFixed(1)}',
                ),
                const SizedBox(height: 6),
                _buildFinancialRow(
                  'Tax Rate(%)',
                  '(${taxRate.toStringAsFixed(1)}%) ₹ ${taxAmount.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        '₹ ${totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
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
  }

  Widget _buildOtherDetailsContent(Item item) {
    // Get values from controllers
    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    final taxExclusivePrice = double.tryParse(_priceController.text) ?? 200.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;

    final taxRate = taxRateValues[selectedTaxRate] ?? 28.0;

    final discountAmount =
        selectedDiscountType == 'Percentage'
            ? (taxExclusivePrice * quantity * discount / 100)
            : discount;
    final taxAmount = (taxExclusivePrice * quantity * taxRate / 100);
    final totalAmount = (taxExclusivePrice * quantity) + taxAmount;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Description
          const Text(
            'Item Description',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add Note/ Description',
                hintStyle: TextStyle(color: Color(0xFF666666), fontSize: 12),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  // Trigger rebuild if needed
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          // Financial Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildFinancialRow(
                  'Tax Exclusive Price * Qty',
                  '₹ ${(taxExclusivePrice * quantity).toStringAsFixed(0)}',
                ),
                const SizedBox(height: 6),
                _buildFinancialRow(
                  'Discount',
                  selectedDiscountType == 'Percentage'
                      ? '(${discount.toStringAsFixed(1)}%) ₹ ${discountAmount.toStringAsFixed(1)}'
                      : '₹ ${discountAmount.toStringAsFixed(1)}',
                ),
                const SizedBox(height: 6),
                _buildFinancialRow(
                  'Tax Rate(%)',
                  '(${taxRate.toStringAsFixed(1)}%) ₹ ${taxAmount.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        '₹ ${totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
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
  }

  Widget _buildFinancialRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
