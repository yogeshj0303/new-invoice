import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../utils/auth_utils.dart';
import '../widgets/edit_bottom_sheet_content.dart';
import 'invoice_created_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? cartItems;
  final Map<int, int>? itemQuantities;
  
  const CreateInvoiceScreen({
    super.key, 
    this.cartItems, 
    this.itemQuantities,
  });

  @override
  _CreateInvoiceScreenState createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  late List<Map<String, dynamic>> items;
  final TextEditingController itemController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController tableController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController amountReceivedController = TextEditingController();
  final TextEditingController chargeNameController = TextEditingController();
  final TextEditingController chargePriceController = TextEditingController();
  
  // Invoice details controllers
  final TextEditingController invoiceDateController = TextEditingController(text: '22 Aug 2025');
  final TextEditingController dueDateController = TextEditingController(text: 'None');
  final TextEditingController prefixController = TextEditingController(text: 'V/SL/');
  final TextEditingController serialNumberController = TextEditingController(text: '1');
  
  String paymentType = 'Cash';
  
  // Additional charges state
  bool isAdditionalChargesExpanded = false;
  List<Map<String, dynamic>> additionalCharges = [];
  
  // Discount state
  bool isDiscountExpanded = false;
  final TextEditingController discountValueController = TextEditingController();
  
  // Roundoff state
  bool isRoundoffExpanded = false;
  final TextEditingController roundoffController = TextEditingController();
  
  // Items section state
  bool isItemsExpanded = true; // Default to expanded
  
  // API call state
  bool _isCreatingInvoice = false;

  // Customer search state
  List<Customer> _customers = [];
  bool _isLoadingCustomers = false;
  bool _isCustomerDropdownOpen = false;
  final TextEditingController _customerSearchController = TextEditingController();
  Customer? _selectedCustomer;

  // Theme colors matching the app
  static const Color primaryColor = Color(0xFF2E3085); // App's blue
  static const Color secondaryColor = Color(0xFF4E4AA8); // App's lighter blue
  static const Color backgroundColor = Color(0xFFFAFBFC);
  static const Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    
    // Initialize items with cart data if available
    if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
      items = List.from(widget.cartItems!);
    } else {
      items = [];
    }
    
    // Set default dates
    final now = DateTime.now();
    invoiceDateController.text = DateFormat('dd/MM/yyyy').format(now);
    dueDateController.text = DateFormat('dd/MM/yyyy').format(now.add(Duration(days: 30)));
    
    // Serial number is already initialized with default value '1'
    
    // Add listener to customer name controller to detect manual typing
    customerNameController.addListener(() {
      if (customerNameController.text.isNotEmpty && _selectedCustomer != null) {
        setState(() {
          _selectedCustomer = null;
        });
      }
    });
    
    // Automatically fetch customers when screen loads
    _fetchCustomers();
  }
  
  // Check if keyboard is visible
  bool _isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  
  // Scroll to focused field when keyboard appears
  void _scrollToFocusedField(ScrollController scrollController) {
    if (_isKeyboardVisible(context)) {
      Future.delayed(Duration(milliseconds: 300), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
  
  // Handle keyboard visibility changes
  void _onKeyboardVisibilityChanged() {
    setState(() {
      // Trigger rebuild when keyboard visibility changes
    });
  }

  double get subtotal =>
      items.fold(0, (sum, item) => sum + (item['qty'] * item['price']));
  double get discount => _calculateDiscount();
  double get tax => _calculateTotalTax();
  double get additionalChargesTotal => additionalCharges.fold(0, (sum, charge) => sum + (charge['price'] ?? 0));
  double get total => subtotal - discount + tax + additionalChargesTotal + _calculateRoundoff();
  
  double _calculateRoundoff() {
    if (roundoffController.text.isEmpty) return 0;
    final roundoffValue = double.tryParse(roundoffController.text) ?? 0;
    
    // Ensure roundoff is reasonable (typically between -1.00 and 1.00 for decimal roundoff)
    if (roundoffValue.abs() > 1.00) {
      // If user enters a value > 1.00, show a warning but still apply it
      // This allows for edge cases while encouraging proper decimal roundoff usage
    }
    
    return roundoffValue;
  }
  
  // Helper method to get current decimal part
  double _getCurrentDecimalPart() {
    final currentTotal = subtotal - discount + tax + additionalChargesTotal;
    return currentTotal - currentTotal.floor();
  }
  
  // Helper method to suggest roundoff values based on decimal part only
  List<double> _getRoundoffSuggestions() {
    final currentTotal = subtotal - discount + tax + additionalChargesTotal;
    final decimalPart = currentTotal - currentTotal.floor(); // Get only the decimal part
    
    if (decimalPart == 0) {
      // If no decimal part, suggest common roundoff values
      return [0.50, -0.50, 1.00, -1.00];
    }
    
    // Calculate roundoff to nearest rupee (only decimal part)
    final roundoffToNearest = (currentTotal.round() - currentTotal);
    
    // Calculate roundoff to next rupee (only decimal part)
    final roundoffToNext = (currentTotal.ceil() - currentTotal);
    
    // Calculate roundoff to previous rupee (only decimal part)
    final roundoffToPrevious = (currentTotal.floor() - currentTotal);
    
    // Create a set of unique suggestions to avoid duplicates
    final suggestions = <double>{};
    
    // Add non-zero suggestions
    if (roundoffToNearest != 0) suggestions.add(roundoffToNearest);
    if (roundoffToNext != 0) suggestions.add(roundoffToNext);
    if (roundoffToPrevious != 0) suggestions.add(roundoffToPrevious);
    
    // If we have very few suggestions, add some common decimal roundoff values
    if (suggestions.length < 2) {
      if (decimalPart > 0.5) {
        suggestions.add(1.0 - decimalPart); // Round up to next whole number
      } else if (decimalPart < 0.5) {
        suggestions.add(-decimalPart); // Round down to previous whole number
      }
    }
    
    // Convert to list and sort by absolute value
    final result = suggestions.toList();
    result.sort((a, b) => a.abs().compareTo(b.abs()));
    
    return result;
  }
  
  double _calculateTotalTax() {
    double totalTax = 0;
    for (var item in items) {
      final itemTotal = item['qty'] * item['price'];
      // Use GST value if available, otherwise fallback to taxRate
      final gstValue = item['gst'] != null ? double.tryParse(item['gst'].toString()) ?? 0.0 : 0.0;
      final itemTax = itemTotal * gstValue / 100;
      totalTax += itemTax;
      

    }
    return totalTax;
  }
  
  double _calculateDiscount() {
    if (discountValueController.text.isEmpty) return 0;
    final value = double.tryParse(discountValueController.text) ?? 0;
    return (subtotal * value) / 100;
  }

  void addItem() {
    if (itemController.text.isNotEmpty &&
        qtyController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {
      setState(() {
        items.add({
          'name': itemController.text,
          'qty': double.tryParse(qtyController.text) ?? 1,
          'price': double.tryParse(priceController.text) ?? 0,
          'unit': 'BOX', // Default unit
          'taxRate': 12.0, // Default tax rate
          'gst': '12.0', // Default GST value
        });
        itemController.clear();
        qtyController.clear();
        priceController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added successfully'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void addAdditionalCharge() {
    if (chargeNameController.text.isNotEmpty &&
        chargePriceController.text.isNotEmpty) {
      setState(() {
        additionalCharges.add({
          'name': chargeNameController.text,
          'price': double.tryParse(chargePriceController.text) ?? 0,
        });
        chargeNameController.clear();
        chargePriceController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Additional charge added successfully'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

     void removeAdditionalCharge(int index) {
     setState(() {
       additionalCharges.removeAt(index);
     });
   }

  void _showQuantityDialog(BuildContext context, Map<String, dynamic> itemData) {
    final quantityController = TextEditingController(text: '1');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Add ${itemData['name']}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Price: ₹${itemData['price']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity = double.tryParse(quantityController.text) ?? 1;
                final finalItemData = Map<String, dynamic>.from(itemData);
                finalItemData['qty'] = quantity;
                
                setState(() {
                  items.add(finalItemData);
                });
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${itemData['name']} added successfully'),
                    backgroundColor: primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
   
  // Customer search methods
  Future<void> _fetchCustomers() async {
    if (_isLoadingCustomers) {
      return;
    }
    
    setState(() {
      _isLoadingCustomers = true;
    });
    
    try {
      final result = await ApiService.getCustomers();
      
      if (result[ApiConstants.successKey] == true) {
        final customersList = result['customers'] ?? [];
        setState(() {
          _customers = customersList;
          _isLoadingCustomers = false;
        });
      } else {
        setState(() {
          _customers = [];
          _isLoadingCustomers = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result[ApiConstants.messageKey] ?? 'Failed to load customers'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _customers = [];
        _isLoadingCustomers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading customers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onCustomerSelected(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      customerNameController.text = customer.customerName;
      phoneController.text = customer.phone;
      _isCustomerDropdownOpen = false;
    });
  }

  void _clearCustomerSelection() {
    setState(() {
      _selectedCustomer = null;
      customerNameController.clear();
      phoneController.clear();
      _isCustomerDropdownOpen = false;
    });
  }

  void _enableManualEntry() {
    setState(() {
      _isCustomerDropdownOpen = false;
      _selectedCustomer = null;
    });
  }

  List<Customer> _getFilteredCustomers() {
    if (customerNameController.text.isEmpty) {
      return _customers;
    }
    return _customers.where((customer) =>
        customer.customerName.toLowerCase().contains(customerNameController.text.toLowerCase()) ||
        customer.companyName.toLowerCase().contains(customerNameController.text.toLowerCase())
    ).toList();
  }
   
       @override
    void dispose() {
      itemController.dispose();
      qtyController.dispose();
      priceController.dispose();
      discountController.dispose();
      tableController.dispose();
      customerNameController.dispose();
      phoneController.dispose();
      notesController.dispose();
      amountReceivedController.dispose();
      chargeNameController.dispose();
      chargePriceController.dispose();
      discountValueController.dispose();
      roundoffController.dispose();
      invoiceDateController.dispose();
      dueDateController.dispose();
      serialNumberController.dispose();
      _customerSearchController.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
         return Scaffold(
       backgroundColor: backgroundColor,
       resizeToAvoidBottomInset: true,
       appBar: AppBar(
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.grey[700], size: 20),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(36, 36),
            ),
          ),
        ),
        title: Text(
          'Create Bill / Invoice',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Currency settings
            },
            icon: Icon(Icons.currency_rupee, color: primaryColor, size: 24),
          ),
        ],
        backgroundColor: cardColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
             body: SingleChildScrollView(
         padding: EdgeInsets.all(12),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             // Invoice Details Section
             Container(
               decoration: BoxDecoration(
                 color: cardColor,
                 borderRadius: BorderRadius.circular(8),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.04),
                     blurRadius: 6,
                     offset: Offset(0, 1),
                   ),
                 ],
               ),
               child: Padding(
                 padding: const EdgeInsets.all(12.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                                                   Text(
                            'Invoice #${serialNumberController.text}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                         Material(
                           color: Colors.transparent,
                           child: InkWell(
                             borderRadius: BorderRadius.circular(4),
                             onTap: () => _showEditInvoiceBottomSheet(),
                             child: Container(
                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(
                                 color: primaryColor.withOpacity(0.1),
                                 borderRadius: BorderRadius.circular(4),
                               ),
                               child: Text(
                                 'EDIT',
                                 style: theme.textTheme.bodySmall?.copyWith(
                                   fontWeight: FontWeight.w600,
                                   color: primaryColor,
                                   fontSize: 11,
                                 ),
                               ),
                             ),
                           ),
                         ),
                       ],
                     ),
                     SizedBox(height: 4),
                     Text(
                       invoiceDateController.text,
                       style: theme.textTheme.bodyMedium?.copyWith(
                         color: Colors.grey[600],
                         fontSize: 13,
                       ),
                     ),
                                           if (dueDateController.text.isNotEmpty && dueDateController.text != 'None')
                        Text(
                          'Due: ${dueDateController.text} (${_calculateDaysDifference()} day(s))',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                   ],
                 ),
               ),
             ),
             SizedBox(height: 12),

                         // Items Section
             Container(
               decoration: BoxDecoration(
                 color: cardColor,
                 borderRadius: BorderRadius.circular(8),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.04),
                     blurRadius: 6,
                     offset: Offset(0, 1),
                   ),
                 ],
               ),
               child: Padding(
                 padding: const EdgeInsets.all(12.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Material(
                           color: Colors.transparent,
                           child: InkWell(
                             borderRadius: BorderRadius.circular(6),
                             onTap: () {
                               setState(() {
                                 isItemsExpanded = !isItemsExpanded;
                               });
                             },
                             child: Padding(
                               padding: EdgeInsets.symmetric(vertical: 6),
                               child: Row(
                                 children: [
                                   Text(
                                     'ITEMS',
                                     style: theme.textTheme.titleMedium?.copyWith(
                                       fontWeight: FontWeight.w600,
                                       color: Colors.black87,
                                     ),
                                   ),
                                   Text(
                                     ' (${items.length})',
                                     style: theme.textTheme.titleMedium?.copyWith(
                                       fontWeight: FontWeight.w600,
                                       color: primaryColor,
                                     ),
                                   ),
                                   SizedBox(width: 4),
                                   Icon(
                                     isItemsExpanded 
                                       ? Icons.keyboard_arrow_up 
                                       : Icons.keyboard_arrow_down,
                                     color: primaryColor,
                                     size: 18,
                                   ),
                                 ],
                               ),
                             ),
                           ),
                         ),
                         TextButton(
                           onPressed: () {
                             Navigator.of(context).pushNamed('/add-item').then((result) {
                               if (result != null && result is Map<String, dynamic>) {
                                 // Show quantity input dialog
                                 _showQuantityDialog(context, result);
                               }
                             });
                           },
                           child: Text(
                             '+ Item',
                             style: theme.textTheme.bodyMedium?.copyWith(
                               fontWeight: FontWeight.w600,
                               color: primaryColor,
                               fontSize: 13,
                             ),
                           ),
                         ),
                       ],
                     ),
                     if (isItemsExpanded) ...[
                       if (items.isEmpty)
                         Container(
                           margin: EdgeInsets.only(top: 12),
                           padding: EdgeInsets.all(12),
                           decoration: BoxDecoration(
                             color: Colors.grey[50],
                             borderRadius: BorderRadius.circular(6),
                             border: Border.all(color: Colors.grey[200]!),
                           ),
                           child: Row(
                             children: [
                               Icon(
                                 Icons.add_circle_outline,
                                 color: primaryColor,
                                 size: 18,
                               ),
                               SizedBox(width: 6),
                               Text(
                                 'Add your first item',
                                 style: theme.textTheme.bodyMedium?.copyWith(
                                   color: Colors.grey[600],
                                   fontSize: 13,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       if (items.isNotEmpty) ...[
                         SizedBox(height: 12),
                         ...items.asMap().entries.map((entry) {
                           final index = entry.key;
                           final item = entry.value;
                           final itemTotal = item['qty'] * item['price'];
                           // Use GST value if available, otherwise fallback to taxRate
                           final gstValue = item['gst'] != null ? double.tryParse(item['gst'].toString()) ?? 0.0 : 0.0;
                           final itemTax = itemTotal * gstValue / 100;
                           final itemTotalWithTax = itemTotal + itemTax;
                           
                           return Container(
                             margin: EdgeInsets.only(bottom: 8),
                             padding: EdgeInsets.all(10),
                             decoration: BoxDecoration(
                               color: Colors.grey[50],
                               borderRadius: BorderRadius.circular(6),
                               border: Border.all(color: Colors.grey[200]!),
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     Expanded(
                                       child: Text(
                                         item['name'],
                                         style: theme.textTheme.bodyMedium?.copyWith(
                                           fontWeight: FontWeight.w600,
                                           color: Colors.black87,
                                           fontSize: 14,
                                         ),
                                       ),
                                     ),
                                     Row(
                                       children: [
                                         Text(
                                           '₹ ${itemTotalWithTax.toStringAsFixed(0)}',
                                           style: theme.textTheme.bodyMedium?.copyWith(
                                             fontWeight: FontWeight.w600,
                                             color: primaryColor,
                                             fontSize: 14,
                                           ),
                                         ),
                                         SizedBox(width: 6),
                                         Container(
                                           padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                           decoration: BoxDecoration(
                                             color: primaryColor.withOpacity(0.1),
                                             borderRadius: BorderRadius.circular(3),
                                           ),
                                           child: GestureDetector(
                                             onTap: () => _editItem(item),
                                             child: Text(
                                               'EDIT',
                                               style: theme.textTheme.bodySmall?.copyWith(
                                                 fontWeight: FontWeight.w600,
                                                 color: primaryColor,
                                                 fontSize: 9,
                                               ),
                                             ),
                                           ),
                                         ),
                                       ],
                                     ),
                                   ],
                                 ),
                                 SizedBox(height: 3),
                                 Text(
                                   'Qty x Rate',
                                   style: theme.textTheme.bodySmall?.copyWith(
                                     color: Colors.grey[600],
                                     fontSize: 11,
                                   ),
                                 ),
                                 Text(
                                   '${item['qty']} ${item['unit']} x ${item['price'].toStringAsFixed(2)}',
                                   style: theme.textTheme.bodyMedium?.copyWith(
                                     color: Colors.black87,
                                     fontSize: 13,
                                   ),
                                 ),
                                 SizedBox(height: 3),
                                 Text(
                                   'Tax',
                                   style: theme.textTheme.bodySmall?.copyWith(
                                     color: Colors.grey[600],
                                     fontSize: 11,
                                   ),
                                 ),
                                 Text(
                                   '${gstValue > 0 ? 'GST ${gstValue.toStringAsFixed(2)}%' : 'No Tax'} = ${itemTax.toStringAsFixed(2)}',
                                   style: theme.textTheme.bodyMedium?.copyWith(
                                     color: Colors.black87,
                                     fontSize: 13,
                                   ),
                                 ),
                               ],
                             ),
                           );
                         }).toList(),
                       ],
                     ],
                   ],
                 ),
               ),
             ),
             SizedBox(height: 12),

                         // Financial Summary Section
             Container(
               decoration: BoxDecoration(
                 color: cardColor,
                 borderRadius: BorderRadius.circular(8),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.04),
                     blurRadius: 6,
                     offset: Offset(0, 1),
                   ),
                 ],
               ),
               child: Padding(
                 padding: const EdgeInsets.all(12.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [                                           Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Item Subtotal',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '₹ ${subtotal.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (discount > 0) ...[
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '- ₹ ${discount.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.red[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (additionalCharges.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Additional Charges',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '₹ ${additionalChargesTotal.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                                             SizedBox(height: 8),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(
                             'Tax',
                             style: theme.textTheme.bodyMedium?.copyWith(
                               color: Colors.grey[700],
                               fontSize: 14,
                             ),
                           ),
                           Text(
                             '₹ ${tax.toStringAsFixed(2)}',
                             style: theme.textTheme.bodyMedium?.copyWith(
                               fontWeight: FontWeight.w600,
                               color: Colors.black87,
                               fontSize: 14,
                             ),
                           ),
                         ],
                       ),
                       if (_calculateRoundoff() != 0) ...[
                         SizedBox(height: 8),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text(
                               'Roundoff (Decimal)',
                               style: theme.textTheme.bodyMedium?.copyWith(
                                 color: Colors.grey[700],
                                 fontSize: 14,
                               ),
                             ),
                             Text(
                               _calculateRoundoff() > 0 
                                 ? '+ ₹ ${_calculateRoundoff().toStringAsFixed(2)}'
                                 : '- ₹ ${(_calculateRoundoff() * -1).toStringAsFixed(2)}',
                               style: theme.textTheme.bodyMedium?.copyWith(
                                 fontWeight: FontWeight.w600,
                                 color: _calculateRoundoff() > 0 ? Colors.green[600] : Colors.red[600],
                                 fontSize: 14,
                               ),
                             ),
                           ],
                         ),
                       ],
                       SizedBox(height: 12),
                      _buildAddOption('Additional Charges', Icons.add_circle_outline),
                      SizedBox(height: 6),
                      _buildAddOption('Discount', Icons.discount_outlined),
                      SizedBox(height: 6),
                      _buildAddOption('Round Off', Icons.rounded_corner),
                   ],
                 ),
               ),
             ),
             SizedBox(height: 12),

                         // Total Amount Section
             Container(
               decoration: BoxDecoration(
                 color: cardColor,
                 borderRadius: BorderRadius.circular(8),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.04),
                     blurRadius: 6,
                     offset: Offset(0, 1),
                   ),
                 ],
               ),
               child: Padding(
                 padding: const EdgeInsets.all(12.0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(
                       'Total Amount',
                       style: theme.textTheme.titleMedium?.copyWith(
                         fontWeight: FontWeight.w600,
                         color: Colors.black87,
                         fontSize: 16,
                       ),
                     ),
                     Text(
                       '₹ ${total.toStringAsFixed(2)}',
                       style: theme.textTheme.titleMedium?.copyWith(
                         fontWeight: FontWeight.w700,
                         color: primaryColor,
                         fontSize: 16,
                       ),
                     ),
                   ],
                 ),
               ),
             ),
             SizedBox(height: 12),



                         // Customer Information Section
             Container(
               decoration: BoxDecoration(
                 color: cardColor,
                 borderRadius: BorderRadius.circular(8),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.04),
                     blurRadius: 6,
                     offset: Offset(0, 1),
                   ),
                 ],
               ),
               child: Padding(
                 padding: const EdgeInsets.all(12.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                                           Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: primaryColor,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Customer Information',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                     SizedBox(height: 10),
                     Row(
                       children: [
                         Expanded(
                           child: SizedBox(
                             height: 40,
                             child: Focus(
                               onFocusChange: (hasFocus) {
                                 if (hasFocus) {
                                   setState(() {
                                     _isCustomerDropdownOpen = true;
                                   });
                                 }
                               },
                               child: TextField(
                                 controller: customerNameController,
                                 decoration: InputDecoration(
                                   labelText: 'Customer Name',
                                   labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                   prefixIcon: Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(6),
                                     borderSide: BorderSide(color: Colors.grey[300]!),
                                   ),
                                   enabledBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(6),
                                     borderSide: BorderSide(color: Colors.grey[300]!),
                                   ),
                                   focusedBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(6),
                                     borderSide: BorderSide(color: primaryColor, width: 1.5),
                                   ),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                   filled: true,
                                   fillColor: Colors.grey[50],
                                   isDense: true,
                                   constraints: BoxConstraints(maxHeight: 40),
                                 ),
                                 style: TextStyle(fontSize: 12, color: Colors.black87),
                                 onChanged: (value) {
                                   setState(() {
                                     // Filter customers based on search text
                                     _isCustomerDropdownOpen = true;
                                   });
                                 },
                                 onTap: () {
                                   setState(() {
                                     _isCustomerDropdownOpen = true;
                                   });
                                 },
                               ),
                             ),
                           ),
                         ),
                         SizedBox(width: 8),
                         Expanded(
                           child: SizedBox(
                             height: 40,
                             child: TextField(
                               controller: phoneController,
                               keyboardType: TextInputType.phone,
                               maxLength: 10,
                               onChanged: (value) {
                                 if (value.length == 10) {
                                   FocusScope.of(context).unfocus();
                                 }
                               },
                               decoration: InputDecoration(
                                 labelText: 'Phone Number',
                                 labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                 prefixIcon: Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                                 border: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(6),
                                   borderSide: BorderSide(color: Colors.grey[300]!),
                                 ),
                                 enabledBorder: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(6),
                                   borderSide: BorderSide(color: Colors.grey[300]!),
                                 ),
                                 focusedBorder: OutlineInputBorder(
                                   borderRadius: BorderRadius.circular(6),
                                   borderSide: BorderSide(color: primaryColor, width: 1.5),
                                 ),
                                 contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                 filled: true,
                                 fillColor: Colors.grey[50],
                                 isDense: true,
                                 constraints: BoxConstraints(maxHeight: 40),
                                 counterText: '', // Hide the character counter
                               ),
                               style: TextStyle(fontSize: 12, color: Colors.black87),
                             ),
                           ),
                         ),
                       ],
                     ),

                     // Customer dropdown list
                     if (_isCustomerDropdownOpen) ...[

                       SizedBox(height: 8),


                       Container(
                         constraints: BoxConstraints(maxHeight: 200),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(6),
                           border: Border.all(color: Colors.grey[300]!),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.black.withOpacity(0.1),
                               blurRadius: 4,
                               offset: Offset(0, 2),
                             ),
                           ],
                         ),
                         child: Column(
                           children: [
                             // Customer list
                             Expanded(
                               child: _isLoadingCustomers
                                   ? Center(
                                       child: Padding(
                                         padding: EdgeInsets.all(16),
                                         child: CircularProgressIndicator(
                                           strokeWidth: 2,
                                           valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                         ),
                                       ),
                                     )
                                   : _getFilteredCustomers().isEmpty
                                       ? Center(
                                           child: Padding(
                                             padding: EdgeInsets.all(16),
                                             child: Column(
                                               mainAxisSize: MainAxisSize.min,
                                               children: [
                                                 Text(
                                                   'No customers found',
                                                   style: TextStyle(
                                                     fontSize: 11,
                                                     color: Colors.grey[500],
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ),
                                         )
                                       : ListView.builder(
                                           shrinkWrap: true,
                                           itemCount: _getFilteredCustomers().length,
                                           itemBuilder: (context, index) {
                                             final customer = _getFilteredCustomers()[index];
                                             return ListTile(
                                               dense: true,
                                               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                               title: Text(
                                                 customer.customerName,
                                                 style: TextStyle(
                                                   fontSize: 12,
                                                   fontWeight: FontWeight.w500,
                                                   color: Colors.black87,
                                                 ),
                                               ),
                                               subtitle: Text(
                                                 customer.companyName.isNotEmpty ? customer.companyName : customer.phone,
                                                 style: TextStyle(
                                                   fontSize: 10,
                                                   color: Colors.grey[600],
                                                 ),
                                               ),
                                               onTap: () => _onCustomerSelected(customer),
                                               trailing: Icon(
                                                 Icons.arrow_forward_ios,
                                                 size: 12,
                                                 color: Colors.grey[400],
                                               ),
                                             );
                                           },
                                         ),
                             ),
                             // Manual entry option
                             Container(
                               padding: EdgeInsets.all(8),
                               decoration: BoxDecoration(
                                 color: Colors.grey[50],
                                 border: Border(
                                   top: BorderSide(color: Colors.grey[200]!),
                                 ),
                               ),
                               child: Row(
                                 children: [
                                   Icon(Icons.edit, size: 14, color: Colors.grey[600]),
                                   SizedBox(width: 8),
                                   Expanded(
                                     child: Text(
                                       'Or type customer name manually',
                                       style: TextStyle(
                                         fontSize: 10,
                                         color: Colors.grey[600],
                                       ),
                                     ),
                                   ),
                                   TextButton(
                                     onPressed: _enableManualEntry,
                                     child: Text(
                                       'Enter Manually',
                                       style: TextStyle(
                                         fontSize: 10,
                                         color: primaryColor,
                                         fontWeight: FontWeight.w500,
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ],
                 ),
               ),
             ),
             SizedBox(height: 12),

                         // Payment and Notes Section
             Container(
               decoration: BoxDecoration(
                 color: cardColor,
                 borderRadius: BorderRadius.circular(8),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.04),
                     blurRadius: 6,
                     offset: Offset(0, 1),
                   ),
                 ],
               ),
               child: Padding(
                 padding: const EdgeInsets.all(12.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                                                                   // Payment Type Selection
                        DropdownButtonFormField<String>(
                          value: paymentType,
                          decoration: InputDecoration(
                            labelText: 'Payment Type',
                            labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: primaryColor, width: 1.5),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: true,
                            fillColor: Colors.grey[50],
                            isDense: true,
                          ),
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                          items: ['Cash', 'Card', 'UPI', 'Bank Transfer'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                paymentType = newValue;
                              });
                            }
                          },
                        ),
                     SizedBox(height: 12),
                                           Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                controller: amountReceivedController,
                                keyboardType: TextInputType.number,
                                                                                                                                   decoration: InputDecoration(
                                   labelText: 'Amount Received',
                                   labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                   prefixText: '₹ ',
                                   prefixStyle: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(6),
                                     borderSide: BorderSide(color: Colors.grey[300]!),
                                   ),
                                   enabledBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(6),
                                     borderSide: BorderSide(color: Colors.grey[300]!),
                                   ),
                                   focusedBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(6),
                                     borderSide: BorderSide(color: primaryColor, width: 1.5),
                                   ),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                   filled: true,
                                   fillColor: Colors.grey[50],
                                   isDense: true,
                                 ),
                                 style: TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                controller: notesController,
                                                                                                  decoration: InputDecoration(
                                    labelText: 'Notes',
                                    labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    isDense: true,
                                  ),
                                 style: TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                          ),
                        ],
                      ),
                   ],
                 ),
               ),
             ),
             SizedBox(height: 16),

                         // Generate Bill Button
             SizedBox(
               width: double.infinity,
               child: Container(
                 height: 48,
                 decoration: BoxDecoration(
                   color: (items.isEmpty || _isCreatingInvoice) ? Colors.grey[400] : primaryColor,
                   borderRadius: BorderRadius.circular(8),
                   boxShadow: (items.isEmpty || _isCreatingInvoice) ? [] : [
                     BoxShadow(
                       color: primaryColor.withOpacity(0.3),
                       blurRadius: 6,
                       offset: Offset(0, 1),
                     ),
                   ],
                 ),
                 child: Material(
                   color: Colors.transparent,
                   child: InkWell(
                     borderRadius: BorderRadius.circular(8),
                     onTap: (items.isEmpty || _isCreatingInvoice) ? null : () async {
                       await _createInvoice();
                     },
                     child: Center(
                       child: _isCreatingInvoice 
                         ? Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               SizedBox(
                                 width: 16,
                                 height: 16,
                                 child: CircularProgressIndicator(
                                   strokeWidth: 2,
                                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                 ),
                               ),
                               SizedBox(width: 8),
                               Text(
                                 'Creating Invoice...',
                                 style: theme.textTheme.titleMedium?.copyWith(
                                   fontWeight: FontWeight.w600,
                                   color: Colors.white,
                                   letterSpacing: 0.2,
                                   fontSize: 16,
                                 ),
                               ),
                             ],
                           )
                         : Text(
                             items.isEmpty ? 'Add Items to Generate Bill' : 'Generate Bill',
                             style: theme.textTheme.titleMedium?.copyWith(
                               fontWeight: FontWeight.w600,
                               color: Colors.white,
                               letterSpacing: 0.2,
                               fontSize: 16,
                             ),
                           ),
                     ),
                   ),
                 ),
               ),
             ),
                           SizedBox(height: 12),
              
              // Add extra padding at bottom to prevent keyboard overlap
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 20),
 
 
                          // Security Footer
              Container(
               padding: EdgeInsets.all(12),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(
                     Icons.lock,
                     color: Colors.green[600],
                     size: 14,
                   ),
                   SizedBox(width: 6),
                   Text(
                     'Your data is safe. Only you can see this data',
                     style: theme.textTheme.bodySmall?.copyWith(
                       color: Colors.green[600],
                       fontWeight: FontWeight.w500,
                       fontSize: 11,
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

           Widget _buildAddOption(String title, IconData icon) {
        if (title == 'Additional Charges') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    setState(() {
                      isAdditionalChargesExpanded = !isAdditionalChargesExpanded;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: primaryColor,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '+ $title',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                            fontSize: 13,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          isAdditionalChargesExpanded 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_down,
                          color: primaryColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isAdditionalChargesExpanded) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [           // Input fields and add button in a row
                       Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                         children: [
                           Expanded(
                             child: SizedBox(
                               height: 40,
                               child: TextField(
                                 controller: chargeNameController,
                                 decoration: InputDecoration(
                                   labelText: 'Charge Name',
                                   labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(6),
                                     borderSide: BorderSide(color: Colors.grey[300]!),
                                   ),
                                   enabledBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(6),
                                     borderSide: BorderSide(color: Colors.grey[300]!),
                                   ),
                                   focusedBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(6),
                                     borderSide: BorderSide(color: primaryColor, width: 1.5),
                                   ),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                   filled: true,
                                   fillColor: Colors.white,
                                   isDense: true,
                                   constraints: BoxConstraints(maxHeight: 40),
                                 ),
                                 style: TextStyle(fontSize: 12, color: Colors.black87),
                               ),
                             ),
                           ),
                           SizedBox(width: 8),
                           Expanded(
                             child: SizedBox(
                               height: 40,
                               child: TextField(
                                 controller: chargePriceController,
                                 keyboardType: TextInputType.number,
                                 decoration: InputDecoration(
                                   labelText: 'Price',
                                   labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                   prefixText: '₹ ',
                                   prefixStyle: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(6),
                                     borderSide: BorderSide(color: Colors.grey[300]!),
                                   ),
                                   enabledBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(6),
                                     borderSide: BorderSide(color: Colors.grey[300]!),
                                   ),
                                   focusedBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(6),
                                     borderSide: BorderSide(color: primaryColor, width: 1.5),
                                   ),
                                   contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                   filled: true,
                                   fillColor: Colors.white,
                                   isDense: true,
                                   constraints: BoxConstraints(maxHeight: 40),
                                 ),
                                 style: TextStyle(fontSize: 12, color: Colors.black87),
                               ),
                             ),
                           ),
                           SizedBox(width: 8),
                            SizedBox(
                              height: 30,
                              child: ElevatedButton(
                                onPressed: addAdditionalCharge,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  minimumSize: Size(30, 30),
                                ),
                                child: Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                         ],
                       ),
                      // Display added charges
                      if (additionalCharges.isNotEmpty) ...[
                        SizedBox(height: 12),
                        ...additionalCharges.asMap().entries.map((entry) {
                          final index = entry.key;
                          final charge = entry.value;
                          return Container(
                            margin: EdgeInsets.only(bottom: 6),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    charge['name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹ ${charge['price'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => removeAdditionalCharge(index),
                                  child: Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red[400],
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        } else if (title == 'Discount') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    setState(() {
                      isDiscountExpanded = !isDiscountExpanded;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: primaryColor,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '+ $title',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                            fontSize: 13,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          isDiscountExpanded 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_down,
                          color: primaryColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isDiscountExpanded) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                                                                            // Discount percentage input and calculated amount in a single row
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: discountValueController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      // Trigger rebuild to update calculated discount
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Discount (%)',
                                    labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    filled: true,
                                    fillColor: Colors.white,
                                    isDense: true,
                                    constraints: BoxConstraints(maxHeight: 40),
                                  ),
                                  style: TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    labelText: 'Amount (₹)',
                                    labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    prefixText: '₹ ',
                                    prefixStyle: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    isDense: true,
                                    constraints: BoxConstraints(maxHeight: 40),
                                  ),
                                  style: TextStyle(fontSize: 12, color: Colors.black87),
                                  controller: TextEditingController(text: discount.toStringAsFixed(2)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      // Clear button
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              discountValueController.clear();
                              isDiscountExpanded = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            'Clear Discount',
                            style: TextStyle(
                              color: Colors.red[400],
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
            ],
          );
        } else if (title == 'Round Off') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    setState(() {
                      isRoundoffExpanded = !isRoundoffExpanded;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: primaryColor,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '+ $title',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                            fontSize: 13,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          isRoundoffExpanded 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_down,
                          color: primaryColor,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isRoundoffExpanded) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                             // Roundoff dropdown field
                       SizedBox(
                         height: 40,
                         child: DropdownButtonFormField<String>(
                           value: roundoffController.text.isEmpty ? null : roundoffController.text,
                           decoration: InputDecoration(
                             labelText: 'Roundoff Amount (₹)',
                             labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                             hintText: 'Select roundoff value',
                             hintStyle: TextStyle(fontSize: 10, color: Colors.grey[500]),
                             prefixText: '₹ ',
                             prefixStyle: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                             border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(6),
                               borderSide: BorderSide(color: Colors.grey[300]!),
                             ),
                             enabledBorder: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(6),
                               borderSide: BorderSide(color: Colors.grey[300]!),
                             ),
                             focusedBorder: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(6),
                               borderSide: BorderSide(color: Colors.grey[300]!),
                             ),
                             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                             filled: true,
                             fillColor: Colors.white,
                             isDense: true,
                             constraints: BoxConstraints(maxHeight: 40),
                           ),
                           style: TextStyle(fontSize: 12, color: Colors.black87),
                           items: [
                             DropdownMenuItem<String>(
                               value: null,
                               child: Text(
                                 'No roundoff',
                                 style: TextStyle(color: Colors.grey[600], fontSize: 12),
                               ),
                             ),
                             ..._getRoundoffSuggestions().take(2).map((suggestion) {
                               return DropdownMenuItem<String>(
                                 value: suggestion.toStringAsFixed(2),
                                 child: Text(
                                   suggestion > 0 
                                     ? '+ ₹${suggestion.toStringAsFixed(2)}'
                                     : '- ₹${(suggestion * -1).toStringAsFixed(2)}',
                                   style: TextStyle(fontSize: 12, color: Colors.black87),
                                 ),
                               );
                             }).toList(),
                           ],
                           onChanged: (String? value) {
                             setState(() {
                               if (value == null) {
                                 roundoffController.clear();
                               } else {
                                 roundoffController.text = value;
                               }
                             });
                           },
                         ),
                       ),
                      SizedBox(height: 8),
                      // Current decimal part display
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 14, color: Colors.blue[700]),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Current decimal part: ₹${_getCurrentDecimalPart().toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      // Info text
                      Text(
                        'Roundoff operates only on decimal values (e.g., .44 in 1.38)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      // Clear button
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              roundoffController.clear();
                              isRoundoffExpanded = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            'Clear Roundoff',
                            style: TextStyle(
                              color: Colors.red[400],
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
            ],
          );
        }
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              // Handle option tap
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: primaryColor,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '+ $title',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

  void _editItem(Map<String, dynamic> item) async {
    // Get actual user ID from auth service
    final userId = await AuthUtils.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not authenticated. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Convert Map to Item object for EditBottomSheetContent
    final itemObject = Item(
      id: item['id'] ?? 0,
      itemName: item['name'] ?? '',
      userId: userId,
      createdAt: item['createdAt'] ?? DateTime.now(),
      updatedAt: item['createdAt'] ?? DateTime.now(),
      pricings: [
        ItemPricing(
          id: 0,
          itemId: item['id'] ?? 0,
          unit: item['unit'] ?? 'PCS',
          salespriceAmount: (item['price'] ?? 0).toString(),
          salespriceTax: 0,
          purchesPriceAmount: (item['purchasePrice'] ?? 0).toString(),
          purchesPriceTax: 0,
          mrpPrice: item['mrpPrice'] != null ? item['mrpPrice'].toString() : null,
          gst: item['gst'], // Use actual GST value from cart item
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      stocks: [
        ItemStock(
          id: 0,
          itemId: item['id'] ?? 0,
          openingStock: (item['stockQuantity'] ?? 0).toInt(),
          asOfDate: null,
          itemName: item['name'] ?? '',
          lowAlertStatus: 'false',
          lowAlertQuantity: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      otherImages: [],
      details: ItemDetails(
        id: 0,
        itemId: item['id'] ?? 0,
        itemCategoryId: null, // TODO: Map category name to ID
        itemDescription: item['description'] ?? '',
        showOnlineStore: 'false',
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _buildEditBottomSheet(itemObject);
      },
    );
  }

  Widget _buildEditBottomSheet(Item item) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return EditBottomSheetContent(
          item: item,
          onItemUpdated: null, // No callback needed in invoice context
        );
      },
    );
  }

  void _showEditInvoiceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _buildEditInvoiceBottomSheet(),
        );
      },
    );
  }

  Widget _buildEditInvoiceBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: _isKeyboardVisible(context) ? 0.8 : 0.6,
      minChildSize: _isKeyboardVisible(context) ? 0.6 : 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Invoice Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[600], size: 18),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice Date
                      _buildCompactDateField(
                        'Invoice Date',
                        invoiceDateController,
                        Icons.calendar_today,
                        () => _selectDate(context, invoiceDateController),
                      ),
                      SizedBox(height: 16),
                      
                      // Due Date
                      _buildCompactDropdownField(
                        'Due Date',
                        dueDateController,
                        Icons.calendar_today,
                      ),
                      SizedBox(height: 6),
                      
                      // Starting Serial Number
                      _buildCompactTextField(
                        'Starting Serial Number',
                        serialNumberController,
                        Icons.numbers,
                      ),
                      SizedBox(height: 6),
                      
                      // Hint text
                      Text(
                        '(Ex: 1, 2, 3..)',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Add extra padding at bottom to ensure content is not hidden behind keyboard
                      SizedBox(height: _isKeyboardVisible(context) ? 120 : 20),
                    ],
                  ),
                ),
              ),
              // Save Button
              Container(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'SAVE CHANGES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, IconData icon, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Select Date' : controller.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.text.isEmpty ? Colors.grey[500] : Colors.black87,
                    ),
                  ),
                ),
                Icon(icon, color: Colors.grey[600], size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDateField(String label, TextEditingController controller, IconData icon, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Select Date' : controller.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: controller.text.isEmpty ? Colors.grey[500] : Colors.black87,
                    ),
                  ),
                ),
                Icon(icon, color: Colors.grey[600], size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickDateButton(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: primaryColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }



  Widget _buildCompactTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (hasFocus) {
                      // Trigger rebuild when focus changes to handle keyboard
                      setState(() {});
                    }
                  },
                  child: TextField(
                    controller: controller,
                    style: TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[50]!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      border: InputBorder.none,
                      hintText: 'Enter $label',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              Icon(icon, color: Colors.grey[600], size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDropdownField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              return DropdownButton<String>(
                value: value.text == 'None' ? 'None' : 
                       ['7 Days', '15 Days', '30 Days', '45 Days', '60 Days'].contains(value.text) ? value.text : null,
                hint: Text(
                  value.text == 'None' ? 'Select Due Date' : value.text,
                  style: TextStyle(
                    fontSize: 12,
                    color: value.text == 'None' ? Colors.grey[500] : Colors.black87,
                  ),
                ),
                isExpanded: true,
                underline: SizedBox.shrink(),
                icon: Icon(icon, color: Colors.grey[600], size: 16),
                menuMaxHeight: 200,
                items: [
                  DropdownMenuItem<String>(
                    value: '7 Days',
                    child: Text(
                      '7 Days',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: '15 Days',
                    child: Text(
                      '15 Days',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: '30 Days',
                    child: Text(
                      '30 Days',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: '45 Days',
                    child: Text(
                      '45 Days',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: '60 Days',
                    child: Text(
                      '60 Days',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'None',
                    child: Text(
                      'None',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[600],
                      ),
                    ),
                  ),
                ],
                onChanged: (String? dropdownValue) {
                  if (dropdownValue != null) {
                    _setDueDateFromDropdown(dropdownValue);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter $label',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              ),
              Icon(icon, color: Colors.grey[600], size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      final parsedDate = _parseDate(controller.text);
      if (parsedDate != null) {
        initialDate = parsedDate;
      }
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = '${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
      });
    }
  }



  String? _getDropdownValue(String controllerText) {
    if (controllerText.isEmpty || controllerText == 'None') {
      return 'None';
    }
    
    // Return the controller text if it matches one of the predefined dropdown values
    if (['7 Days', '15 Days', '30 Days', '45 Days', '60 Days'].contains(controllerText)) {
      return controllerText;
    }
    
    // If it's any other value, return null to show hint
    return null;
  }

  void _setDueDateFromDropdown(String value) {
    setState(() {
      dueDateController.text = value;
    });
  }



    String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  int _calculateDaysDifference() {
    if (invoiceDateController.text.isEmpty || 
        dueDateController.text.isEmpty || 
        dueDateController.text == '') {
      return 0;
    }
    
    // If dueDateController.text is in format "X Days", extract the number
    if (dueDateController.text.endsWith(' Days')) {
      final days = int.tryParse(dueDateController.text.split(' ')[0]);
      if (days != null) {
        return days;
      }
    }
    
    // Fallback to date parsing for backward compatibility
    try {
      final invoiceDate = _parseDate(invoiceDateController.text);
      final dueDate = _parseDate(dueDateController.text);
      if (invoiceDate != null && dueDate != null) {
        return dueDate.difference(invoiceDate).inDays;
      }
    } catch (e) {
      // If parsing fails, return 0
    }
    return 0;
  }

  DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.split(' ');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = _getMonthNumber(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // If parsing fails, return null
    }
    return null;
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthName] ?? 1;
  }

  // Create Invoice Method
  Future<void> _createInvoice() async {
    // Set loading state
    setState(() {
      _isCreatingInvoice = true;
    });

    try {
      // Validate required fields
      if (customerNameController.text.isEmpty) {
        setState(() {
          _isCreatingInvoice = false;
        });
        _showErrorDialog('Customer name is required');
        return;
      }

      if (phoneController.text.isEmpty) {
        setState(() {
          _isCreatingInvoice = false;
        });
        _showErrorDialog('Phone number is required');
        return;
      }

      if (phoneController.text.length != 10) {
        setState(() {
          _isCreatingInvoice = false;
        });
        _showErrorDialog('Phone number must be 10 digits');
        return;
      }

      if (items.isEmpty) {
        setState(() {
          _isCreatingInvoice = false;
        });
        _showErrorDialog('Please add at least one item to create an invoice');
        return;
      }

      // Validate amount received
      final amountReceivedValue = double.tryParse(amountReceivedController.text) ?? total;
      if (amountReceivedValue < total) {
        setState(() {
          _isCreatingInvoice = false;
        });
        _showErrorDialog('Amount received cannot be less than total amount');
        return;
      }

      // Prepare data for API call
      // Get actual user ID from auth service
      final userId = await AuthUtils.getCurrentUserId();
      if (userId == null) {
        setState(() {
          _isCreatingInvoice = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not authenticated. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final customerId = "1"; // TODO: Get actual customer ID or create new customer
      final customerName = customerNameController.text;
      final customerNumber = phoneController.text;
      final paymentTypeValue = _formatPaymentType(paymentType);
      final discountPercent = discountValueController.text.isEmpty ? "0" : discountValueController.text;
      final discountAmount = discount.toStringAsFixed(2);
      final roundOff = _calculateRoundoff().toStringAsFixed(2);
      final totalAmount = total.toStringAsFixed(2);
      final amountReceived = amountReceivedController.text.isEmpty ? total.toStringAsFixed(2) : amountReceivedController.text;
      final note = notesController.text.isEmpty ? "Thank you for shopping!" : notesController.text;

      // Call the API
      final result = await ApiService.createInvoice(
        userId: userId.toString(),
        customerId: customerId,
        customerName: customerName,
        customerNumber: customerNumber,
        paymentType: paymentTypeValue,
        discountPercent: discountPercent,
        discountAmount: discountAmount,
        roundOff: roundOff,
        totalAmount: totalAmount,
        amountReceived: amountReceived,
        note: note,
        items: items,
        charges: additionalCharges,
      );

      // Reset loading state
      setState(() {
        _isCreatingInvoice = false;
      });

      if (result['success'] == true) {
        // Show success message and navigate to invoice created screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result[ApiConstants.messageKey] ?? 'Invoice created successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        // Show success dialog with options
        _showSuccessDialog(result['invoice']);
      } else {
        // Show error message
        final errorMessage = result[ApiConstants.messageKey] ?? 'Failed to create invoice';
        final errorType = result[ApiConstants.errorKey] ?? 'Unknown Error';
        
        _showErrorDialog('$errorMessage\n\nError Type: $errorType');
      }
    } catch (e) {
      // Reset loading state
      setState(() {
        _isCreatingInvoice = false;
      });
      
      // Show error message
      _showErrorDialog('An error occurred: ${e.toString()}');
    }
  }

  // Show Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Error', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Please check your input and try again.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Retry creating the invoice
                _createInvoice();
              },
              child: Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  // Format Payment Type for API
  String _formatPaymentType(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'cash':
        return 'cash';
      case 'card':
        return 'card';
      case 'upi':
        return 'upi';
      case 'bank transfer':
        return 'bank_transfer';
      default:
        return 'cash';
    }
  }

  // Clear Form Method
  void _clearForm() {
    setState(() {
      // Clear items
      items.clear();
      
      // Clear additional charges
      additionalCharges.clear();
      
      // Clear discount
      discountValueController.clear();
      isDiscountExpanded = false;
      
      // Clear roundoff
      roundoffController.clear();
      isRoundoffExpanded = false;
      
      // Clear customer information
      customerNameController.clear();
      phoneController.clear();
      
      // Clear payment and notes
      notesController.clear();
      amountReceivedController.clear();
      
      // Reset payment type to default
      paymentType = 'Cash';
      
      // Reset additional charges expansion
      isAdditionalChargesExpanded = false;
    });
  }

  // Show Success Dialog
  void _showSuccessDialog(Map<String, dynamic>? invoiceData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text('Invoice Created!', style: TextStyle(color: Colors.green)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your invoice has been created successfully!',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              if (invoiceData != null && invoiceData['id'] != null)
                Text(
                  'Invoice ID: ${invoiceData['id']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              SizedBox(height: 16),
              Text(
                'What would you like to do next?',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to invoice created screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvoiceCreatedScreen(
                      items: items,
                      subtotal: subtotal, 
                      discount: discount,
                      tax: tax,
                      additionalCharges: additionalCharges,
                      additionalChargesTotal: additionalChargesTotal,
                      roundoff: _calculateRoundoff(),
                      total: total,
                      invoiceNumber: invoiceData?['id']?.toString() ?? 'INV-${DateTime.now().millisecondsSinceEpoch}',
                      date: DateTime.now(),
                      customerName: customerNameController.text,
                      customerPhone: phoneController.text,
                      notes: notesController.text,
                      paymentType: paymentType,
                      amountReceived: double.tryParse(amountReceivedController.text) ?? total,
                    ),
                  ),
                );
              },
              child: Text('View Invoice'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Clear form and create another invoice
                _clearForm();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Form cleared. Ready to create another invoice!'),
                    backgroundColor: Colors.blue,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Create Another'),
            ),
          ],
        );
      },
    );
  }

  // Save Invoice Data Locally (for offline access)
  void _saveInvoiceLocally(Map<String, dynamic> invoiceData) {
    // TODO: Implement local storage for offline access
    // This could use SharedPreferences, Hive, or SQLite

  }

  // Share Invoice (placeholder for future implementation)
  void _shareInvoice(Map<String, dynamic> invoiceData) {
    // TODO: Implement sharing functionality
    // This could use the share_plus package or other sharing methods

    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing functionality coming soon!'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Print Invoice (placeholder for future implementation)
  void _printInvoice(Map<String, dynamic> invoiceData) {
    // TODO: Implement printing functionality
    // This could use the printing package or other printing methods

    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing functionality coming soon!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Export Invoice (placeholder for future implementation)
  void _exportInvoice(Map<String, dynamic> invoiceData) {
    // TODO: Implement export functionality
    // This could export to PDF, Excel, or other formats

    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export functionality coming soon!'),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }



  // Validate Form
  bool _validateForm() {
    // Check if customer name is provided
    if (customerNameController.text.trim().isEmpty) {
      _showErrorDialog('Customer name is required');
      return false;
    }

    // Check if phone number is provided and valid
    if (phoneController.text.trim().isEmpty) {
      _showErrorDialog('Phone number is required');
      return false;
    }

    if (phoneController.text.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phoneController.text)) {
      _showErrorDialog('Phone number must be 10 digits');
      return false;
    }

    // Check if items are added
    if (items.isEmpty) {
      _showErrorDialog('Please add at least one item to create an invoice');
      return false;
    }

    // Check if amount received is valid
    final amountReceived = double.tryParse(amountReceivedController.text) ?? total;
    if (amountReceived < total) {
      _showErrorDialog('Amount received cannot be less than total amount');
      return false;
    }

    return true;
  }

}




