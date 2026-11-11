import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';
import 'add_inventory_screen.dart';
import 'edit_inventory_screen.dart';
import 'inventory_details_screen.dart';
import '../../services/inventory_database.dart';

const Color farmGreen = Color(0xFF1B5E20);
const Color darkGreen = Color(0xFF0B3D1B);
const Color mediumGreen = Color(0xFF43A047);
const Color lightGreen = Color(0xFFE8F5E9);
const Color pageBackground = Color(0xFFF4F7F4);
const Color textBlack = Color(0xFF17201A);

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<InventoryItem> inventoryItems = [
    InventoryItem(
      itemName: 'Cabbage Seeds',
      category: 'Seeds & Seedlings',
      unit: 'Packets',
      quantity: 4,
      minimumStockLevel: 5,
      unitCost: 85,
      supplier: 'Local Agricultural Supplier',
      storageLocation: 'Seed Store',
      purchaseDate: DateTime.now().subtract(const Duration(days: 20)),
      expiryDate: DateTime.now().add(const Duration(days: 300)),
      notes: 'Seeds for the next cabbage planting season.',
    ),
    InventoryItem(
      itemName: 'Spinach Seeds',
      category: 'Seeds & Seedlings',
      unit: 'Packets',
      quantity: 12,
      minimumStockLevel: 5,
      unitCost: 45,
      supplier: 'Local Agricultural Supplier',
      storageLocation: 'Seed Store',
      purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
      expiryDate: DateTime.now().add(const Duration(days: 250)),
      notes: 'Seeds for spinach production.',
    ),
    InventoryItem(
      itemName: 'NPK Fertiliser',
      category: 'Fertiliser',
      unit: 'Bags',
      quantity: 8,
      minimumStockLevel: 4,
      unitCost: 620,
      supplier: 'Farm Inputs Supplier',
      storageLocation: 'Fertiliser Store',
      purchaseDate: DateTime.now().subtract(const Duration(days: 15)),
      expiryDate: null,
      notes: 'Fertiliser for crop production.',
    ),
    InventoryItem(
      itemName: 'Sheep Feed',
      category: 'Animal Feed',
      unit: 'Bags',
      quantity: 10,
      minimumStockLevel: 6,
      unitCost: 320,
      supplier: 'Animal Feed Supplier',
      storageLocation: 'Feed Store',
      purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      notes: 'Feed for sheep and other livestock.',
    ),
    InventoryItem(
      itemName: 'Diesel',
      category: 'Fuel & Lubricants',
      unit: 'Litres',
      quantity: 75,
      minimumStockLevel: 50,
      unitCost: 24.50,
      supplier: 'Fuel Supplier',
      storageLocation: 'Fuel Storage',
      purchaseDate: DateTime.now().subtract(const Duration(days: 3)),
      expiryDate: null,
      notes: 'Fuel for farm machinery and tractors.',
    ),
  ];

  String selectedFilter = 'All';
  String searchQuery = '';

  final List<String> categories = [
    'Seeds & Seedlings',
    'Fertiliser',
    'Pesticides',
    'Herbicides',
    'Animal Feed',
    'Veterinary Supplies',
    'Fuel & Lubricants',
    'Tools & Equipment',
    'Other',
  ];

  bool _isLoadingInventory = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    try {
      final savedItems = await InventoryDatabase.instance.loadOrSeed(inventoryItems);
      if (!mounted) return;
      setState(() {
        inventoryItems = savedItems;
        _isLoadingInventory = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingInventory = false);
      _showMessage('Could not load saved inventory: $error');
    }
  }

  Future<void> _saveInventory() async {
    try {
      await InventoryDatabase.instance.saveAll(inventoryItems);
    } catch (error) {
      if (mounted) _showMessage('Could not save inventory: $error');
    }
  }

  List<InventoryItem> get filteredItems {
    return inventoryItems.where((item) {
      final query = searchQuery.toLowerCase();
      final matchesSearch = item.itemName.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.supplier.toLowerCase().contains(query);

      final bool matchesFilter;
      switch (selectedFilter) {
        case 'In Stock':
          matchesFilter = !item.isLowStock && !item.isOutOfStock;
          break;
        case 'Low Stock':
          matchesFilter = item.isLowStock && !item.isOutOfStock;
          break;
        case 'Out of Stock':
          matchesFilter = item.isOutOfStock;
          break;
        default:
          matchesFilter = true;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  double get totalInventoryValue => inventoryItems.fold<double>(
    0,
        (total, item) => total + item.totalValue,
  );

  int get lowStockCount =>
      inventoryItems.where((item) => item.isLowStock && !item.isOutOfStock).length;

  int get outOfStockCount =>
      inventoryItems.where((item) => item.isOutOfStock).length;

  int get expiringCount =>
      inventoryItems.where((item) => item.isExpiringSoon).length;

  String formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatMoney(num amount) => 'R ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Inventory Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Stock alerts',
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: _openStockAlerts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        onPressed: () => _showItemForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: SafeArea(
        child: _isLoadingInventory
            ? const Center(child: CircularProgressIndicator(color: farmGreen))
            : ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 18),
            _buildOverview(),
            const SizedBox(height: 22),
            _buildManagementSection(),
            const SizedBox(height: 22),
            _buildInventorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, farmGreen, mediumGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.white, size: 34),
          SizedBox(height: 12),
          Text(
            'Farm Inventory',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Manage farm supplies, purchases, suppliers and stock levels.',
            style: TextStyle(color: Colors.white, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Overview',
          style: TextStyle(
            color: textBlack,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _statCard('Total Items', '${inventoryItems.length}',
                Icons.inventory_2_outlined, farmGreen),
            _statCard('Stock Value', formatMoney(totalInventoryValue),
                Icons.account_balance_wallet_outlined, const Color(0xFF1565C0)),
            _statCard('Low Stock', '$lowStockCount',
                Icons.warning_amber_rounded, Colors.orange.shade800),
            _statCard('Out of Stock', '$outOfStockCount',
                Icons.remove_shopping_cart_outlined, Colors.red.shade700),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textBlack,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Tools',
          style: TextStyle(
            color: textBlack,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _managementCard(
          icon: Icons.shopping_cart_outlined,
          title: 'Purchase Records',
          subtitle: 'View recorded inventory purchases',
          onTap: _openPurchaseRecords,
        ),
        _managementCard(
          icon: Icons.local_shipping_outlined,
          title: 'Suppliers',
          subtitle: 'View suppliers linked to inventory items',
          onTap: _openSuppliers,
        ),
        _managementCard(
          icon: Icons.notifications_active_outlined,
          title: 'Stock Alerts',
          subtitle: 'Check low stock and expiring supplies',
          onTap: _openStockAlerts,
        ),
      ],
    );
  }

  Widget _managementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: farmGreen),
        ),
        title: Text(
          title,
          style: const TextStyle(color: textBlack, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: farmGreen),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInventorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Inventory',
          style: TextStyle(
            color: textBlack,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          style: const TextStyle(color: textBlack),
          decoration: InputDecoration(
            hintText: 'Search inventory...',
            hintStyle: const TextStyle(color: Colors.black45),
            prefixIcon: const Icon(Icons.search, color: farmGreen),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.black12),
            ),
          ),
          onChanged: (value) => setState(() => searchQuery = value),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'In Stock', 'Low Stock', 'Out of Stock'].map((filter) {
              final selected = selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  selectedColor: lightGreen,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? farmGreen : textBlack,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => setState(() => selectedFilter = filter),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (filteredItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 42, color: Colors.black38),
                  SizedBox(height: 10),
                  Text('No inventory items found.', style: TextStyle(color: textBlack)),
                ],
              ),
            ),
          )
        else
          ...filteredItems.map(_inventoryCard),
      ],
    );
  }

  Widget _inventoryCard(InventoryItem item) {
    final statusColor = item.isOutOfStock
        ? Colors.red
        : item.isLowStock
        ? Colors.orange.shade800
        : farmGreen;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showItemDetails(item),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_categoryIcon(item.category), color: farmGreen, size: 25),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: const TextStyle(
                            color: textBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(item.category,
                            style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: textBlack),
                    onSelected: (value) {
                      switch (value) {
                        case 'details':
                          _showItemDetails(item);
                          break;
                        case 'edit':
                          _showItemForm(item: item);
                          break;
                        case 'quantity':
                          _updateQuantity(item);
                          break;
                        case 'delete':
                          _deleteItem(item);
                          break;
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'details', child: Text('View details')),
                      PopupMenuItem(value: 'edit', child: Text('Edit item')),
                      PopupMenuItem(value: 'quantity', child: Text('Update quantity')),
                      PopupMenuItem(value: 'delete', child: Text('Delete item')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _smallInfo('Quantity', '${item.quantityText} ${item.unit}')),
                  Expanded(child: _smallInfo('Unit Cost', formatMoney(item.unitCost))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _smallInfo('Total Value', formatMoney(item.totalValue))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.stockStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.isExpiringSoon) ...[
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.deepOrange),
                    SizedBox(width: 5),
                    Text(
                      'This item may be expiring soon.',
                      style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.storageLocation,
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _updateQuantity(item),
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Update stock'),
                    style: TextButton.styleFrom(foregroundColor: farmGreen),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: textBlack, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Seeds & Seedlings':
        return Icons.grass;
      case 'Fertiliser':
        return Icons.eco_outlined;
      case 'Animal Feed':
        return Icons.pets_outlined;
      case 'Fuel & Lubricants':
        return Icons.local_gas_station_outlined;
      case 'Tools & Equipment':
        return Icons.build_outlined;
      case 'Veterinary Supplies':
        return Icons.medical_services_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  // ADD AND EDIT INVENTORY

  Future<void> _showItemForm({InventoryItem? item}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item?.itemName ?? '');
    final quantityController = TextEditingController(text: item?.quantity.toString() ?? '');
    final minimumController = TextEditingController(text: item?.minimumStockLevel.toString() ?? '');
    final costController = TextEditingController(text: item?.unitCost.toString() ?? '');
    final unitController = TextEditingController(text: item?.unit ?? '');
    final supplierController = TextEditingController(text: item?.supplier ?? '');
    final storageController = TextEditingController(text: item?.storageLocation ?? '');
    final notesController = TextEditingController(text: item?.notes ?? '');

    String category = categories.contains(item?.category) ? item!.category : categories.first;
    DateTime purchaseDate = item?.purchaseDate ?? DateTime.now();
    DateTime? expiryDate = item?.expiryDate;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            item == null ? 'Add Inventory Item' : 'Edit Inventory Item',
            style: const TextStyle(color: textBlack, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _formField(nameController, 'Item name'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: textBlack),
                      decoration: _inputDecoration('Category'),
                      items: categories
                          .map((value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setDialogState(() => category = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _formField(unitController, 'Unit (e.g. Bags, Litres)'),
                    const SizedBox(height: 12),
                    _formField(quantityController, 'Current quantity', numeric: true),
                    const SizedBox(height: 12),
                    _formField(minimumController, 'Minimum stock level', numeric: true),
                    const SizedBox(height: 12),
                    _formField(costController, 'Cost per unit (R)', numeric: true),
                    const SizedBox(height: 12),
                    _formField(supplierController, 'Supplier'),
                    const SizedBox(height: 12),
                    _formField(storageController, 'Storage location'),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month, color: farmGreen),
                      title: const Text('Purchase date', style: TextStyle(color: textBlack)),
                      subtitle: Text(formatDate(purchaseDate),
                          style: const TextStyle(color: Colors.black54)),
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: dialogContext,
                          initialDate: purchaseDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selected != null) setDialogState(() => purchaseDate = selected);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_available_outlined, color: farmGreen),
                      title: const Text('Expiry date (optional)', style: TextStyle(color: textBlack)),
                      subtitle: Text(formatDate(expiryDate),
                          style: const TextStyle(color: Colors.black54)),
                      trailing: expiryDate == null
                          ? null
                          : IconButton(
                        tooltip: 'Clear expiry date',
                        icon: const Icon(Icons.clear),
                        onPressed: () => setDialogState(() => expiryDate = null),
                      ),
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: dialogContext,
                          initialDate: expiryDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selected != null) setDialogState(() => expiryDate = selected);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: notesController,
                      maxLines: 3,
                      style: const TextStyle(color: textBlack),
                      decoration: _inputDecoration('Notes (optional)'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: farmGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final newItem = InventoryItem(
                  itemName: nameController.text.trim(),
                  category: category,
                  unit: unitController.text.trim(),
                  quantity: double.parse(quantityController.text.trim()),
                  minimumStockLevel: double.parse(minimumController.text.trim()),
                  unitCost: double.parse(costController.text.trim()),
                  supplier: supplierController.text.trim(),
                  storageLocation: storageController.text.trim(),
                  purchaseDate: purchaseDate,
                  expiryDate: expiryDate,
                  notes: notesController.text.trim(),
                );

                setState(() {
                  if (item == null) {
                    inventoryItems.add(newItem);
                  } else {
                    final index = inventoryItems.indexOf(item);
                    if (index != -1) inventoryItems[index] = newItem;
                  }
                });
                _saveInventory();

                Navigator.pop(dialogContext);
                _showMessage(item == null
                    ? 'Inventory item added successfully.'
                    : 'Inventory item updated successfully.');
              },
              child: Text(item == null ? 'Add Item' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    quantityController.dispose();
    minimumController.dispose();
    costController.dispose();
    unitController.dispose();
    supplierController.dispose();
    storageController.dispose();
    notesController.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: pageBackground,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: farmGreen, width: 1.5),
      ),
    );
  }

  Widget _formField(
      TextEditingController controller,
      String label, {
        bool numeric = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: textBlack),
      decoration: _inputDecoration(label),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Please enter $label.';
        if (numeric) {
          final number = double.tryParse(value.trim());
          if (number == null || number < 0) return 'Enter a valid number of 0 or more.';
        }
        return null;
      },
    );
  }

  // ITEM DETAILS

  void _showItemDetails(InventoryItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          item.itemName,
          style: const TextStyle(color: textBlack, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Category', item.category),
              _detailRow('Quantity', '${item.quantityText} ${item.unit}'),
              _detailRow('Minimum stock', '${item.minimumStockLevel} ${item.unit}'),
              _detailRow('Unit cost', formatMoney(item.unitCost)),
              _detailRow('Total value', formatMoney(item.totalValue)),
              _detailRow('Supplier', item.supplier),
              _detailRow('Storage', item.storageLocation),
              _detailRow('Purchase date', formatDate(item.purchaseDate)),
              _detailRow('Expiry date', formatDate(item.expiryDate)),
              _detailRow('Stock status', item.stockStatus),
              _detailRow('Notes', item.notes.isEmpty ? 'No notes added.' : item.notes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close', style: TextStyle(color: farmGreen)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: farmGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _showItemForm(item: item);
            },
            child: const Text('Edit Item'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(color: textBlack, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // UPDATE STOCK QUANTITY

  Future<void> _updateQuantity(InventoryItem item) async {
    final controller = TextEditingController(text: item.quantity.toString());
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Update ${item.itemName}', style: const TextStyle(color: textBlack)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: textBlack),
            decoration: _inputDecoration('New quantity (${item.unit})'),
            validator: (value) {
              final number = double.tryParse(value ?? '');
              if (number == null || number < 0) return 'Enter a valid quantity.';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: farmGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final newQuantity = double.parse(controller.text.trim());

              setState(() {
                final index = inventoryItems.indexOf(item);
                if (index != -1) {
                  inventoryItems[index] = InventoryItem(
                    itemName: item.itemName,
                    category: item.category,
                    unit: item.unit,
                    quantity: newQuantity,
                    minimumStockLevel: item.minimumStockLevel,
                    unitCost: item.unitCost,
                    supplier: item.supplier,
                    storageLocation: item.storageLocation,
                    purchaseDate: item.purchaseDate,
                    expiryDate: item.expiryDate,
                    notes: item.notes,
                  );
                }
              });
              _saveInventory();

              Navigator.pop(dialogContext);
              _showMessage('Stock quantity updated.');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();
  }

  // DELETE INVENTORY ITEM

  Future<void> _deleteItem(InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete inventory item?', style: TextStyle(color: textBlack)),
        content: Text(
          'Are you sure you want to delete "${item.itemName}"?',
          style: const TextStyle(color: textBlack),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => inventoryItems.remove(item));
      await _saveInventory();
      _showMessage('Inventory item deleted.');
    }
  }

  // NAVIGATION TO INVENTORY TOOLS

  void _openPurchaseRecords() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PurchaseRecordsPage(items: List<InventoryItem>.from(inventoryItems)),
      ),
    );
  }

  void _openSuppliers() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SuppliersPage(items: List<InventoryItem>.from(inventoryItems)),
      ),
    );
  }

  void _openStockAlerts() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => StockAlertsPage(items: List<InventoryItem>.from(inventoryItems)),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: farmGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ============================================================
// PURCHASE RECORDS
// ============================================================

class PurchaseRecordsPage extends StatelessWidget {
  final List<InventoryItem> items;

  const PurchaseRecordsPage({super.key, required this.items});

  String _date(DateTime? date) {
    if (date == null) return 'No date';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final records = List<InventoryItem>.from(items)
      ..sort((a, b) {
        final dateA = a.purchaseDate ?? DateTime(2000);
        final dateB = b.purchaseDate ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

    final total = records.fold<double>(0, (sum, item) => sum + item.totalValue);

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        title: const Text('Purchase Records'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _pageSummary(
            icon: Icons.receipt_long_outlined,
            title: 'Purchase Overview',
            subtitle: '${records.length} inventory purchase records',
            amount: 'R ${total.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 16),
          const Text(
            'Recorded Purchases',
            style: TextStyle(color: textBlack, fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (records.isEmpty)
            _emptyPage('No purchase records available.')
          else
            ...records.map(
                  (item) => Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: lightGreen,
                    child: Icon(Icons.shopping_bag_outlined, color: farmGreen),
                  ),
                  title: Text(
                    item.itemName,
                    style: const TextStyle(color: textBlack, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Supplier: ${item.supplier}\n'
                        'Purchase date: ${_date(item.purchaseDate)}\n'
                        'Quantity: ${item.quantityText} ${item.unit}',
                    style: const TextStyle(color: Colors.black54, height: 1.5),
                  ),
                  isThreeLine: true,
                  trailing: SizedBox(
                    width: 95,
                    child: Text(
                      'R ${item.totalValue.toStringAsFixed(2)}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(color: farmGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Note: These records use the purchase dates and quantities currently saved on each inventory item. They are not a separate transaction history.',
            style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUPPLIERS
// ============================================================

class SuppliersPage extends StatelessWidget {
  final List<InventoryItem> items;

  const SuppliersPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<InventoryItem>> supplierItems = {};

    for (final item in items) {
      final supplier = item.supplier.trim().isEmpty
          ? 'Supplier not specified'
          : item.supplier.trim();
      supplierItems.putIfAbsent(supplier, () => []);
      supplierItems[supplier]!.add(item);
    }

    final suppliers = supplierItems.keys.toList()..sort();

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        title: const Text('Suppliers'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _pageSummary(
            icon: Icons.local_shipping_outlined,
            title: 'Farm Suppliers',
            subtitle: 'Suppliers linked to your inventory',
            amount: '${suppliers.length} suppliers',
          ),
          const SizedBox(height: 16),
          const Text(
            'Supplier Directory',
            style: TextStyle(color: textBlack, fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (suppliers.isEmpty)
            _emptyPage('No suppliers have been recorded.')
          else
            ...suppliers.map((supplier) {
              final supplierInventory = supplierItems[supplier]!;
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    backgroundColor: lightGreen,
                    child: Icon(Icons.storefront_outlined, color: farmGreen),
                  ),
                  title: Text(
                    supplier,
                    style: const TextStyle(color: textBlack, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${supplierInventory.length} inventory item(s)',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  iconColor: farmGreen,
                  collapsedIconColor: farmGreen,
                  children: supplierInventory.map((item) {
                    return ListTile(
                      leading: const Icon(Icons.inventory_2_outlined, color: farmGreen),
                      title: Text(item.itemName, style: const TextStyle(color: textBlack)),
                      subtitle: Text(
                        'Quantity: ${item.quantityText} ${item.unit}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Text(
                        'R ${item.totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(color: farmGreen, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          const SizedBox(height: 8),
          const Text(
            'Note: This directory groups suppliers from your inventory records. Contact details and independent supplier profiles have not been added yet.',
            style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STOCK ALERTS
// ============================================================

class StockAlertsPage extends StatelessWidget {
  final List<InventoryItem> items;

  const StockAlertsPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final outOfStock = items.where((item) => item.isOutOfStock).toList();
    final lowStock = items.where((item) => item.isLowStock && !item.isOutOfStock).toList();
    final expiring = items.where((item) => item.isExpiringSoon).toList();

    final alerts = items
        .where((item) => item.isLowStock || item.isOutOfStock || item.isExpiringSoon)
        .toList();

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        title: const Text('Stock Alerts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _pageSummary(
            icon: Icons.notifications_active_outlined,
            title: 'Stock Monitoring',
            subtitle: 'Review inventory that needs attention',
            amount: '${alerts.length} alert(s)',
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.20,
            children: [
              _alertCountCard('Out of Stock', outOfStock.length, Colors.red),
              _alertCountCard('Low Stock', lowStock.length, Colors.orange.shade800),
              _alertCountCard('Expiring Soon', expiring.length, Colors.deepOrange),
              _alertCountCard('Needs Attention', alerts.length, farmGreen),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Items Requiring Attention',
            style: TextStyle(color: textBlack, fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (alerts.isEmpty)
            _emptyPage('Good news! No stock alerts at the moment.')
          else
            ...alerts.map((item) {
              final isOut = item.isOutOfStock;
              final isLow = item.isLowStock && !isOut;
              final color = isOut
                  ? Colors.red
                  : isLow
                  ? Colors.orange.shade800
                  : Colors.deepOrange;
              final message = isOut
                  ? 'Out of stock'
                  : isLow
                  ? 'Stock below minimum level'
                  : 'Expiring soon';

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(
                      isOut
                          ? Icons.remove_shopping_cart_outlined
                          : isLow
                          ? Icons.warning_amber_rounded
                          : Icons.event_busy_outlined,
                      color: color,
                    ),
                  ),
                  title: Text(
                    item.itemName,
                    style: const TextStyle(color: textBlack, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$message\n'
                        'Current stock: ${item.quantityText} ${item.unit}\n'
                        'Minimum stock: ${item.minimumStockLevel} ${item.unit}',
                    style: const TextStyle(color: Colors.black54, height: 1.5),
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.info_outline, color: farmGreen),
                ),
              );
            }),
          const SizedBox(height: 8),
          const Text(
            'These alerts appear inside the app. Phone notifications and background reminders are not enabled by this screen.',
            style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED PAGE WIDGETS
// ============================================================

Widget _pageSummary({
  required IconData icon,
  required String title,
  required String subtitle,
  required String amount,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [darkGreen, farmGreen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.white, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                amount,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

Widget _emptyPage(String message) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: [
        const Icon(Icons.check_circle_outline, color: farmGreen, size: 42),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: textBlack),
        ),
      ],
    ),
  );
}

Widget _alertCountCard(String title, int count, Color color) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.black12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_none, color: color, size: 25),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: const TextStyle(color: textBlack, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    ),
  );
}
