import 'package:flutter/material.dart';

import '../../models/inventory_item.dart';

class InventoryDetailsScreen extends StatelessWidget {
  final InventoryItem item;

  const InventoryDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: const Text(
          'Inventory Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF17201A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 26),

            _buildSectionTitle(
              'Stock Information',
            ),

            const SizedBox(height: 14),

            _buildInformationCard(
              children: [
                _buildInformationRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Item Name',
                  value: item.itemName,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  value: item.category,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.numbers_rounded,
                  label: 'Current Quantity',
                  value: item.quantityText,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.warning_amber_rounded,
                  label: 'Minimum Stock',
                  value: item.minimumStockText,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.monitor_heart_outlined,
                  label: 'Stock Status',
                  value: item.stockStatus,
                  valueColor: _statusColor(),
                ),
              ],
            ),

            const SizedBox(height: 26),

            _buildSectionTitle(
              'Financial Information',
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    icon: Icons.payments_outlined,
                    title: 'Unit Cost',
                    value: item.unitCostText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFinancialCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Stock Value',
                    value: item.totalValueText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            _buildSectionTitle(
              'Supplier & Storage',
            ),

            const SizedBox(height: 14),

            _buildInformationCard(
              children: [
                _buildInformationRow(
                  icon: Icons.storefront_outlined,
                  label: 'Supplier',
                  value: item.supplier.trim().isEmpty
                      ? 'Not recorded'
                      : item.supplier,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.warehouse_outlined,
                  label: 'Storage Location',
                  value: item.storageLocation,
                ),
              ],
            ),

            const SizedBox(height: 26),

            _buildSectionTitle(
              'Dates',
            ),

            const SizedBox(height: 14),

            _buildInformationCard(
              children: [
                _buildInformationRow(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Purchase Date',
                  value: item.purchaseDateText,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.event_busy_outlined,
                  label: 'Expiry Date',
                  value: item.expiryDateText,
                  valueColor: item.isExpired
                      ? const Color(0xFFC62828)
                      : item.isExpiringSoon
                      ? const Color(0xFFF57F17)
                      : null,
                ),
              ],
            ),

            if (item.isExpired) ...[
              const SizedBox(height: 16),
              _buildAlertCard(
                icon: Icons.error_outline_rounded,
                title: 'Product Expired',
                message:
                'This inventory item has passed its recorded expiry date.',
                backgroundColor: const Color(0xFFFFEBEE),
                foregroundColor: const Color(0xFFC62828),
              ),
            ] else if (item.isExpiringSoon) ...[
              const SizedBox(height: 16),
              _buildAlertCard(
                icon: Icons.warning_amber_rounded,
                title: 'Expiring Soon',
                message:
                'This inventory item is approaching its recorded expiry date.',
                backgroundColor: const Color(0xFFFFF8E1),
                foregroundColor: const Color(0xFFF57F17),
              ),
            ],

            if (item.isOutOfStock) ...[
              const SizedBox(height: 16),
              _buildAlertCard(
                icon: Icons.remove_shopping_cart_outlined,
                title: 'Out of Stock',
                message:
                'This item currently has no available stock.',
                backgroundColor: const Color(0xFFFFEBEE),
                foregroundColor: const Color(0xFFC62828),
              ),
            ] else if (item.isLowStock) ...[
              const SizedBox(height: 16),
              _buildAlertCard(
                icon: Icons.inventory_outlined,
                title: 'Low Stock Warning',
                message:
                'Current stock is at or below the minimum stock level.',
                backgroundColor: const Color(0xFFFFF8E1),
                foregroundColor: const Color(0xFFF57F17),
              ),
            ],

            const SizedBox(height: 26),

            _buildSectionTitle(
              'Notes',
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE3E9E4),
                ),
              ),
              child: Text(
                item.notes.trim().isEmpty
                    ? 'No additional notes recorded.'
                    : item.notes,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Color(0xFF66736A),
                ),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                ),
                label: const Text(
                  'Back to Inventory',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _categoryIcon(),
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      item.category,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBackgroundColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.stockStatus,
                        style: TextStyle(
                          color: _statusColor(),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _buildHeaderValue(
                  label: 'Quantity',
                  value: item.quantityText,
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildHeaderValue(
                  label: 'Stock Value',
                  value: item.totalValueText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderValue({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
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

  Widget _buildInformationCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInformationRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1B5E20),
              size: 21,
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
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: valueColor ??
                        const Color(0xFF17201A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF66736A),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF17201A),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required String title,
    required String message,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: foregroundColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: Color(0xFFE8ECE9),
    );
  }

  Color _statusColor() {
    if (item.isOutOfStock) {
      return const Color(0xFFC62828);
    }

    if (item.isLowStock) {
      return const Color(0xFFF57F17);
    }

    return const Color(0xFF1B5E20);
  }

  Color _statusBackgroundColor() {
    if (item.isOutOfStock) {
      return const Color(0xFFFFCDD2);
    }

    if (item.isLowStock) {
      return const Color(0xFFFFECB3);
    }

    return const Color(0xFFC8E6C9);
  }

  IconData _categoryIcon() {
    switch (item.category) {
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
}