import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/item.dart';
import 'create_item_screen.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  // Theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);

  List<Item> _items = [];
  String _selectedCategory = 'All Items';
  String _selectedStockFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadItems() {
    // Sample data
    _items = [
      Item(
        id: '1',
        name: 'Margherita Pizza',
        description: 'Classic Margherita Pizza',
        salesPrice: 12.99,
        purchasePrice: 8.99,
        category: 'Pizza',
        unit: 'pieces',
        stockQuantity: 50,
        createdAt: DateTime.now(),
      ),
      Item(
        id: '2',
        name: 'Chicken Burger',
        description: 'Grilled Chicken Burger',
        salesPrice: 8.99,
        purchasePrice: 5.99,
        category: 'Burgers',
        unit: 'pieces',
        stockQuantity: 30,
        createdAt: DateTime.now(),
      ),
      Item(
        id: '3',
        name: 'French Fries',
        description: 'Crispy French Fries',
        salesPrice: 4.99,
        purchasePrice: 2.99,
        category: 'Sides',
        unit: 'servings',
        stockQuantity: 100,
        createdAt: DateTime.now(),
      ),
      Item(
        id: '4',
        name: 'Coca Cola',
        description: 'Refreshing Coca Cola',
        salesPrice: 2.99,
        purchasePrice: 1.99,
        category: 'Beverages',
        unit: 'bottles',
        stockQuantity: 200,
        createdAt: DateTime.now(),
      ),
    ];
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child:
                filteredItems.isEmpty
                    ? _buildEmptyState()
                    : _buildItemsList(filteredItems),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: _isSearching
              ? Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search items by name or description...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: primaryColor,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Text(
                  'Items',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.1,
                    color: Colors.black87,
                  ),
                ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_isSearching) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                    _isSearching = !_isSearching;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: _isSearching ? Colors.red[400] : Colors.grey[600],
                    size: 18,
                  ),
                ),
              ),
            ),
            if (!_isSearching)
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateItemScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.white,
      child: Row(
        children: [
          // Low Stock Toggle
          FilterChip(
            label: const Text('Low Stock', style: TextStyle(fontSize: 13)),
            selected: false, // This state variable is not used in the new code
            onSelected: (bool value) {
              // setState(() {
              //   _showLowStock = value;
              // });
            },
            backgroundColor: Colors.white,
            selectedColor: primaryColor.withOpacity(0.1),
            checkmarkColor: primaryColor,
            labelStyle: TextStyle(
              color:
                  false
                      ? primaryColor
                      : Colors
                          .grey[800], // This state variable is not used in the new code
              fontWeight:
                  false
                      ? FontWeight.w500
                      : FontWeight
                          .normal, // This state variable is not used in the new code
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color:
                    false
                        ? primaryColor
                        : Colors.grey.withOpacity(
                          0.3,
                        ), // This state variable is not used in the new code
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Category Dropdown
          Expanded(
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  iconSize: 20,
                  elevation: 1,
                  isExpanded: true,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items:
                      <String>[
                        'All Items',
                        'Food',
                        'Beverages',
                        'Desserts',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter Button
          InkWell(
            onTap: () {
              _showFilterDialog(context);
            },
            child: Container(
              height: 32,
              width: 70,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tune, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    'All',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(List<Item> items) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: 8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No items found. Add a new item!',
        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.grey[300]!, Colors.grey[500]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'S',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.stockQuantity.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.unit.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Price',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹ ${item.salesPrice}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purchase Price',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹ ${item.purchasePrice}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                                         Container(
                       padding: const EdgeInsets.all(6),
                       decoration: BoxDecoration(
                         color: Colors.grey[50],
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(
                           color: Colors.grey.withOpacity(0.2),
                           width: 1,
                         ),
                       ),
                       child: Icon(
                         Icons.tune,
                         size: 16,
                         color: primaryColor,
                       ),
                     ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort by',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                              'A-Z',
                              'Z-A',
                              'Price: Low to High',
                              'Price: High to Low',
                            ]
                            .map(
                              (sort) => ChoiceChip(
                                label: Text(sort),
                                selected:
                                    false, // This state variable is not used in the new code
                                onSelected: (bool selected) {
                                  // if (selected) {
                                  //   setState(() {
                                  //     _sortBy = sort;
                                  //   });
                                  //   this.setState(() {});
                                  // }
                                },
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Filter by',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children:
                        ['All Items', 'Low Stock', 'In Stock', 'Not in Stock']
                            .map(
                              (filter) => ChoiceChip(
                                label: Text(filter),
                                selected:
                                    false, // This state variable is not used in the new code
                                onSelected: (bool selected) {
                                  // if (selected) {
                                  //   setState(() {
                                  //     _stockFilter = filter;
                                  //   });
                                  //   this.setState(() {});
                                  // }
                                },
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('In Online Store'),
                    value:
                        false, // This state variable is not used in the new code
                    onChanged: (bool value) {
                      // setState(() {
                      //   _isOnlineStore = value;
                      // });
                      this.setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Item> _getFilteredItems() {
    List<Item> filteredItems = List.from(_items);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        final name = item.name.toLowerCase();
        final description = item.description.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All Items') {
      filteredItems =
          filteredItems
              .where((item) => item.category == _selectedCategory)
              .toList();
    }

    // Apply stock filter
    // switch (_stockFilter) { // This state variable is not used in the new code
    //   case 'Low Stock':
    //     filteredItems = filteredItems.where((item) => item.isLowStock).toList();
    //     break;
    //   case 'In Stock':
    //     filteredItems =
    //         filteredItems.where((item) => item.stockQuantity > 0).toList();
    //     break;
    //   case 'Not in Stock':
    //     filteredItems =
    //         filteredItems.where((item) => item.stockQuantity <= 0).toList();
    //     break;
    // }

    // Apply online store filter
    // if (_isOnlineStore) { // This state variable is not used in the new code
    //   // Add your online store filtering logic here
    //   // For example: filteredItems = filteredItems.where((item) => item.isOnlineEnabled).toList();
    // }

    // Apply sorting
    // switch (_sortBy) { // This state variable is not used in the new code
    //   case 'A-Z':
    //     filteredItems.sort((a, b) => a.name.compareTo(b.name));
    //     break;
    //   case 'Z-A':
    //     filteredItems.sort((a, b) => b.name.compareTo(a.name));
    //     break;
    //   case 'Price: Low to High':
    //     filteredItems.sort((a, b) => a.salesPrice.compareTo(b.salesPrice));
    //     break;
    //   case 'Price: High to Low':
    //     filteredItems.sort((a, b) => b.salesPrice.compareTo(a.salesPrice));
    //     break;
    // }

    return filteredItems;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
