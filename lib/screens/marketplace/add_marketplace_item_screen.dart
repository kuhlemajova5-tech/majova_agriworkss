import 'package:flutter/material.dart';

import '../../models/marketplace_item.dart';

class AddMarketplaceItemScreen extends StatefulWidget {
  const AddMarketplaceItemScreen({super.key});

  @override
  State<AddMarketplaceItemScreen> createState() =>
      _AddMarketplaceItemScreenState();
}

class _AddMarketplaceItemScreenState
    extends State<AddMarketplaceItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _sellerNameController = TextEditingController(
    text: 'JOVAS Farm',
  );
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _categories = [
    'Vegetables',
    'Fruit',
    'Grains',
    'Livestock',
    'Animal Products',
    'Seedlings',
    'Farm Supplies',
    'Other',
  ];

  final List<String> _units = [
    'Head',
    'Bunch',
    'Kilogram',
    'Bag',
    'Crate',
    'Box',
    'Tray',
    'Dozen',
    'Litre',
    'Animal',
    'Unit',
    'Tonne',
  ];

  final List<String> _qualityGrades = [
    'Grade A',
    'Grade B',
    'Grade C',
    'Standard',
    'Premium',
    'Not Graded',
  ];

  String _selectedCategory = 'Vegetables';
  String _selectedUnit = 'Head';
  String _selectedQuality = 'Grade A';

  DateTime _listedDate = DateTime.now();
  DateTime? _availableUntil;

  bool _available = true;

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _sellerNameController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _selectAvailableUntilDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _availableUntil ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (selectedDate != null) {
      setState(() {
        _availableUntil = selectedDate;
      });
    }
  }

  void _removeAvailableUntilDate() {
    setState(() {
      _availableUntil = null;
    });
  }

  void _saveListing() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = double.tryParse(
      _quantityController.text.trim(),
    );

    final price = double.tryParse(
      _priceController.text.trim(),
    );

    if (quantity == null || price == null) {
      return;
    }

    final item = MarketplaceItem(
      productName: _productNameController.text.trim(),
      category: _selectedCategory,
      quantity: quantity,
      unit: _selectedUnit,
      pricePerUnit: price,
      sellerName: _sellerNameController.text.trim(),
      location: _locationController.text.trim(),
      contactNumber: _contactController.text.trim(),
      listedDate: _listedDate,
      availableUntil: _availableUntil,
      qualityGrade: _selectedQuality,
      description: _descriptionController.text.trim(),
      available: _available,
    );

    Navigator.pop(
      context,
      item,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'No expiry date';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text(
          'Add Product Listing',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: const Color(0xFFF4F7F4),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                _buildHeader(),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  'Product Information',
                  Icons.shopping_basket_outlined,
                ),

                const SizedBox(height: 12),

                _buildCard(
                  children: [
                    TextFormField(
                      controller: _productNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'e.g. Fresh Cabbage',
                        prefixIcon: Icon(
                          Icons.eco_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter the product name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(
                          Icons.category_outlined,
                        ),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedCategory = value;

                          if (value == 'Livestock') {
                            _selectedUnit = 'Animal';
                          } else if (value == 'Vegetables' &&
                              !_units.contains(_selectedUnit)) {
                            _selectedUnit = 'Head';
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedQuality,
                      decoration: const InputDecoration(
                        labelText: 'Quality / Grade',
                        prefixIcon: Icon(
                          Icons.workspace_premium_outlined,
                        ),
                      ),
                      items: _qualityGrades.map((quality) {
                        return DropdownMenuItem<String>(
                          value: quality,
                          child: Text(quality),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedQuality = value;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                _buildSectionTitle(
                  'Quantity & Price',
                  Icons.payments_outlined,
                ),

                const SizedBox(height: 12),

                _buildCard(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType:
                            const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              hintText: '120',
                              prefixIcon: Icon(
                                Icons.inventory_2_outlined,
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Required';
                              }

                              final quantity = double.tryParse(
                                value.trim(),
                              );

                              if (quantity == null ||
                                  quantity <= 0) {
                                return 'Invalid quantity';
                              }

                              return null;
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            items: _units.map((unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(
                                  unit,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                _selectedUnit = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _priceController,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Price per $_selectedUnit',
                        hintText: '15.00',
                        prefixText: 'R ',
                        prefixIcon: const Icon(
                          Icons.sell_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter a selling price';
                        }

                        final price = double.tryParse(
                          value.trim(),
                        );

                        if (price == null || price <= 0) {
                          return 'Enter a valid price';
                        }

                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                _buildSectionTitle(
                  'Seller Information',
                  Icons.storefront_outlined,
                ),

                const SizedBox(height: 12),

                _buildCard(
                  children: [
                    TextFormField(
                      controller: _sellerNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Farm / Seller Name',
                        prefixIcon: Icon(
                          Icons.agriculture_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter the seller name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _locationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Product Location',
                        hintText: 'e.g. East London',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter the product location';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        hintText: 'e.g. 071 234 5678',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter a contact number';
                        }

                        if (value.trim().length < 9) {
                          return 'Enter a valid contact number';
                        }

                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                _buildSectionTitle(
                  'Availability',
                  Icons.event_available_outlined,
                ),

                const SizedBox(height: 12),

                _buildCard(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Available for Sale',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        _available
                            ? 'Buyers can see that this product is available.'
                            : 'This product will be marked as sold out.',
                      ),
                      value: _available,
                      activeColor: const Color(0xFF1B5E20),
                      onChanged: (value) {
                        setState(() {
                          _available = value;
                        });
                      },
                    ),

                    const Divider(height: 28),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.calendar_month_outlined,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      title: const Text(
                        'Available Until',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        _formatDate(_availableUntil),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                      ),
                      onTap: _selectAvailableUntilDate,
                    ),

                    if (_availableUntil != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _removeAvailableUntilDate,
                          icon: const Icon(
                            Icons.close_rounded,
                          ),
                          label: const Text(
                            'Remove Date',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 26),

                _buildSectionTitle(
                  'Product Description',
                  Icons.description_outlined,
                ),

                const SizedBox(height: 12),

                _buildCard(
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        hintText:
                        'Describe the product, quality, collection arrangements or other information for buyers.',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: _saveListing,
                  icon: const Icon(
                    Icons.add_business_rounded,
                  ),
                  label: const Text(
                    'Publish Listing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
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

                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
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
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sell Farm Products',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Create a marketplace listing and connect your farm products with buyers.',
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
          size: 21,
          color: const Color(0xFF1B5E20),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF17201A),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}