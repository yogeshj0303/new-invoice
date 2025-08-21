import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
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
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Filter states
  bool _showLowStockOnly = false;
  String _selectedSortBy = 'A-Z';
  String _selectedFilterBy = 'All Items';
  bool _showOnlineStoreOnly = false;
  
  // Categories from API
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = false;
  
  // Get unique categories from items
  List<String> get _availableCategories {
    final categories = <String>['All Items'];
    final seenNames = <String>{};
    
    for (final category in _categories) {
      final categoryName = category['item_category_name'] as String?;
      if (categoryName != null && categoryName.isNotEmpty) {
        // Handle duplicate category names by adding ID suffix
        String uniqueName = categoryName;
        int counter = 1;
        
        while (seenNames.contains(uniqueName)) {
          uniqueName = '$categoryName (${counter++})';
        }
        
        seenNames.add(uniqueName);
        categories.add(uniqueName);
      }
    }
    return categories;
  }

  // Check if any filters are active
  bool get _hasActiveFilters {
    return _showLowStockOnly || 
           _selectedCategory != 'All Items' || 
           _selectedFilterBy != 'All Items' || 
           _showOnlineStoreOnly || 
           _selectedSortBy != 'A-Z';
  }

  // Reset all filters
  void _resetAllFilters() {
    setState(() {
      _showLowStockOnly = false;
      _selectedCategory = 'All Items';
      _selectedFilterBy = 'All Items';
      _showOnlineStoreOnly = false;
      _selectedSortBy = 'A-Z';
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
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

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final response = await ApiService.getItemCategories();
      
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response['data']);
        });
        
        // Check if the currently selected category still exists
        if (_selectedCategory != 'All Items') {
          final categoryExists = _categories.any(
            (cat) {
              final catName = cat['item_category_name'] as String?;
              if (catName == null) return false;
              
              // Check if it's an exact match
              if (catName == _selectedCategory) return true;
              
              // Check if it's a name with ID suffix (e.g., "new (1)" matches "new")
              if (_selectedCategory.startsWith('$catName (')) return true;
              
              return false;
            }
          );
          if (!categoryExists) {
            setState(() {
              _selectedCategory = 'All Items';
            });
          }
        }
      } else {
        setState(() {
          _categories = [];
          _selectedCategory = 'All Items';
        });
      }
    } catch (e) {
      setState(() {
        _categories = [];
        _selectedCategory = 'All Items';
      });
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  // Refresh both items and categories
  Future<void> _refreshAll() async {
    await Future.wait([
      _loadItems(),
      _loadCategories(),
    ]);
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
            child: _isLoading
                ? _buildLoadingState()
                : _hasError
                    ? _buildErrorState()
                    : filteredItems.isEmpty
                        ? _buildEmptyState()
                        : _buildItemsList(filteredItems),
          ),
        ],
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
          automaticallyImplyLeading: false,
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
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateItemScreen()),
                    );
                    // Refresh items after creating a new one
                    if (result == true) {
                      _loadItems();
                    }
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active filters indicator
          if (_hasActiveFilters)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_getActiveFilterCount()} active',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          if (_hasActiveFilters) const SizedBox(height: 8),
          
          // Filter chips row
          Row(
            children: [
              // Low Stock Toggle
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _showLowStockOnly 
                        ? primaryColor 
                        : Colors.grey.withOpacity(0.3),
                    width: _showLowStockOnly ? 1.5 : 1,
                  ),
                  color: _showLowStockOnly 
                      ? primaryColor.withOpacity(0.1) 
                      : Colors.white,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      setState(() {
                        _showLowStockOnly = !_showLowStockOnly;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showLowStockOnly ? Icons.inventory_2 : Icons.inventory_2_outlined,
                            size: 14,
                            color: _showLowStockOnly ? primaryColor : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Low Stock',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _showLowStockOnly ? FontWeight.w600 : FontWeight.w500,
                              color: _showLowStockOnly ? primaryColor : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Category Dropdown
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedCategory != 'All Items' 
                          ? primaryColor.withOpacity(0.5) 
                          : Colors.grey.withOpacity(0.3),
                      width: _selectedCategory != 'All Items' ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    color: _selectedCategory != 'All Items' 
                        ? primaryColor.withOpacity(0.05) 
                        : Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _selectedCategory != 'All Items' ? primaryColor : Colors.grey[600],
                        size: 18,
                      ),
                      iconSize: 18,
                      elevation: 3,
                      isExpanded: true,
                      style: TextStyle(
                        color: _selectedCategory != 'All Items' ? primaryColor : Colors.grey[700],
                        fontSize: 12,
                        fontWeight: _selectedCategory != 'All Items' ? FontWeight.w600 : FontWeight.w500,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      items: _isLoadingCategories 
                        ? ['Loading...'].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Icon(Icons.category_outlined, size: 14, color: Colors.grey[400]),
                                  const SizedBox(width: 6),
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList()
                        : _availableCategories.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Icon(
                                    value == 'All Items' ? Icons.category_outlined : Icons.category,
                                    size: 14,
                                    color: value == 'All Items' ? Colors.grey[400] : primaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Advanced Filters Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _hasActiveFilters ? primaryColor : Colors.grey.withOpacity(0.3),
                    width: _hasActiveFilters ? 1.5 : 1,
                  ),
                  color: _hasActiveFilters ? primaryColor.withOpacity(0.1) : Colors.white,
                  boxShadow: _hasActiveFilters ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      _showFilterDialog(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 14,
                            color: _hasActiveFilters ? primaryColor : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'More',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _hasActiveFilters ? FontWeight.w600 : FontWeight.w500,
                              color: _hasActiveFilters ? primaryColor : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Active filters summary
          if (_hasActiveFilters) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      size: 14,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Filters',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _getActiveFilterSummary(),
                          style: TextStyle(
                            fontSize: 10,
                            color: primaryColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _resetAllFilters,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getFilterButtonText() {
    if (_isLoadingCategories) return 'Loading...';
    if (_selectedFilterBy != 'All Items') return _selectedFilterBy;
    if (_showOnlineStoreOnly) return 'Online';
    if (_selectedSortBy != 'A-Z') return 'Sorted';
    if (_showLowStockOnly) return 'Low Stock';
    return 'All';
  }

  Widget _buildItemsList(List<Item> items) {
    final totalItems = _items.length;
    final showingItems = items.length;
    
    return Column(
      children: [
        // Results count indicator
        if (_hasActiveFilters || _searchQuery.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[50],
            child: Text(
              'Showing $showingItems of $totalItems items',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        // Items list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshAll,
            color: primaryColor,
            child: ListView.builder(
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _hasActiveFilters || _searchQuery.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_list_off : Icons.inventory_2_outlined,
            size: 64,
            color: hasFilters ? Colors.orange[400] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No items match your filters' : 'No items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters 
              ? 'Try adjusting your search or filter criteria'
              : 'Add your first item to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (hasFilters)
            ElevatedButton(
              onPressed: _resetAllFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Clear All Filters'),
            )
          else
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateItemScreen()),
                );
                if (result == true) {
                  _loadItems();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Item item) {
    // Get the first pricing and stock info
    final pricing = item.pricings.isNotEmpty ? item.pricings.first : null;
    final stock = item.stocks.isNotEmpty ? item.stocks.first : null;
    
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
          onTap: () {
            // TODO: Navigate to item detail/edit screen
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item image or placeholder
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
                          item.itemName.isNotEmpty ? item.itemName[0].toUpperCase() : 'I',
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
                            item.itemName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.details.itemDescription ?? 'No description',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          stock?.openingStock?.toString() ?? '0',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pricing?.unit?.toUpperCase() ?? 'PCS',
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
                    const SizedBox(width: 50),
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
                          pricing?.salespriceAmount != null 
                              ? '₹ ${pricing!.salespriceAmount}'
                              : '₹ 0.00',
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
                          pricing?.purchesPriceAmount != null 
                              ? '₹ ${pricing!.purchesPriceAmount}'
                              : '₹ 0.00',
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
                // Show additional info if available
                if (pricing?.gst != null || stock?.lowAlertStatus == 'true') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 50),
                      if (pricing?.gst != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Text(
                            'GST: ${pricing!.gst}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (stock?.lowAlertStatus == 'true') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Text(
                            'Low Stock',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 4),
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Advanced Filters',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[900],
                                ),
                              ),
                              Text(
                                'Customize your item view',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_hasActiveFilters)
                          TextButton(
                            onPressed: _resetAllFilters,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              backgroundColor: Colors.red[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Reset All',
                              style: TextStyle(
                                color: Colors.red[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Active filters summary
                          if (_hasActiveFilters) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: primaryColor.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.filter_list_rounded,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${_getActiveFilterCount()} active filters: ${_getActiveFilterSummary()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: primaryColor.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Sort by section
                          _buildFilterSection(
                            title: 'Sort Items',
                            subtitle: 'Choose how to organize your items',
                            icon: Icons.sort_rounded,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  'A-Z',
                                  'Z-A',
                                  'Price: Low to High',
                                  'Price: High to Low',
                                ].map(
                                  (sort) => _buildChoiceChip(
                                    label: sort,
                                    selected: _selectedSortBy == sort,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        _selectedSortBy = selected ? sort : 'A-Z';
                                      });
                                      this.setState(() {});
                                    },
                                  ),
                                ).toList(),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Filter by section
                          _buildFilterSection(
                            title: 'Stock Status',
                            subtitle: 'Filter items by their stock availability',
                            icon: Icons.inventory_2_rounded,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: ['All Items', 'Low Stock', 'In Stock', 'Not in Stock']
                                    .map(
                                      (filter) => _buildChoiceChip(
                                        label: filter,
                                        selected: _selectedFilterBy == filter,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            _selectedFilterBy = selected ? filter : 'All Items';
                                          });
                                          this.setState(() {});
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom actions
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Apply Filters',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Safe area padding
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildFilterSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
  
  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? primaryColor : Colors.grey.withOpacity(0.3),
          width: selected ? 1.5 : 1,
        ),
        color: selected ? primaryColor.withOpacity(0.1) : Colors.white,
        boxShadow: selected ? [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onSelected(!selected),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? primaryColor : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Item> _getFilteredItems() {
    List<Item> filteredItems = List.from(_items);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        final name = item.itemName.toLowerCase();
        final description = (item.details.itemDescription ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    // Apply low stock filter
    if (_showLowStockOnly) {
      filteredItems = filteredItems.where((item) {
        return item.stocks.any((stock) => stock.lowAlertStatus == 'true');
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All Items') {
      // Find the category ID from the selected category name
      // Handle both original names and names with ID suffixes
      final selectedCategory = _categories.firstWhere(
        (cat) {
          final catName = cat['item_category_name'] as String?;
          if (catName == null) return false;
          
          // Check if it's an exact match
          if (catName == _selectedCategory) return true;
          
          // Check if it's a name with ID suffix (e.g., "new (1)" matches "new")
          if (_selectedCategory.startsWith('$catName (')) return true;
          
          return false;
        },
        orElse: () => <String, dynamic>{},
      );
      
      if (selectedCategory.isNotEmpty) {
        final categoryId = selectedCategory['id'] as int?;
        if (categoryId != null) {
          filteredItems = filteredItems.where((item) {
            return item.details.itemCategoryId == categoryId;
          }).toList();
        }
      }
    }

    // Apply stock filter
    if (_selectedFilterBy != 'All Items') {
      switch (_selectedFilterBy) {
        case 'Low Stock':
          filteredItems = filteredItems.where((item) {
            return item.stocks.any((stock) => stock.lowAlertStatus == 'true');
          }).toList();
          break;
        case 'In Stock':
          filteredItems = filteredItems.where((item) {
            return item.stocks.any((stock) => stock.openingStock > 0);
          }).toList();
          break;
        case 'Not in Stock':
          filteredItems = filteredItems.where((item) {
            return item.stocks.every((stock) => stock.openingStock <= 0);
          }).toList();
          break;
      }
    }

    // Apply online store filter
    if (_showOnlineStoreOnly) {
      filteredItems = filteredItems.where((item) {
        return item.details.showOnlineStore == 'true';
      }).toList();
    }

    // Apply sorting
    switch (_selectedSortBy) {
      case 'A-Z':
        filteredItems.sort((a, b) => a.itemName.compareTo(b.itemName));
        break;
      case 'Z-A':
        filteredItems.sort((a, b) => b.itemName.compareTo(a.itemName));
        break;
      case 'Price: Low to High':
        filteredItems.sort((a, b) {
          final aPrice = a.salesPrice;
          final bPrice = b.salesPrice;
          return aPrice.compareTo(bPrice);
        });
        break;
      case 'Price: High to Low':
        filteredItems.sort((a, b) {
          final aPrice = a.salesPrice;
          final bPrice = b.salesPrice;
          return bPrice.compareTo(aPrice);
        });
        break;
    }

    return filteredItems;
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_showLowStockOnly) count++;
    if (_selectedCategory != 'All Items') count++;
    if (_selectedFilterBy != 'All Items') count++;
    if (_showOnlineStoreOnly) count++;
    if (_selectedSortBy != 'A-Z') count++;
    if (_searchQuery.isNotEmpty) count++;
    return count;
  }

  String _getActiveFilterSummary() {
    final List<String> activeFilters = [];
    if (_showLowStockOnly) activeFilters.add('Low Stock');
    if (_selectedCategory != 'All Items') activeFilters.add(_selectedCategory);
    if (_selectedFilterBy != 'All Items') activeFilters.add(_selectedFilterBy);
    if (_showOnlineStoreOnly) activeFilters.add('Online Store');
    if (_selectedSortBy != 'A-Z') activeFilters.add(_selectedSortBy);
    if (_searchQuery.isNotEmpty) activeFilters.add('Search: "${_searchQuery}"');
    return activeFilters.join(', ');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
