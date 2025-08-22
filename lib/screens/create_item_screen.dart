import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class CreateItemScreen extends StatefulWidget {
  const CreateItemScreen({super.key});

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  // Theme colors
  static const Color primaryColor = Color(0xFF2E3085);
  static const Color secondaryColor = Color(0xFF4E4AA8);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _salesPriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _mrpPriceController = TextEditingController();
  final _hsnController = TextEditingController();
  final _openingStockController = TextEditingController();
  final _lowAlertQuantityController = TextEditingController();
  final _itemDescriptionController = TextEditingController();

  String _selectedGst = 'None';
  bool _withTax = false;
  String _selectedTab = 'Pricing';
  bool _lowStockAlert = false;
  String _selectedCategory = 'Select Category';
  String _showOnlineStore = 'false';
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _selectedImagePath; // Added for image validation

  // Categories from API
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = false;
  
  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    // Ensure initial GST value is valid
    _selectedGst = 'None';
    // Set default unit value to PCS
    _unitController.text = 'PCS';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _salesPriceController.dispose();
    _purchasePriceController.dispose();
    _mrpPriceController.dispose();
    _hsnController.dispose();
    _openingStockController.dispose();
    _lowAlertQuantityController.dispose();
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
        'Create New Item',
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
                    enabled: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactFormField(
                    'Sales Price',
                    controller: _salesPriceController,
                    hintText: '₹ 130',
                    suffix: _buildTaxDropdown(),
                    keyboardType: TextInputType.number,
                    icon: Icons.attach_money,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCompactFormField(
                    'Purchase Price',
                    controller: _purchasePriceController,
                    hintText: '₹ 115',
                    suffix: _buildTaxDropdown(),
                    keyboardType: TextInputType.number,
                    icon: Icons.shopping_cart_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactFormField(
                    'MRP Price',
                    controller: _mrpPriceController,
                    hintText: '₹ 150',
                    keyboardType: TextInputType.number,
                    icon: Icons.attach_money,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCompactFormField(
                    'GST',
                    isDropdown: true,
                    value: _selectedGst,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedGst = value);
                      }
                    },
                    items: const [
                      'None',
                      'Tax Exempted',
                      'GST @ 0%',
                      'GST @ 0.1%',
                      'GST @ 0.25%',
                      'GST @ 1%',
                      'GST @ 3%',
                      'GST @ 5%',
                      'GST @ 6%',
                      'GST @ 12%',
                      'GST @ 13.8%',
                      'GST @ 14%',
                      'GST @ 14% + Cess @ 12%',
                      'GST @ 18%',
                      'GST @ 28%',
                      'GST @ 28% + Cess @ 5%',
                      'GST @ 28% + Cess @ 12%',
                      'GST @ 28% + Cess @ 36%',
                      'GST @ 28% + Cess @ 60%',
                    ],
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactFormField(
                    'HSN',
                    controller: _hsnController,
                    hintText: 'Ex: 6704',
                    suffix: IconButton(
                      icon: const Icon(Icons.search, color: primaryColor, size: 18),
                      onPressed: () {
                        // TODO: Search HSN
                      },
                    ),
                    icon: Icons.numbers,
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
                      'PCS',
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
            const SizedBox(height: 12),
            _buildCompactFormField(
              'As of Date',
              hintText: _selectedDate != null 
                  ? '${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}'
                  : '02 Aug 2025',
              suffix: IconButton(
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  color: primaryColor,
                  size: 18,
                ),
                onPressed: () => _selectDate(context),
              ),
              icon: Icons.calendar_month_outlined,
            ),
            const SizedBox(height: 12),
            _buildCompactSwitchTile(
              'Low stock alert',
              Icons.notifications_outlined,
              _lowStockAlert,
              (value) => setState(() => _lowStockAlert = value),
            ),
            if (_lowStockAlert) ...[
              const SizedBox(height: 12),
              _buildCompactFormField(
                'Low Alert Quantity',
                controller: _lowAlertQuantityController,
                hintText: 'Ex: 10',
                keyboardType: TextInputType.number,
                icon: Icons.warning_amber_outlined,
              ),
            ],
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
                                print('🔍 [DEBUG] Category: ${cat['item_category_name']} (ID: ${cat['id']})');
                                // Make each category name unique by adding ID if duplicates exist
                                final baseName = cat['item_category_name'] as String;
                                final categoryId = cat['id'] as int;
                                return '$baseName (ID: $categoryId)';
                              }), '➕ Add Category'],
                        icon: Icons.category_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                                         Container(
                       margin: const EdgeInsets.only(top: 24), // Align with dropdown
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

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildCompactImageUpload() {
    return Container(
      height: _selectedImagePath != null ? 120 : 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _selectedImagePath != null ? Colors.green : primaryColor.withOpacity(0.2),
          width: _selectedImagePath != null ? 2.0 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: _selectedImagePath != null ? _showImagePreview : _showImageSourceDialog,
        child: _selectedImagePath != null
            ? Stack(
                children: [
                  // Show the selected image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FutureBuilder<bool>(
                      future: File(_selectedImagePath!).exists(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == true) {
                          return Image.file(
                            File(_selectedImagePath!),
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
                          );
                        } else {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  // Overlay with clear button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImagePath = null;
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
                  // Add image overlay text
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
              // Image preview
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.file(
                  File(_selectedImagePath!),
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 300,
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                    );
                  },
                ),
              ),
              // Action buttons
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
        // Validate image file
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
          
          print('📸 [DEBUG] Image selected from camera: ${image.path}');
          setState(() {
            _selectedImagePath = image.path;
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
        // Validate image file
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
          
          print('📸 [DEBUG] Image selected from gallery: ${image.path}');
          setState(() {
            _selectedImagePath = image.path;
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
      print('🔍 [DEBUG] Categories API Response: $response');
      
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response['data']);
        });
        print('✅ [DEBUG] Loaded ${_categories.length} categories');
      } else {
        print('⚠️ [DEBUG] Categories API returned: ${response['message'] ?? 'Unknown error'}');
        setState(() {
          _categories = [];
        });
      }
    } catch (e) {
      print('❌ [DEBUG] Error loading categories: $e');
      // Fallback to empty list
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
                      // Header
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
                      
                      // Category Name Input
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
                      
                      // Create Button
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
                                // Show success message
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message'] ?? 'Category created successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  
                                  // Close bottom sheet
                                  Navigator.of(context).pop();
                                  
                                  // Refresh categories list
                                  _loadCategories();
                                  
                                  // Auto-select the newly created category
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
                                // Show error message
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
    bool enabled = true,
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
            enabled: enabled,
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

  Widget _buildTaxDropdown() {
    return PopupMenuButton<bool>(
      offset: const Offset(0, 30),
      initialValue: _withTax,
      onSelected: (bool value) {
        setState(() {
          _withTax = value;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
        const PopupMenuItem<bool>(value: true, child: Text('With Tax')),
        const PopupMenuItem<bool>(value: false, child: Text('Without Tax')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _withTax ? 'With Tax' : 'Without Tax',
              style: const TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down, color: primaryColor, size: 14),
          ],
        ),
      ),
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
          onPressed: _isLoading ? null : _saveItem,
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
                  'Save Item',
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

  void _saveItem() async {
    // Validate required fields
    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image for the item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate image file exists
    final imageFile = File(_selectedImagePath!);
    if (!await imageFile.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected image file not found. Please select again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategory == 'Select Category' || _selectedCategory == 'Loading...' || _selectedCategory == '➕ Add Category') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category for the item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Extract GST percentage from selected value
        String? gstValue;
        print('🔍 [DEBUG] Selected GST: $_selectedGst'); // Debug log
        
        if (_selectedGst != 'None' && _selectedGst != 'Tax Exempted') {
          // Handle different GST formats
          if (_selectedGst.startsWith('GST @ ')) {
            // Extract the main GST percentage
            final gstMatch = RegExp(r'GST @ ([\d.]+)%').firstMatch(_selectedGst);
            if (gstMatch != null) {
              gstValue = gstMatch.group(1);
              print('🔍 [DEBUG] Extracted GST value: $gstValue'); // Debug log
            }
          } else {
            // Handle legacy format (e.g., "5%")
            gstValue = _selectedGst.replaceAll('%', '');
            print('🔍 [DEBUG] Legacy GST format, extracted: $gstValue'); // Debug log
          }
        } else {
          print('🔍 [DEBUG] GST is None or Tax Exempted, setting to null'); // Debug log
        }
        
        print('🔍 [DEBUG] Final GST value to be sent: $gstValue'); // Debug log

        // Extract category ID from selected category
        int? categoryId;
        if (_selectedCategory != 'Select Category' && _selectedCategory != 'Loading...') {
          // Handle both formats: "name" and "name (ID: X)"
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

        print('🔍 [DEBUG] Creating item with image path: $_selectedImagePath');
        final result = await ApiService.createItem(
          userId: '1', // TODO: Get actual user ID from auth service
          itemName: _nameController.text.trim(),
          unit: 'PCS',
          salesPriceAmount: _salesPriceController.text.trim().isNotEmpty ? _salesPriceController.text.trim() : null,
          salesPriceTax: _withTax ? 1 : 0,
          purchasePriceAmount: _purchasePriceController.text.trim().isNotEmpty ? _purchasePriceController.text.trim() : null,
          purchasePriceTax: _withTax ? 1 : 0,
          mrpPrice: _mrpPriceController.text.trim().isNotEmpty ? _mrpPriceController.text.trim() : null,
          gst: gstValue,
          openingStock: _openingStockController.text.trim().isNotEmpty ? int.tryParse(_openingStockController.text.trim()) : null,
          asOfDate: _selectedDate?.toIso8601String().split('T')[0],
          lowAlertStatus: _lowStockAlert ? 'true' : 'false',
          lowAlertQuantity: _lowAlertQuantityController.text.trim().isNotEmpty ? int.tryParse(_lowAlertQuantityController.text.trim()) : null,
          itemCategoryId: categoryId,
          itemDescription: _itemDescriptionController.text.trim().isNotEmpty ? _itemDescriptionController.text.trim() : null,
          showOnlineStore: _showOnlineStore,
          imagePaths: _selectedImagePath != null ? [_selectedImagePath!] : null,
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result[ApiConstants.messageKey] ?? 'Item created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          }
        } else {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result[ApiConstants.messageKey] ?? 'Failed to create item'),
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
