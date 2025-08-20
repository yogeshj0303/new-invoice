import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/item.dart';

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
  final _hsnController = TextEditingController();

  String _selectedGst = 'None';
  bool _withTax = false;
  String _selectedTab = 'Pricing';
  bool _lowStockAlert = false;

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _salesPriceController.dispose();
    _purchasePriceController.dispose();
    _hsnController.dispose();
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
            // physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  _buildItemNameField(),
                  const SizedBox(height: 16),
                  _buildTabBar(),
                  const SizedBox(height: 12),
                  _buildTabContent(),
                  // const SizedBox(height: 80), // Space for bottom button
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
                    'GST',
                    isDropdown: true,
                    value: _selectedGst,
                    onChanged: (value) => setState(() => _selectedGst = value!),
                    items: ['None', '5%', '12%', '18%', '28%'],
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCompactFormField(
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
                  child: const Center(
                    child: Text(
                      'PCS',
                      style: TextStyle(
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
              hintText: '02 Aug 2025',
              suffix: IconButton(
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  color: primaryColor,
                  size: 18,
                ),
                onPressed: () {
                  // TODO: Show date picker
                },
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
          ],
        );
      case 'Other':
        return Column(
          children: [
            _buildCompactImageUpload(),
            const SizedBox(height: 12),
            _buildCompactFormField(
              'Item Category',
              isDropdown: true,
              value: 'Select Category',
              items: ['Select Category', 'Food', 'Beverages', 'Snacks'],
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 12),
            _buildCompactCustomFieldsButton(),
            const SizedBox(height: 12),
            _buildCompactFormField(
              'Item Description',
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
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            'Add Image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCustomFieldsButton() {
    return Container(
      height: 40,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: Handle add fields
        },
        label: const Text(
          'Custom Fields',
          style: TextStyle(
            color: primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
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

  Widget _buildCompactEmptyState(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
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
                value: value,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                items: items?.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
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
          onPressed: _saveItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
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

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save item logic
      Navigator.of(context).pop();
    }
  }
}
