import 'package:flutter/material.dart';
import 'invoice_created_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  _CreateInvoiceScreenState createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final List<Map<String, dynamic>> items = [];
  final TextEditingController itemController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController tableController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController amountReceivedController = TextEditingController();
  String paymentType = 'Cash';

  // Theme colors matching the app
  static const Color primaryColor = Color(0xFF2E3085); // App's blue
  static const Color secondaryColor = Color(0xFF4E4AA8); // App's lighter blue
  static const Color backgroundColor = Color(0xFFFAFBFC);
  static const Color cardColor = Colors.white;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + (item['qty'] * item['price']));
  double get discount => double.tryParse(discountController.text) ?? 0;
  double get tax => double.tryParse(taxController.text) ?? 0;
  double get total => subtotal - discount + tax;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: backgroundColor,
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
                           'Invoice #2',
                           style: theme.textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.w600,
                             color: Colors.black87,
                           ),
                         ),
                         Container(
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
                       ],
                     ),
                     SizedBox(height: 4),
                     Text(
                       '03 Aug 2025',
                       style: theme.textTheme.bodyMedium?.copyWith(
                         color: Colors.grey[600],
                         fontSize: 13,
                       ),
                     ),
                     Text(
                       '- 7 day(s) to due',
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
                         Row(
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
                               Icons.keyboard_arrow_up,
                               color: primaryColor,
                               size: 18,
                             ),
                           ],
                         ),
                         TextButton(
                           onPressed: () {
                             _showAddItemDialog(context);
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
                         final itemTax = itemTotal * (item['taxRate'] / 100);
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
                                         child: Text(
                                           'EDIT',
                                           style: theme.textTheme.bodySmall?.copyWith(
                                             fontWeight: FontWeight.w600,
                                             color: primaryColor,
                                             fontSize: 9,
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
                                 '${item['taxRate']}% = ${itemTax.toStringAsFixed(2)}',
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
                   children: [
                     Row(
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
                           '${subtotal.toStringAsFixed(2)}',
                           style: theme.textTheme.bodyMedium?.copyWith(
                             fontWeight: FontWeight.w600,
                             color: Colors.black87,
                             fontSize: 14,
                           ),
                         ),
                       ],
                     ),
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
                     Text(
                       'Customer Information',
                       style: theme.textTheme.titleMedium?.copyWith(
                         fontWeight: FontWeight.w600,
                         color: Colors.black87,
                         fontSize: 14,
                       ),
                     ),
                     SizedBox(height: 12),
                     Row(
                       children: [
                         Expanded(
                           child: TextField(
                             controller: customerNameController,
                             decoration: InputDecoration(
                               labelText: 'Customer Name',
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                             ),
                           ),
                         ),
                         SizedBox(width: 12),
                         Expanded(
                           child: TextField(
                             controller: phoneController,
                             decoration: InputDecoration(
                               labelText: 'Phone Number',
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                             ),
                           ),
                         ),
                       ],
                     ),
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
                     Container(
                       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                       decoration: BoxDecoration(
                         border: Border.all(color: Colors.grey[300]!),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: DropdownButtonFormField<String>(
                         value: paymentType,
                         decoration: InputDecoration(
                           labelText: 'Payment Type',
                           border: InputBorder.none,
                           contentPadding: EdgeInsets.zero,
                         ),
                         items: ['Cash', 'Card', 'UPI', 'Bank Transfer'].map((String value) {
                           return DropdownMenuItem<String>(
                             value: value,
                             child: Text(value),
                           );
                         }).toList(),
                         onChanged: (String? newValue) {
                           setState(() {
                             paymentType = newValue!;
                           });
                         },
                       ),
                     ),
                     SizedBox(height: 12),
                     Row(
                       children: [
                         Expanded(
                           child: TextField(
                             controller: amountReceivedController,
                             keyboardType: TextInputType.number,
                             decoration: InputDecoration(
                               labelText: 'Amount Received',
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                             ),
                           ),
                         ),
                         SizedBox(width: 12),
                         Expanded(
                           child: TextField(
                             controller: notesController,
                             decoration: InputDecoration(
                               labelText: 'Notes',
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
             Container(
               width: double.infinity,
               height: 48,
               decoration: BoxDecoration(
                 color: items.isEmpty ? Colors.grey[400] : primaryColor,
                 borderRadius: BorderRadius.circular(8),
                 boxShadow: items.isEmpty ? [] : [
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
                   onTap: items.isEmpty ? null : () {
                     // Navigate to invoice created screen
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => InvoiceCreatedScreen(
                           items: items,
                           subtotal: subtotal,
                           discount: discount,
                           tax: tax,
                           total: total,
                           invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
                           date: DateTime.now(),
                           customerName: customerNameController.text,
                           customerPhone: phoneController.text,
                           notes: notesController.text,
                           paymentType: paymentType,
                           amountReceived: double.tryParse(amountReceivedController.text) ?? 0,
                         ),
                       ),
                     );
                   },
                   child: Center(
                     child: Text(
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
             SizedBox(height: 12),

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

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Add Item',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
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
                addItem();
                Navigator.of(context).pop();
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
}

class InvoicePreviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Example data for preview
    final items = [
      {'name': 'Paneer Tikka', 'qty': 2, 'price': 250.0},
      {'name': 'Butter Naan', 'qty': 4, 'price': 60.0},
      {'name': 'Lassi', 'qty': 2, 'price': 80.0},
    ];
    final subtotal = 250.0 * 2 + 60.0 * 4 + 80.0 * 2;
    final discount = 50.0;
    final tax = 60.0;
    final total = subtotal - discount + tax;
    final invoiceNumber = 'INV-20250801-001';
    final date = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invoice Preview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.restaurant, size: 40, color: Colors.deepOrange),
                    SizedBox(width: 12),
                    Text(
                      'My Restaurant',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '123 Main Street, City',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Invoice #: $invoiceNumber'),
                    Text('${date.day}/${date.month}/${date.year}'),
                  ],
                ),
                SizedBox(height: 16),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Total')),
                  ],
                  rows:
                      items.map((item) {
                        final name = item['name']?.toString() ?? '';
                        final qty =
                            item['qty'] is int
                                ? item['qty'] as int
                                : int.tryParse(item['qty'].toString()) ?? 0;
                        final price =
                            item['price'] is double
                                ? item['price'] as double
                                : double.tryParse(item['price'].toString()) ??
                                    0.0;
                        return DataRow(
                          cells: [
                            DataCell(Text(name)),
                            DataCell(Text(qty.toString())),
                            DataCell(Text('₹${price.toStringAsFixed(2)}')),
                            DataCell(
                              Text('₹${(qty * price).toStringAsFixed(2)}'),
                            ),
                          ],
                        );
                      }).toList(),
                ),
                Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Subtotal: ₹${subtotal.toStringAsFixed(2)}'),
                        Text('Discount: ₹${discount.toStringAsFixed(2)}'),
                        Text('Tax: ₹${tax.toStringAsFixed(2)}'),
                        SizedBox(height: 8),
                        Text(
                          'Grand Total: ₹${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Print feature coming soon')),
                      );
                    },
                    icon: Icon(Icons.print),
                    label: Text('Print Invoice'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

