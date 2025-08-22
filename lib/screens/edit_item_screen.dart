import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class EditItemScreen extends StatefulWidget {
  final Item item;
  
  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  // Theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _salesPriceController = TextEditingController();
  final _openingStockController = TextEditingController();
  final _itemDescriptionController = TextEditingController();

  String _selectedTab = 'Pricing';
  String _selectedCategory = 'Select Category';
  String _showOnlineStore = 'false';
  bool _isLoading = false;
  String? _selectedImagePath;
  String? _existingImagePath;

  // Categories from API
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = false;
  
  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _populateFields();
  }

  void _populateFields() {
    final item = widget.item;
    
    // Populate basic fields
    _nameController.text = item.itemName;
    
    // Populate pricing fields
    if (item.pricings.isNotEmpty) {
      final pricing = item.pricings.first;
      _unitController.text = pricing.unit;
      _salesPriceController.text = pricing.salespriceAmount ?? '';
    }
    
    // Populate stock fields
    if (item.stocks.isNotEmpty) {
      final stock = item.stocks.first;
      _openingStockController.text = stock.openingStock.toString();
    }
    
    // Populate other fields
    _itemDescriptionController.text = item.details.itemDescription ?? '';
    _showOnlineStore = item.details.showOnlineStore;
    
    // Set category
    if (item.details.itemCategoryId != null) {
      _selectedCategory = 'Category ID: ${item.details.itemCategoryId}';
    }
    
    // Set existing image
    if (item.otherImages.isNotEmpty) {
      _existingImagePath = item.otherImages.first.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _salesPriceController.dispose();
    _openingStockController.dispose();
    _itemDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFBFC),
        appBar: _buildAppBar(),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  _buildItemNameField(),
                  const SizedBox(height: 16),
                  _buildTabBar(),
                  const SizedBox(height: 12),
                  _buildTabContent(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1A1A1A),
            size: 16,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: const Text(
        'Edit Item',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }

  Widget _buildItemNameField() {
    return _buildCompactFormField(
      'Item Name',
      required: true,
      controller: _nameController,
      hintText: 'Ex: Kissan Fruit Jam 500 gm',
      icon: Icons.inventory_2_outlined,
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Expanded(child: _buildTab('Pricing', _selectedTab == 'Pricing')),
            Expanded(child: _buildTab('Stock', _selectedTab == 'Stock')),
            Expanded(child: _buildTab('Other', _selectedTab == 'Other')),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool selected) {
    return InkWell(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.transparent,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF666666),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _getTabContent(),
    );
  }

  Widget _getTabContent() {
    switch (_selectedTab) {
      case 'Pricing':
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildCompactFormField(
                    'Unit',
                    controller: _unitController,
                    hintText: 'PCS',
                    icon: Icons.straighten,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactFormField(
                    'Sales Price',
                    controller: _salesPriceController,
                    hintText: '₹ 130',
                    keyboardType: TextInputType.number,
                    icon: Icons.attach_money,
                  ),
                ),
              ],
            ),
          ],
        );
      case 'Stock':
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildCompactFormField(
                    'Opening Stock',
                    controller: _openingStockController,
                    hintText: 'Ex: 35',
                    keyboardType: TextInputType.number,
                    icon: Icons.inventory,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _unitController.text.isNotEmpty ? _unitController.text : 'PCS',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case 'Other':
        return Column(
          children: [
            _buildCompactImageUpload(),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactFormField(
                        'Item Category *${_categories.isNotEmpty ? ' (${_categories.length} available)' : ''}',
                        isDropdown: true,
                        value: _selectedCategory,
                        onChanged: (value) {
                          if (value == '➕ Add Category') {
                            _showAddCategoryBottomSheet();
                          } else {
                            setState(() => _selectedCategory = value!);
                          }
                        },
                        items: _isLoadingCategories 
                          ? ['Loading...'] 
                          : _categories.isEmpty 
                            ? ['No categories available', '➕ Add Category']
                            : ['Select Category', ..._categories.map((cat) {
                                final baseName = cat['item_category_name'] as String;
                                final categoryId = cat['id'] as int;
                                return '$baseName (ID: $categoryId)';
                              }), '➕ Add Category'],
                        icon: Icons.category_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: IconButton(
                          onPressed: _loadCategories,
                          icon: Icon(
                            _isLoadingCategories ? Icons.hourglass_empty : Icons.refresh,
                            color: _isLoadingCategories ? Colors.grey : primaryColor,
                            size: 20,
                          ),
                          tooltip: 'Refresh Categories',
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCompactSwitchTile(
              'Show in Online Store',
              Icons.storefront_outlined,
              _showOnlineStore == 'true',
              (value) => setState(() => _showOnlineStore = value ? 'true' : 'false'),
            ),
            const SizedBox(height: 12),
            _buildCompactFormField(
              'Item Description',
              controller: _itemDescriptionController,
              hintText: 'Ex: 100% Real Mixed Fruit Jam',
              keyboardType: TextInputType.multiline,
              maxLines: 2,
              icon: Icons.description_outlined,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCompactImageUpload() {
    final hasImage = _selectedImagePath != null || _existingImagePath != null;
    
    return Container(
      height: hasImage ? 120 : 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasImage ? Colors.green : primaryColor.withOpacity(0.2),
          width: hasImage ? 2.0 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: hasImage ? _showImagePreview : _showImageSourceDialog,
        child: hasImage
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _selectedImagePath != null
                        ? Image.file(
                            File(_selectedImagePath!),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : _existingImagePath != null
                            ? Image.network(
                                'https://new-invoice.acttconnect.com/storage/$_existingImagePath',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImagePath = null;
                          _existingImagePath = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Tap to change image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: primaryColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add Image *',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Select Image Source',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: primaryColor),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: primaryColor),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImagePreview() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: _selectedImagePath != null
                    ? Image.file(
                        File(_selectedImagePath!),
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      )
                    : _existingImagePath != null
                        ? Image.network(
                            'https://new-invoice.acttconnect.com/storage/$_existingImagePath',
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 300,
                            height: 300,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 60,
                            ),
                          ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showImageSourceDialog();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Change'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('OK'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
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

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        final file = File(image.path);
        if (await file.exists()) {
          final fileSize = await file.length();
          final maxSize = 5 * 1024 * 1024; // 5MB limit
          
          if (fileSize > maxSize) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size too large. Please select an image under 5MB.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          setState(() {
            _selectedImagePath = image.path;
            _existingImagePath = null; // Clear existing image when new one is selected
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        final file = File(image.path);
        if (await file.exists()) {
          final fileSize = await file.length();
          final maxSize = 5 * 1024 * 1024; // 5MB limit
          
          if (fileSize > maxSize) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size too large. Please select an image under 5MB.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          setState(() {
            _selectedImagePath = image.path;
            _existingImagePath = null; // Clear existing image when new one is selected
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
        
        // Auto-select the current category if available
        if (widget.item.details.itemCategoryId != null) {
          final currentCategory = _categories.firstWhere(
            (cat) => cat['id'] == widget.item.details.itemCategoryId,
            orElse: () => <String, dynamic>{},
          );
          if (currentCategory.isNotEmpty) {
            final baseName = currentCategory['item_category_name'] as String;
            final categoryId = currentCategory['id'] as int;
            setState(() {
              _selectedCategory = '$baseName (ID: $categoryId)';
            });
          }
        }
      } else {
        setState(() {
          _categories = [];
        });
      }
    } catch (e) {
      setState(() {
        _categories = [];
      });
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  void _showAddCategoryBottomSheet() {
    final TextEditingController categoryController = TextEditingController();
    bool isCreating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final screenHeight = MediaQuery.of(context).size.height;
            final bottomSheetHeight = screenHeight * 0.4;
            
            return Container(
              height: bottomSheetHeight + keyboardHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: keyboardHeight > 0 ? keyboardHeight + 20 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Add New Category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        'Category Name *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: categoryController,
                        decoration: InputDecoration(
                          hintText: 'Enter category name (e.g., Electronics, Food)',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: primaryColor,
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        maxLength: 50,
                      ),
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isCreating ? null : () async {
                            final categoryName = categoryController.text.trim();
                            if (categoryName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a category name'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            setModalState(() {
                              isCreating = true;
                            });

                            try {
                              final result = await ApiService.createItemCategory(categoryName);
                              
                              if (result['status'] == true) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message'] ?? 'Category created successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  
                                  Navigator.of(context).pop();
                                  _loadCategories();
                                  
                                  if (result['data'] != null) {
                                    final newCategory = result['data'];
                                    final newCategoryName = newCategory['item_category_name'] as String;
                                    final newCategoryId = newCategory['id'] as int;
                                    setState(() {
                                      _selectedCategory = '$newCategoryName (ID: $newCategoryId)';
                                    });
                                  }
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message'] ?? 'Failed to create category'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setModalState(() {
                                  isCreating = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isCreating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Create Category',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompactSwitchTile(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFormField(
    String label, {
    bool required = false,
    TextEditingController? controller,
    String? hintText,
    Widget? suffix,
    bool isDropdown = false,
    String? value,
    void Function(String?)? onChanged,
    List<String>? items,
    TextInputType? keyboardType,
    int? maxLines,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: primaryColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  color: Colors.red[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (isDropdown)
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: (items != null && items.isNotEmpty && value != null && items.contains(value)) ? value : null,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                hint: Text(
                  value ?? 'Select',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                items: (items ?? []).map<DropdownMenuItem<String>>((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          )
        else
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
            validator: required
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  }
                : null,
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _updateItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Update Item',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  void _updateItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Extract category ID from selected category
        int? categoryId;
        if (_selectedCategory != 'Select Category' && _selectedCategory != 'Loading...') {
          final selectedCategory = _categories.firstWhere(
            (cat) {
              final baseName = cat['item_category_name'] as String;
              final categoryId = cat['id'] as int;
              final formattedName = '$baseName (ID: $categoryId)';
              return _selectedCategory == baseName || _selectedCategory == formattedName;
            },
            orElse: () => <String, dynamic>{},
          );
          categoryId = selectedCategory['id'] as int?;
        }

        final result = await ApiService.updateItem(
          itemId: widget.item.id,
          userId: widget.item.userId.toString(),
          itemName: _nameController.text.trim(),
          unit: _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : null,
          salesPriceAmount: _salesPriceController.text.trim().isNotEmpty ? _salesPriceController.text.trim() : null,
          openingStock: _openingStockController.text.trim().isNotEmpty ? int.tryParse(_openingStockController.text.trim()) : null,
          itemDescription: _itemDescriptionController.text.trim().isNotEmpty ? _itemDescriptionController.text.trim() : null,
          showOnlineStore: _showOnlineStore,
          itemCategoryId: categoryId,
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result[ApiConstants.messageKey] ?? 'Item updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          }
        } else {
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
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
