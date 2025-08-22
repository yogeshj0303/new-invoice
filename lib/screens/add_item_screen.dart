import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../widgets/edit_bottom_sheet_content.dart';
import 'create_invoice.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // Theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);

  final _searchController = TextEditingController();
  String _selectedCategory = 'All Categories';
  final List<String> _categories = ['All Categories', 'Food', 'Beverages', 'Snacks', 'Electronics'];
  
  // Track which items are in cart mode
  final Set<int> _itemsInCart = {};
  final Map<int, int> _itemQuantities = {};
  
  List<Item> _items = [];
  List<Item> _filteredItems = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await ApiService.getItems('1'); // TODO: Get actual user ID from auth service
      
      if (result['success'] == true) {
        setState(() {
          _items = result['items'] as List<Item>;
          _filteredItems = _items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = result[ApiConstants.messageKey] ?? 'Failed to load items';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    setState(() {
      _filteredItems = _items.where((item) {
        final matchesSearch = item.itemName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            item.id.toString().contains(_searchController.text.toLowerCase());
        final matchesCategory = _selectedCategory == 'All Categories' || 
                               (item.details.itemCategoryId != null && _getCategoryName(item.details.itemCategoryId!) == _selectedCategory);
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  String _getCategoryName(int categoryId) {
    final categoryMap = {
      1: 'Food',
      2: 'Beverages',
      3: 'Snacks',
      4: 'Dairy',
      5: 'Fruits',
      6: 'Vegetables',
    };
    return categoryMap[categoryId] ?? 'Other';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchAndFilters(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _hasError
                        ? _buildErrorState()
                        : _buildItemList(),
              ),
              // Show bottom section only when items are in cart
              if (_itemsInCart.isNotEmpty) _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Loading items...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadItems,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Icon(
                Icons.arrow_back,
                color: primaryColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Icon(
                    Icons.search,
                    color: primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _filterItems(),
                      style: const TextStyle(fontSize: 13, height: 1.2),
                      decoration: InputDecoration(
                        hintText: 'Search by name or code',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[50]!),
                        ),
                        hintStyle: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 13,
                          height: 1.2,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    child: IconButton(
                      icon: Icon(
                        Icons.qr_code_scanner,
                        color: primaryColor,
                        size: 16,
                      ),
                      onPressed: () {
                        // TODO: Implement QR code scanning
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    child: IconButton(
                      icon: Icon(
                        Icons.mic,
                        color: primaryColor,
                        size: 16,
                      ),
                      onPressed: () {
                        // TODO: Implement voice search
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCreateButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedCategory,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => _categories.map((category) {
        return PopupMenuItem<String>(
          value: category,
          child: Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: category == _selectedCategory ? primaryColor : Colors.grey[700],
            ),
          ),
        );
      }).toList(),
      onSelected: (category) {
        setState(() {
          _selectedCategory = category;
        });
        _filterItems();
      },
    );
  }

  Widget _buildCreateButton() {
    return InkWell(
      onTap: _navigateToCreateItem,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: primaryColor,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'Create New Item',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList() {
    if (_filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadItems,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return _buildItemCard(item);
        },
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    // Get the first pricing and stock info
    final pricing = item.pricings.isNotEmpty ? item.pricings.first : null;
    final stock = item.stocks.isNotEmpty ? item.stocks.first : null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Item Icon/Image
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                item.itemName.isNotEmpty ? item.itemName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '₹ ${pricing?.salespriceAmount ?? '0.00'}/${pricing?.unit ?? 'PCS'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[500],
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'STOCK: ${stock?.openingStock ?? 0}${pricing?.unit ?? 'PCS'}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: (stock?.openingStock ?? 0) < 0 ? Colors.red[600] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Add Button or Cart Controls
          _itemsInCart.contains(item.id) 
            ? _buildCartControls(item)
            : _buildAddButton(item),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or category filter',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _addItemToCart(Item item) {
    setState(() {
      if (_itemsInCart.contains(item.id)) {
        // Remove from cart
        _itemsInCart.remove(item.id);
        _itemQuantities.remove(item.id);
      } else {
        // Add to cart
        _itemsInCart.add(item.id);
        _itemQuantities[item.id] = 1;
      }
    });
  }

  void _incrementQuantity(int itemId) {
    setState(() {
      _itemQuantities[itemId] = (_itemQuantities[itemId] ?? 1) + 1;
    });
  }

  void _decrementQuantity(int itemId) {
    setState(() {
      final currentQty = _itemQuantities[itemId] ?? 1;
      if (currentQty > 1) {
        _itemQuantities[itemId] = currentQty - 1;
      } else {
        // Remove from cart if quantity becomes 0
        _itemsInCart.remove(itemId);
        _itemQuantities.remove(itemId);
      }
    });
  }

  void _editItem(Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _buildEditBottomSheet(item);
      },
    );
  }

  Widget _buildAddButton(Item item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: primaryColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _addItemToCart(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'ADD +',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartControls(Item item) {
    final quantity = _itemQuantities[item.id] ?? 1;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Button
        Container(
          width: 60,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => _editItem(item),
              child: Center(
                child: Text(
                  'EDIT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Quantity Controls
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(3),
                  onTap: () => _decrementQuantity(item.id),
                  child: Center(
                    child: Icon(
                      Icons.remove,
                      size: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 24,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Text(
                  '$quantity',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(3),
                  onTap: () => _incrementQuantity(item.id),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
          onItemUpdated: () {
            // Refresh the items list when an item is updated
            print('🔄 [DEBUG] AddItemScreen: Item updated via bottom sheet, refreshing items...');
            _loadItems();
          },
        );
      },
    );
  }

  Widget _buildBottomSection() {
    final totalQuantity = _calculateTotalQuantity();
    final totalPrice = _calculateTotalPrice();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Bottom section with additional details and generate bill button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left side - Additional details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to create invoice screen with cart data
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CreateInvoiceScreen(
                                cartItems: _getCartItemsForInvoice(),
                                itemQuantities: _itemQuantities,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Add more details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Additional charges, Round off...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right side - Generate Bill button
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        // Navigate to create invoice screen to generate bill
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CreateInvoiceScreen(
                              cartItems: _getCartItemsForInvoice(),
                              itemQuantities: _itemQuantities,
                            ),
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          'Generate Bill',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (final itemId in _itemsInCart) {
      final item = _items.firstWhere((i) => i.id == itemId);
      final quantity = _itemQuantities[itemId] ?? 1;
      final pricing = item.pricings.isNotEmpty ? item.pricings.first : null;
      final price = pricing?.salespriceAmount != null ? double.tryParse(pricing!.salespriceAmount!) ?? 0.0 : 0.0;
      total += price * quantity;
    }
    return total;
  }

  double _calculateTotalQuantity() {
    double total = 0;
    for (final itemId in _itemsInCart) {
      total += _itemQuantities[itemId] ?? 1;
    }
    return total;
  }

  void _navigateToCreateItem() {
    Navigator.of(context).pushNamed('/create-item');
  }

  // Helper method to get cart items for invoice screen
  List<Map<String, dynamic>> _getCartItemsForInvoice() {
    return _itemsInCart.map((itemId) {
      final item = _items.firstWhere((i) => i.id == itemId);
      final quantity = _itemQuantities[itemId] ?? 1;
      final pricing = item.pricings.isNotEmpty ? item.pricings.first : null;
      return {
        'id': item.id,
        'name': item.itemName,
        'description': item.details.itemDescription ?? '',
        'price': pricing?.salespriceAmount != null ? double.tryParse(pricing!.salespriceAmount!) ?? 0.0 : 0.0,
        'qty': quantity,
        'unit': pricing?.unit ?? 'PCS',
        'category': item.details.itemCategoryId != null ? _getCategoryName(item.details.itemCategoryId!) : 'Other',
      };
    }).toList();
  }
}