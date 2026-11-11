import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';

class AddInventoryScreen extends StatefulWidget {
  const AddInventoryScreen({super.key});

  @override
  State<AddInventoryScreen> createState() =>
      _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _itemNameController =
  TextEditingController();
  final TextEditingController _quantityController =
  TextEditingController();
  final TextEditingController _minimumStockController =
  TextEditingController();
  final TextEditingController _unitCostController =
  TextEditingController();
  final TextEditingController _supplierController =
  TextEditingController();
  final TextEditingController _storageLocationController =
  TextEditingController();
  final TextEditingController _notesController =
  TextEditingController();

  final List<String> _categories = [
    'Seeds & Seedlings',
    'Fertiliser',
    'Animal Feed',
    'Crop Protection',
    'Fuel & Lubricants',
    'Tractor Parts',
    'Tools & Equipment',
    'Veterinary Supplies',
    'Packaging',
    'Irrigation Supplies',
    'Other',
  ];

  final List<String> _units = [
    'Packets',
    'Bags',
    'Kilograms',
    'Litres',
    'Units',
    'Boxes',
    'Bottles',
    'Rolls',
    'Metres',
    'Tonnes',
  ];

  String _selectedCategory = 'Seeds & Seedlings';
  String _selectedUnit = 'Units';

  DateTime? _purchaseDate = DateTime.now();
  DateTime? _expiryDate;

  bool _hasExpiryDate = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    _minimumStockController.dispose();
    _unitCostController.dispose();
    _supplierController.dispose();
    _storageLocationController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _selectPurchaseDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _purchaseDate = selectedDate;
    });
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();

    final initialDate = _expiryDate ??
        DateTime(
          now.year + 1,
          now.month,
          now.day,
        );

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _expiryDate = selectedDate;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not selected';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  void _saveInventoryItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hasExpiryDate && _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select an expiry date.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final quantity = double.tryParse(
      _quantityController.text.trim(),
    ) ??
        0;

    final minimumStock = double.tryParse(
      _minimumStockController.text.trim(),
    ) ??
        0;

    final unitCost = double.tryParse(
      _unitCostController.text.trim(),
    ) ??
        0;

    final newItem = InventoryItem(
      itemName: _itemNameController.text.trim(),
      category: _selectedCategory,
      unit: _selectedUnit,
      quantity: quantity,
      minimumStockLevel: minimumStock,
      unitCost: unitCost,
      supplier: _supplierController.text.trim(),
      storageLocation: _storageLocationController.text.trim(),
      purchaseDate: _purchaseDate,
      expiryDate: _hasExpiryDate ? _expiryDate : null,
      notes: _notesController.text.trim(),
    );

    Navigator.pop(
      context,
      newItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Inventory Item',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17201A),
              ),
            ),
            Text(
              'Record a new farm supply or product',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF66736A),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            15,
            20,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 28),

              _buildSectionTitle('Item Information'),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _itemNameController,
                label: 'Item Name',
                hint: 'Example: Cabbage Seeds',
                icon: Icons.inventory_2_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the item name.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              _buildDropdown(
                label: 'Category',
                icon: Icons.category_outlined,
                value: _selectedCategory,
                items: _categories,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              _buildDropdown(
                label: 'Unit of Measurement',
                icon: Icons.straighten_rounded,
                value: _selectedUnit,
                items: _units,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedUnit = value;
                  });
                },
              ),

              const SizedBox(height: 28),

              _buildSectionTitle('Stock Information'),

              const SizedBox(height: 14),

              _buildNumberField(
                controller: _quantityController,
                label: 'Quantity',
                hint: 'Example: 10',
                icon: Icons.numbers_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the quantity.';
                  }

                  final number = double.tryParse(value.trim());

                  if (number == null) {
                    return 'Please enter a valid number.';
                  }

                  if (number < 0) {
                    return 'Quantity cannot be negative.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              _buildNumberField(
                controller: _minimumStockController,
                label: 'Minimum Stock Level',
                hint: 'Example: 5',
                icon: Icons.warning_amber_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the minimum stock level.';
                  }

                  final number = double.tryParse(value.trim());

                  if (number == null) {
                    return 'Please enter a valid number.';
                  }

                  if (number < 0) {
                    return 'Minimum stock cannot be negative.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              _buildNumberField(
                controller: _unitCostController,
                label: 'Unit Cost (R)',
                hint: 'Example: 320.00',
                icon: Icons.payments_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the unit cost.';
                  }

                  final number = double.tryParse(value.trim());

                  if (number == null) {
                    return 'Please enter a valid amount.';
                  }

                  if (number < 0) {
                    return 'Cost cannot be negative.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              _buildSectionTitle('Supplier & Storage'),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _supplierController,
                label: 'Supplier',
                hint: 'Example: Farm Inputs Supplier',
                icon: Icons.storefront_outlined,
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _storageLocationController,
                label: 'Storage Location',
                hint: 'Example: Main Farm Store',
                icon: Icons.warehouse_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the storage location.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              _buildSectionTitle('Purchase Information'),

              const SizedBox(height: 14),

              _buildDateCard(
                icon: Icons.shopping_cart_outlined,
                label: 'Purchase Date',
                value: _formatDate(_purchaseDate),
                onTap: _selectPurchaseDate,
              ),

              const SizedBox(height: 16),

              _buildExpirySwitch(),

              if (_hasExpiryDate) ...[
                const SizedBox(height: 14),
                _buildDateCard(
                  icon: Icons.event_busy_outlined,
                  label: 'Expiry Date',
                  value: _formatDate(_expiryDate),
                  onTap: _selectExpiryDate,
                ),
              ],

              const SizedBox(height: 28),

              _buildSectionTitle('Additional Notes'),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _notesController,
                label: 'Notes',
                hint: 'Add useful information about this item...',
                icon: Icons.notes_rounded,
                maxLines: 5,
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _saveInventoryItem,
                icon: const Icon(
                  Icons.save_rounded,
                ),
                label: const Text(
                  'Save Inventory Item',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1B5E20),
                    side: const BorderSide(
                      color: Color(0xFF1B5E20),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B3D1B),
            Color(0xFF1B5E20),
            Color(0xFF43A047),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.add_box_outlined,
            color: Colors.white,
            size: 38,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Farm Stock',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Record supplies, stock levels and costs.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF17201A),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: maxLines == 1 ? Icon(icon) : null,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE3E9E4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF66736A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17201A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit_calendar_outlined,
              color: Color(0xFF66736A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpirySwitch() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_busy_outlined,
              color: Color(0xFFEF6C00),
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Has Expiry Date',
                  style: TextStyle(
                    color: Color(0xFF17201A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Enable this for products that expire.',
                  style: TextStyle(
                    color: Color(0xFF66736A),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _hasExpiryDate,
            activeThumbColor: const Color(0xFF1B5E20),
            onChanged: (value) {
              setState(() {
                _hasExpiryDate = value;

                if (!value) {
                  _expiryDate = null;
                }
              });
            },
          ),
        ],
      ),
    );
  }
}