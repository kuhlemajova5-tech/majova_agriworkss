import 'package:flutter/material.dart';

import '../../models/marketplace_item.dart';
import 'add_marketplace_item_screen.dart';
import 'edit_marketplace_item_screen.dart';
import 'marketplace_item_details_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Available',
    'Vegetables',
    'Livestock',
    'Sold Out',
  ];

  final List<MarketplaceItem> _items = [
    MarketplaceItem(
      productName: 'Fresh Cabbage',
      category: 'Vegetables',
      quantity: 120,
      unit: 'Head',
      pricePerUnit: 15,
      sellerName: 'JOVAS Farm',
      location: 'East London',
      contactNumber: '071 234 5678',
      listedDate: DateTime.now().subtract(
        const Duration(days: 1),
      ),
      availableUntil: DateTime.now().add(
        const Duration(days: 14),
      ),
      qualityGrade: 'Grade A',
      description:
      'Fresh farm-grown cabbage available for local buyers, households, vendors and community markets.',
      available: true,
    ),
    MarketplaceItem(
      productName: 'Fresh Spinach',
      category: 'Vegetables',
      quantity: 80,
      unit: 'Bunch',
      pricePerUnit: 12,
      sellerName: 'JOVAS Farm',
      location: 'East London',
      contactNumber: '071 234 5678',
      listedDate: DateTime.now().subtract(
        const Duration(days: 2),
      ),
      availableUntil: DateTime.now().add(
        const Duration(days: 10),
      ),
      qualityGrade: 'Grade A',
      description:
      'Freshly harvested spinach suitable for households, local shops and informal traders.',
      available: true,
    ),
    MarketplaceItem(
      productName: 'Farm Onions',
      category: 'Vegetables',
      quantity: 150,
      unit: 'Kilogram',
      pricePerUnit: 18,
      sellerName: 'JOVAS Farm',
      location: 'East London',
      contactNumber: '071 234 5678',
      listedDate: DateTime.now().subtract(
        const Duration(days: 3),
      ),
      availableUntil: DateTime.now().add(
        const Duration(days: 21),
      ),
      qualityGrade: 'Grade A',
      description:
      'Good quality onions available in bulk or smaller quantities depending on buyer requirements.',
      available: true,
    ),
    MarketplaceItem(
      productName: 'Sheep',
      category: 'Livestock',
      quantity: 4,
      unit: 'Animal',
      pricePerUnit: 3200,
      sellerName: 'JOVAS Farm',
      location: 'East London',
      contactNumber: '071 234 5678',
      listedDate: DateTime.now().subtract(
        const Duration(days: 4),
      ),
      availableUntil: DateTime.now().add(
        const Duration(days: 30),
      ),
      qualityGrade: 'Standard',
      description:
      'Healthy sheep available for sale. Buyers should contact the farm to arrange viewing and collection.',
      available: true,
    ),
    MarketplaceItem(
      productName: 'Cabbage Seedlings',
      category: 'Seedlings',
      quantity: 200,
      unit: 'Unit',
      pricePerUnit: 2.50,
      sellerName: 'JOVAS Farm',
      location: 'East London',
      contactNumber: '071 234 5678',
      listedDate: DateTime.now().subtract(
        const Duration(days: 7),
      ),
      availableUntil: null,
      qualityGrade: 'Premium',
      description:
      'Strong cabbage seedlings prepared for transplanting.',
      available: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MarketplaceItem> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();

    final results = _items.where((item) {
      final matchesSearch =
          query.isEmpty ||
              item.productName.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query) ||
              item.sellerName.toLowerCase().contains(query) ||
              item.location.toLowerCase().contains(query);

      bool matchesFilter;

      switch (_selectedFilter) {
        case 'Available':
          matchesFilter = item.available && !item.isExpired;
          break;

        case 'Vegetables':
          matchesFilter = item.category == 'Vegetables';
          break;

        case 'Livestock':
          matchesFilter = item.category == 'Livestock';
          break;

        case 'Sold Out':
          matchesFilter = !item.available;
          break;

        default:
          matchesFilter = true;
      }

      return matchesSearch && matchesFilter;
    }).toList();

    results.sort(
          (a, b) => b.listedDate.compareTo(a.listedDate),
    );

    return results;
  }

  int get _availableCount {
    return _items.where((item) {
      return item.available && !item.isExpired;
    }).length;
  }

  int get _soldOutCount {
    return _items.where((item) => !item.available).length;
  }

  double get _marketValue {
    return _items
        .where((item) => item.available && !item.isExpired)
        .fold(
      0.0,
          (total, item) => total + item.totalValue,
    );
  }

  Future<void> _openAddListing() async {
    final newItem = await Navigator.push<MarketplaceItem>(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const AddMarketplaceItemScreen(),
      ),
    );

    if (!mounted || newItem == null) {
      return;
    }

    setState(() {
      _items.add(newItem);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${newItem.productName} published successfully.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openDetails(MarketplaceItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MarketplaceItemDetailsScreen(
              item: item,
            ),
      ),
    );
  }

  Future<void> _openEdit(MarketplaceItem item) async {
    final index = _items.indexOf(item);

    if (index == -1) {
      return;
    }

    final updatedItem =
    await Navigator.push<MarketplaceItem>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditMarketplaceItemScreen(
              item: item,
            ),
      ),
    );

    if (!mounted || updatedItem == null) {
      return;
    }

    setState(() {
      _items[index] = updatedItem;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${updatedItem.productName} updated successfully.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleAvailability(MarketplaceItem item) {
    final index = _items.indexOf(item);

    if (index == -1) {
      return;
    }

    final updatedItem = MarketplaceItem(
      productName: item.productName,
      category: item.category,
      quantity: item.quantity,
      unit: item.unit,
      pricePerUnit: item.pricePerUnit,
      sellerName: item.sellerName,
      location: item.location,
      contactNumber: item.contactNumber,
      listedDate: item.listedDate,
      availableUntil: item.availableUntil,
      qualityGrade: item.qualityGrade,
      description: item.description,
      available: !item.available,
    );

    setState(() {
      _items[index] = updatedItem;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedItem.available
              ? '${updatedItem.productName} is available again.'
              : '${updatedItem.productName} marked as sold out.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteItem(
      MarketplaceItem item,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Listing?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to delete '
                '"${item.productName}" from the marketplace?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                const Color(0xFFC62828),
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldDelete != true) {
      return;
    }

    setState(() {
      _items.remove(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.productName} deleted.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature will be connected later.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        surfaceTintColor: Colors.transparent,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Marketplace',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              'Buy and sell farm products',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
                color: Color(0xFF66736A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showComingSoon(
                'Marketplace notifications',
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMarketplaceHeader(),

              const SizedBox(height: 22),

              _buildStatistics(),

              const SizedBox(height: 26),

              _buildSearchField(),

              const SizedBox(height: 16),

              _buildFilters(),

              const SizedBox(height: 26),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Marketplace Listings',
                      style: TextStyle(
                        color: Color(0xFF17201A),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${filteredItems.length} found',
                    style: const TextStyle(
                      color: Color(0xFF66736A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (filteredItems.isEmpty)
                _buildEmptyState()
              else
                ...filteredItems.map(
                      (item) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 14,
                    ),
                    child: _buildListingCard(item),
                  ),
                ),

              const SizedBox(height: 18),

              _buildMarketplaceTools(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddListing,
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add_business_rounded,
        ),
        label: const Text(
          'Sell Product',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildMarketplaceHeader() {
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
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(width: 15),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JOVAS Community Market',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Connecting farmers, produce and local buyers.',
                      style: TextStyle(
                        color: Color(0xFFC8E6C9),
                        fontSize: 12,
                        height: 1.4,
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
                child: ElevatedButton.icon(
                  onPressed: _openAddListing,
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                  label: const Text(
                    'Sell Product',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor:
                    const Color(0xFF1B5E20),
                    minimumSize: const Size(
                      double.infinity,
                      48,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showComingSoon(
                      'Buyer requests',
                    );
                  },
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                  ),
                  label: const Text(
                    'Buy Produce',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(
                      double.infinity,
                      48,
                    ),
                    side: const BorderSide(
                      color: Colors.white54,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.storefront_outlined,
            value: '${_items.length}',
            label: 'Listings',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_outline,
            value: '$_availableCount',
            label: 'Available',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildStatCard(
            icon: Icons.sell_outlined,
            value: '$_soldOutCount',
            label: 'Sold Out',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4EAE5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF1B5E20),
            size: 22,
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF17201A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF66736A),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText:
        'Search products, categories or locations...',
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
          onPressed: () {
            _searchController.clear();

            setState(() {});
          },
          icon: const Icon(
            Icons.close_rounded,
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final filter = _filters[index];

          return ChoiceChip(
            label: Text(filter),
            selected: _selectedFilter == filter,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            selectedColor: const Color(0xFFE8F5E9),
            labelStyle: TextStyle(
              color: _selectedFilter == filter
                  ? const Color(0xFF1B5E20)
                  : const Color(0xFF5F6D63),
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color: _selectedFilter == filter
                  ? const Color(0xFF81C784)
                  : const Color(0xFFE0E6E1),
            ),
            backgroundColor: Colors.white,
          );
        },
      ),
    );
  }

  Widget _buildListingCard(
      MarketplaceItem item,
      ) {
    final canBuy = item.available && !item.isExpired;

    return InkWell(
      onTap: () {
        _openDetails(item);
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE4EAE5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    _categoryIcon(item.category),
                    color: const Color(0xFF1B5E20),
                    size: 30,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          color: Color(0xFF17201A),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '${item.category} • ${item.qualityGrade}',
                        style: const TextStyle(
                          color: Color(0xFF66736A),
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF66736A),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              item.location,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                color:
                                Color(0xFF66736A),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'details':
                        _openDetails(item);
                        break;

                      case 'edit':
                        _openEdit(item);
                        break;

                      case 'status':
                        _toggleAvailability(item);
                        break;

                      case 'delete':
                        _deleteItem(item);
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                            ),
                            SizedBox(width: 10),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                            ),
                            SizedBox(width: 10),
                            Text('Edit Listing'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'status',
                        child: Row(
                          children: [
                            Icon(
                              item.available
                                  ? Icons
                                  .remove_shopping_cart_outlined
                                  : Icons
                                  .check_circle_outline,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              item.available
                                  ? 'Mark Sold Out'
                                  : 'Mark Available',
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Color(0xFFC62828),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color:
                                Color(0xFFC62828),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(
              height: 1,
              color: Color(0xFFE8ECE9),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRICE',
                        style: TextStyle(
                          color: Color(0xFF8A958D),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.priceText,
                        style: const TextStyle(
                          color: Color(0xFF1B5E20),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QUANTITY',
                        style: TextStyle(
                          color: Color(0xFF8A958D),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.quantityText,
                        style: const TextStyle(
                          color: Color(0xFF17201A),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: canBuy
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    canBuy ? 'Available' : 'Sold Out',
                    style: TextStyle(
                      color: canBuy
                          ? const Color(0xFF1B5E20)
                          : const Color(0xFFC62828),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 15,
                  color: Color(0xFF66736A),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    item.sellerName,
                    style: const TextStyle(
                      color: Color(0xFF66736A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8A958D),
                ),
              ],
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
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE4EAE5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Color(0xFF1B5E20),
              size: 34,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'No Products Found',
            style: TextStyle(
              color: Color(0xFF17201A),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Try another search or filter, or add a new farm product to the marketplace.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF66736A),
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          OutlinedButton.icon(
            onPressed: () {
              _searchController.clear();

              setState(() {
                _selectedFilter = 'All';
              });
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'Clear Filters',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marketplace Overview',
          style: TextStyle(
            color: Color(0xFF17201A),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFF1B5E20),
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Market Value',
                      style: TextStyle(
                        color: Color(0xFF4D6653),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'R${_marketValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF1B5E20),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 3),

                    const Text(
                      'Estimated value based on currently available listings.',
                      style: TextStyle(
                        color: Color(0xFF66736A),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _buildToolCard(
                icon: Icons.receipt_long_outlined,
                title: 'My Listings',
                onTap: () {
                  setState(() {
                    _selectedFilter = 'All';
                  });
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _buildToolCard(
                icon: Icons.insights_outlined,
                title: 'Market Insights',
                onTap: () {
                  _showComingSoon(
                    'Market insights',
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE4EAE5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1B5E20),
                size: 21,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF17201A),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
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