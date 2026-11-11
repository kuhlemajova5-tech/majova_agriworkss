import 'package:flutter/material.dart';

import '../../models/marketplace_item.dart';

class MarketplaceItemDetailsScreen extends StatelessWidget {
  final MarketplaceItem item;

  const MarketplaceItemDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: const Color(0xFFF4F7F4),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductHeader(),

              const SizedBox(height: 26),

              _buildSectionTitle(
                'Product Information',
                Icons.shopping_basket_outlined,
              ),

              const SizedBox(height: 12),

              _buildDetailsCard(
                children: [
                  _buildDetailRow(
                    Icons.category_outlined,
                    'Category',
                    item.category,
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    Icons.workspace_premium_outlined,
                    'Quality / Grade',
                    item.qualityGrade,
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    Icons.inventory_2_outlined,
                    'Quantity Available',
                    item.quantityText,
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    Icons.sell_outlined,
                    'Price',
                    item.priceText,
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    Icons.calculate_outlined,
                    'Estimated Total Value',
                    item.totalValueText,
                  ),
                ],
              ),

              const SizedBox(height: 26),

              _buildSectionTitle(
                'Seller Information',
                Icons.storefront_outlined,
              ),

              const SizedBox(height: 12),

              _buildDetailsCard(
                children: [
                  _buildDetailRow(
                    Icons.agriculture_outlined,
                    'Seller / Farm',
                    item.sellerName,
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'Location',
                    item.location,
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    Icons.phone_outlined,
                    'Contact Number',
                    item.contactNumber,
                  ),
                ],
              ),

              const SizedBox(height: 26),

              _buildSectionTitle(
                'Listing Information',
                Icons.event_note_outlined,
              ),

              const SizedBox(height: 12),

              _buildDetailsCard(
                children: [
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'Listed Date',
                    item.listedDateText,
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    Icons.event_available_outlined,
                    'Available Until',
                    item.availableUntilText,
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    Icons.check_circle_outline,
                    'Status',
                    item.availabilityStatus,
                  ),
                ],
              ),

              if (item.isExpired) ...[
                const SizedBox(height: 18),
                _buildAlertCard(
                  icon: Icons.event_busy_outlined,
                  title: 'Listing Date Expired',
                  message:
                  'The availability date for this product has passed.',
                  backgroundColor: const Color(0xFFFFEBEE),
                  iconColor: const Color(0xFFC62828),
                ),
              ],

              if (!item.available) ...[
                const SizedBox(height: 18),
                _buildAlertCard(
                  icon: Icons.remove_shopping_cart_outlined,
                  title: 'Product Sold Out',
                  message:
                  'This product is currently marked as unavailable.',
                  backgroundColor: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFEF6C00),
                ),
              ],

              if (item.description.trim().isNotEmpty) ...[
                const SizedBox(height: 26),

                _buildSectionTitle(
                  'Description',
                  Icons.description_outlined,
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE4EAE5),
                    ),
                  ),
                  child: Text(
                    item.description,
                    style: const TextStyle(
                      color: Color(0xFF4F5D53),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 26),

              _buildBuyerNotice(),

              const SizedBox(height: 26),

              ElevatedButton.icon(
                onPressed: item.available && !item.isExpired
                    ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Seller contact: ${item.contactNumber}',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                    : null,
                icon: const Icon(
                  Icons.phone_rounded,
                ),
                label: const Text(
                  'Contact Seller',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  const Color(0xFFCFD8D1),
                  disabledForegroundColor:
                  const Color(0xFF7B8A7F),
                  minimumSize: const Size(
                    double.infinity,
                    58,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                ),
                label: const Text(
                  'Back to Marketplace',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B5E20),
                  minimumSize: const Size(
                    double.infinity,
                    56,
                  ),
                  side: const BorderSide(
                    color: Color(0xFF1B5E20),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    final bool canBuy = item.available && !item.isExpired;

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
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Icon(
                  _categoryIcon(item.category),
                  color: Colors.white,
                  size: 34,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      item.category,
                      style: const TextStyle(
                        color: Color(0xFFC8E6C9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: canBuy
                      ? Colors.white
                      : const Color(0xFFFFECB3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  canBuy ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    color: canBuy
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFE65100),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Selling Price',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            item.priceText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${item.quantityText} available',
            style: const TextStyle(
              color: Color(0xFFC8E6C9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF1B5E20),
          size: 21,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF17201A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE4EAE5),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: Color(0xFF7A867D),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF17201A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Divider(
        height: 1,
        color: Color(0xFFE8ECE9),
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required String title,
    required String message,
    required Color backgroundColor,
    required Color iconColor,
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
            color: iconColor,
            size: 25,
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF5C655E),
                    fontSize: 12,
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

  Widget _buildBuyerNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(19),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF1B5E20),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'Contact the seller directly to confirm product availability, quantity, payment and collection or delivery arrangements.',
              style: TextStyle(
                color: Color(0xFF35523C),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Vegetables':
        return Icons.eco_rounded;

      case 'Fruit':
        return Icons.apple_rounded;

      case 'Grains':
        return Icons.grass_rounded;

      case 'Livestock':
        return Icons.pets_rounded;

      case 'Animal Products':
        return Icons.egg_alt_outlined;

      case 'Seedlings':
        return Icons.spa_rounded;

      case 'Farm Supplies':
        return Icons.inventory_2_outlined;

      default:
        return Icons.storefront_rounded;
    }
  }
}