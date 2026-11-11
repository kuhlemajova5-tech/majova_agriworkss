import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<InventoryItem> inventoryItems = [
    InventoryItem(
      itemName: 'Cabbage Seeds',
      category: 'Seeds & Seedlings',
      unit: 'Packets',
      quantity: 4,
      minimumStockLevel: 5,
      unitCost: 85,
      supplier: 'Local Agricultural Supplier',
      storageLocation: 'Seed Store',
      purchaseDate: DateTime.now().subtract(
        const Duration(days: 20),
      ),
      expiryDate: DateTime.now().add(
        const Duration(days: 300),
      ),
      notes: 'Hybrid cabbage seeds for the next planting cycle.',
    ),
    InventoryItem(
      itemName: 'Spinach Seeds',
      category: 'Seeds & Seedlings',
      unit: 'Packets',
      quantity: 12,
      minimumStockLevel: 5,
      unitCost: 55,
      supplier: 'Local Agricultural Supplier',
      storageLocation: 'Seed Store',
      purchaseDate: DateTime.now().subtract(
        const Duration(days: 15),
      ),
      expiryDate: DateTime.now().add(
        const Duration(days: 250),
      ),
      notes: 'Spinach seed stock for upcoming planting.',
    ),
    InventoryItem(
      itemName: 'NPK Fertiliser',
      category: 'Fertiliser',
      unit: 'Bags',
      quantity: 8,
      minimumStockLevel: 4,
      unitCost: 620,
      supplier: 'Farm Inputs Supplier',
      storageLocation: 'Chemical Store',
      purchaseDate: DateTime.now().subtract(
        const Duration(days: 10),
      ),
      expiryDate: null,
      notes: 'Used for crop nutrition and soil fertility management.',
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
      purchaseDate: DateTime.now().subtract(
        const Duration(days: 5),
      ),
      expiryDate: DateTime.now().add(
        const Duration(days: 90),
      ),
      notes: 'Supplementary feed for the sheep flock.',
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
      purchaseDate: DateTime.now().subtract(
        const Duration(days: 3),
      ),
      expiryDate: null,
      notes: 'Fuel stock for tractors and farm machinery.',
    ),
  ];

  String selectedFilter = 'All';

  final List<String> filters = [
    'All',
    'In Stock',
    'Low Stock',
    'Out of Stock',
  ];

  int get totalItems {
    return inventoryItems.length;
  }

  int get lowStockItems {
    return inventoryItems.where((item) {
      return item.isLowStock && !item.isOutOfStock;
    }).length;
  }

  int get outOfStockItems {
    return inventoryItems.where((item) {
      return item.isOutOfStock;
    }).length;
  }

  int get expiringSoonItems {
    return inventoryItems.where((item) {
      return item.isExpiringSoon;
    }).length;
  }

  double get totalInventoryValue {
    return inventoryItems.fold(
      0,
          (total, item) => total + item.totalValue,
    );
  }

  List<InventoryItem> get filteredItems {
    switch (selectedFilter) {
      case 'In Stock':
        return inventoryItems.where((item) {
          return !item.isLowStock && !item.isOutOfStock;
        }).toList();

      case 'Low Stock':
        return inventoryItems.where((item) {
          return item.isLowStock && !item.isOutOfStock;
        }).toList();

      case 'Out of Stock':
        return inventoryItems.where((item) {
          return item.isOutOfStock;
        }).toList();

      default:
        return inventoryItems;
    }
  }

  String _formatMoney(double amount) {
    return 'R${amount.toStringAsFixed(2)}';
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature will be connected next.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<InventoryItem> visibleItems = filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Inventory',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17201A),
              ),
            ),
            Text(
              'Manage farm supplies and stock',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF66736A),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          15,
          20,
          110,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInventoryValueCard(),

            const SizedBox(height: 26),

            const Text(
              'Inventory Overview',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17201A),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.inventory_2_outlined,
                    value: totalItems.toString(),
                    label: 'Items',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.warning_amber_rounded,
                    value: lowStockItems.toString(),
                    label: 'Low Stock',
                    warning: lowStockItems > 0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.remove_shopping_cart_outlined,
                    value: outOfStockItems.toString(),
                    label: 'Out of Stock',
                    danger: outOfStockItems > 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.event_busy_outlined,
                    value: expiringSoonItems.toString(),
                    label: 'Expiring Soon',
                    warning: expiringSoonItems > 0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stock Items',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF17201A),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _showComingSoon('Add inventory item');
                  },
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                  label: const Text(
                    'Add Item',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildFilters(),

            const SizedBox(height: 18),

            if (visibleItems.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleItems.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 14);
                },
                itemBuilder: (context, index) {
                  return _buildInventoryCard(
                    visibleItems[index],
                  );
                },
              ),

            const SizedBox(height: 30),

            const Text(
              'Inventory Management',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17201A),
              ),
            ),

            const SizedBox(height: 14),

            _buildManagementCard(
              icon: Icons.shopping_cart_outlined,
              title: 'Purchase Records',
              subtitle: 'Track farm input and supply purchases',
              onTap: () {
                _showComingSoon('Purchase records');
              },
            ),

            const SizedBox(height: 12),

            _buildManagementCard(
              icon: Icons.local_shipping_outlined,
              title: 'Suppliers',
              subtitle: 'Manage agricultural suppliers',
              onTap: () {
                _showComingSoon('Suppliers');
              },
            ),

            const SizedBox(height: 12),

            _buildManagementCard(
              icon: Icons.notifications_active_outlined,
              title: 'Stock Alerts',
              subtitle: 'Monitor low stock and expiring supplies',
              onTap: () {
                _showComingSoon('Stock alerts');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showComingSoon('Add inventory item');
        },
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add_box_outlined,
        ),
        label: const Text(
          'Add Item',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryValueCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Farm Stock Value',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            _formatMoney(totalInventoryValue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Estimated value of current farm inventory',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _OverviewItem(
                  value: totalItems.toString(),
                  label: 'Products',
                ),
              ),
              const _OverviewDivider(),
              Expanded(
                child: _OverviewItem(
                  value: lowStockItems.toString(),
                  label: 'Low Stock',
                ),
              ),
              const _OverviewDivider(),
              Expanded(
                child: _OverviewItem(
                  value: expiringSoonItems.toString(),
                  label: 'Expiring',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String value,
    required String label,
    bool warning = false,
    bool danger = false,
  }) {
    Color background = Colors.white;
    Color iconBackground = const Color(0xFFE8F5E9);
    Color foreground = const Color(0xFF1B5E20);
    Color border = const Color(0xFFE3E9E4);

    if (danger) {
      background = const Color(0xFFFFEBEE);
      iconBackground = const Color(0xFFFFCDD2);
      foreground = const Color(0xFFC62828);
      border = const Color(0xFFEF9A9A);
    } else if (warning) {
      background = const Color(0xFFFFF8E1);
      iconBackground = const Color(0xFFFFECB3);
      foreground = const Color(0xFFF57F17);
      border = const Color(0xFFFFCC80);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: foreground,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF66736A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final String filter = filters[index];
          final bool selected = selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            selectedColor: const Color(0xFFE8F5E9),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? const Color(0xFF43A047)
                  : const Color(0xFFE3E9E4),
            ),
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: selected
                  ? const Color(0xFF1B5E20)
                  : const Color(0xFF66736A),
            ),
            onSelected: (_) {
              setState(() {
                selectedFilter = filter;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    final Color statusColor = _stockStatusColor(item);
    final Color statusBackground = _stockStatusBackground(item);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        _showComingSoon('Inventory item details');
      },
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: item.isOutOfStock
                ? const Color(0xFFEF9A9A)
                : item.isLowStock
                ? const Color(0xFFFFCC80)
                : const Color(0xFFE3E9E4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _categoryBackground(
                      item.category,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _categoryIcon(
                      item.category,
                    ),
                    color: _categoryColor(
                      item.category,
                    ),
                    size: 28,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF17201A),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF66736A),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.stockStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'details') {
                      _showComingSoon(
                        'Inventory item details',
                      );
                    } else if (value == 'edit') {
                      _showComingSoon(
                        'Edit inventory item',
                      );
                    } else if (value == 'stock') {
                      _showComingSoon(
                        'Update stock quantity',
                      );
                    } else if (value == 'delete') {
                      _showComingSoon(
                        'Delete inventory item',
                      );
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined),
                          SizedBox(width: 10),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text('Edit Item'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'stock',
                      child: Row(
                        children: [
                          Icon(Icons.sync_alt_rounded),
                          SizedBox(width: 10),
                          Text('Update Stock'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),
            const Divider(height: 1),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildItemValue(
                    label: 'Quantity',
                    value: item.quantityText,
                  ),
                ),
                Expanded(
                  child: _buildItemValue(
                    label: 'Unit Cost',
                    value: item.unitCostText,
                  ),
                ),
                Expanded(
                  child: _buildItemValue(
                    label: 'Value',
                    value: item.totalValueText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF66736A),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.storageLocation,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF66736A),
                    ),
                  ),
                ),

                if (item.isExpiringSoon) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 17,
                    color: Color(0xFFF57F17),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Expiring soon',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF57F17),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemValue({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF66736A),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF17201A),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1B5E20),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17201A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF66736A),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF66736A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 58,
            color: Color(0xFF9AA69D),
          ),
          SizedBox(height: 15),
          Text(
            'No inventory items found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF17201A),
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Add farm supplies or choose another stock filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF66736A),
            ),
          ),
        ],
      ),
    );
  }

  Color _stockStatusColor(InventoryItem item) {
    if (item.isOutOfStock) {
      return const Color(0xFFC62828);
    }

    if (item.isLowStock) {
      return const Color(0xFFF57F17);
    }

    return const Color(0xFF1B5E20);
  }

  Color _stockStatusBackground(InventoryItem item) {
    if (item.isOutOfStock) {
      return const Color(0xFFFFEBEE);
    }

    if (item.isLowStock) {
      return const Color(0xFFFFF3E0);
    }

    return const Color(0xFFE8F5E9);
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Seeds & Seedlings':
        return Icons.grass_rounded;

      case 'Fertiliser':
        return Icons.eco_outlined;

      case 'Animal Feed':
        return Icons.pets_outlined;

      case 'Crop Protection':
        return Icons.shield_outlined;

      case 'Fuel & Lubricants':
        return Icons.local_gas_station_outlined;

      case 'Tractor Parts':
        return Icons.settings_outlined;

      case 'Tools & Equipment':
        return Icons.handyman_outlined;

      case 'Veterinary Supplies':
        return Icons.medical_services_outlined;

      case 'Packaging':
        return Icons.inventory_outlined;

      case 'Irrigation Supplies':
        return Icons.water_drop_outlined;

      default:
        return Icons.inventory_2_outlined;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Seeds & Seedlings':
      case 'Fertiliser':
        return const Color(0xFF2E7D32);

      case 'Animal Feed':
        return const Color(0xFF6D4C41);

      case 'Crop Protection':
      case 'Veterinary Supplies':
        return const Color(0xFF6A1B9A);

      case 'Fuel & Lubricants':
        return const Color(0xFFEF6C00);

      case 'Tractor Parts':
      case 'Tools & Equipment':
        return const Color(0xFF455A64);

      case 'Irrigation Supplies':
        return const Color(0xFF1565C0);

      default:
        return const Color(0xFF1B5E20);
    }
  }

  Color _categoryBackground(String category) {
    switch (category) {
      case 'Seeds & Seedlings':
      case 'Fertiliser':
        return const Color(0xFFE8F5E9);

      case 'Animal Feed':
        return const Color(0xFFEFEBE9);

      case 'Crop Protection':
      case 'Veterinary Supplies':
        return const Color(0xFFF3E5F5);

      case 'Fuel & Lubricants':
        return const Color(0xFFFFF3E0);

      case 'Tractor Parts':
      case 'Tools & Equipment':
        return const Color(0xFFECEFF1);

      case 'Irrigation Supplies':
        return const Color(0xFFE3F2FD);

      default:
        return const Color(0xFFF1F8E9);
    }
  }
}

class _OverviewItem extends StatelessWidget {
  final String value;
  final String label;

  const _OverviewItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _OverviewDivider extends StatelessWidget {
  const _OverviewDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: Colors.white24,
    );
  }
}