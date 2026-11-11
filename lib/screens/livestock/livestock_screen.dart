
import 'package:flutter/material.dart';

import '../../models/livestock.dart';
import 'add_livestock_screen.dart';
import 'edit_livestock_screen.dart';
import 'livestock_details_screen.dart';
import 'animal_care_screen.dart';

class LivestockScreen extends StatefulWidget {
  const LivestockScreen({super.key});

  @override
  State<LivestockScreen> createState() => _LivestockScreenState();
}

class _LivestockScreenState extends State<LivestockScreen> {
  static const Color farmGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);

  final List<Livestock> _livestock = [];
  final TextEditingController _searchController =
  TextEditingController();

  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<String> _filters = [
    'All',
    'Sheep',
    'Goats',
    'Cattle',
    'Poultry',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Livestock> get _filteredLivestock {
    return _livestock.where((animal) {
      final query = _searchQuery.toLowerCase();

      final matchesSearch =
          animal.displayName.toLowerCase().contains(query) ||
              animal.identification.toLowerCase().contains(query) ||
              animal.breed.toLowerCase().contains(query) ||
              animal.animalType.toLowerCase().contains(query);

      final matchesFilter = _selectedFilter == 'All' ||
          animal.animalType.toLowerCase() ==
              _selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get _totalAnimals => _livestock.fold<int>(
    0,
        (total, animal) => total + animal.quantity,
  );

  int get _healthyAnimals => _livestock
      .where(
        (animal) =>
    animal.healthStatus.toLowerCase() == 'healthy',
  )
      .fold<int>(
    0,
        (total, animal) => total + animal.quantity,
  );

  int get _animalsNeedingAttention => _livestock
      .where(
        (animal) =>
    animal.healthStatus.toLowerCase() != 'healthy',
  )
      .fold<int>(
    0,
        (total, animal) => total + animal.quantity,
  );

  Future<void> _addLivestock() async {
    final result = await Navigator.push<Livestock>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddLivestockScreen(),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() => _livestock.add(result));
      _showMessage('Livestock added successfully.');
    }
  }

  Future<void> _editLivestock(Livestock animal) async {
    final result = await Navigator.push<Livestock>(
      context,
      MaterialPageRoute(
        builder: (_) => EditLivestockScreen(livestock: animal),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        final index = _livestock.indexOf(animal);
        if (index != -1) {
          _livestock[index] = result;
        }
      });

      _showMessage('Livestock updated successfully.');
    }
  }

  Future<void> _viewDetails(Livestock animal) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LivestockDetailsScreen(livestock: animal),
      ),
    );
  }

  void _openAnimalCare({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimalCareScreen(
          title: title,
          subtitle: subtitle,
          icon: icon,
        ),
      ),
    );
  }

  void _confirmDelete(Livestock animal) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Livestock',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${animal.displayName}?',
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() => _livestock.remove(animal));
              Navigator.pop(dialogContext);
              _showMessage('Livestock deleted.');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Statistics cards: flexible height and no fixed-height Column.
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            softWrap: true,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _animalIcon(String animalType) {
    switch (animalType.toLowerCase()) {
      case 'sheep':
      case 'goat':
      case 'goats':
        return Icons.pets;
      case 'cattle':
      case 'cow':
        return Icons.agriculture;
      case 'poultry':
      case 'chicken':
        return Icons.egg_alt_outlined;
      default:
        return Icons.pets_outlined;
    }
  }

  Widget _buildLivestockCard(Livestock animal) {
    final isHealthy =
        animal.healthStatus.toLowerCase() == 'healthy';

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _viewDetails(animal),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: lightGreen,
                    child: Icon(
                      _animalIcon(animal.animalType),
                      color: farmGreen,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.displayName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${animal.identification}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.black,
                    ),
                    onSelected: (value) {
                      if (value == 'view') {
                        _viewDetails(animal);
                      } else if (value == 'edit') {
                        _editLivestock(animal);
                      } else if (value == 'delete') {
                        _confirmDelete(animal);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'view',
                        child: Text(
                          'View Details',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          'Edit Livestock',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete Livestock',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildAnimalInfo(
                      'Breed',
                      animal.breed.isEmpty
                          ? 'Not specified'
                          : animal.breed,
                    ),
                  ),
                  Expanded(
                    child: _buildAnimalInfo(
                      'Gender',
                      animal.gender.isEmpty
                          ? 'Not specified'
                          : animal.gender,
                    ),
                  ),
                  Expanded(
                    child: _buildAnimalInfo(
                      'Quantity',
                      animal.quantity.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildAnimalInfo(
                      'Weight',
                      animal.weightText,
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isHealthy
                            ? lightGreen
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        animal.healthStatus.isEmpty
                            ? 'Unknown'
                            : animal.healthStatus,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isHealthy
                              ? farmGreen
                              : Colors.red.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _viewDetails(animal),
                  icon: const Icon(
                    Icons.visibility_outlined,
                    color: farmGreen,
                  ),
                  label: const Text(
                    'View Details',
                    style: TextStyle(
                      color: farmGreen,
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

  Widget _buildCareCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: lightGreen,
          child: Icon(icon, color: farmGreen),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.black),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: farmGreen,
          size: 17,
        ),
        onTap: () => _openAnimalCare(
          title: title,
          subtitle: subtitle,
          icon: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animals = _filteredLivestock;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      appBar: AppBar(
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Livestock Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Livestock',
            onPressed: _addLivestock,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Manage Your Livestock',
              style: TextStyle(
                color: Colors.black,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Track your animals, health, growth and daily care.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Flexible grid cards prevent bottom overflow.
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                _buildStatCard(
                  title: 'Total Animals',
                  value: _totalAnimals.toString(),
                  icon: Icons.pets,
                  iconColor: farmGreen,
                ),
                _buildStatCard(
                  title: 'Animal Groups',
                  value: _livestock.length.toString(),
                  icon: Icons.groups_outlined,
                  iconColor: Colors.blue,
                ),
                _buildStatCard(
                  title: 'Healthy Animals',
                  value: _healthyAnimals.toString(),
                  icon: Icons.health_and_safety_outlined,
                  iconColor: farmGreen,
                ),
                _buildStatCard(
                  title: 'Needs Attention',
                  value: _animalsNeedingAttention.toString(),
                  icon: Icons.warning_amber_outlined,
                  iconColor: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 26),
            const Text(
              'Search Livestock',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search by name, ID or breed...',
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(
                  Icons.search,
                  color: farmGreen,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Colors.black12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final selected = _selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      showCheckmark: false,
                      backgroundColor: Colors.white,
                      selectedColor: lightGreen,
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: selected
                            ? farmGreen
                            : Colors.black12,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your Livestock',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${animals.length} groups',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (animals.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.pets_outlined,
                      size: 55,
                      color: farmGreen,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'No livestock records found',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add sheep, goats, cattle or other animals '
                          'to start managing your livestock.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: _addLivestock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: farmGreen,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Livestock'),
                    ),
                  ],
                ),
              )
            else
              ...animals.map(_buildLivestockCard),

            const SizedBox(height: 26),
            const Text(
              'Animal Care',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Keep track of your animals’ wellbeing.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),

            _buildCareCard(
              title: 'Health Records',
              subtitle: 'Illnesses, treatments and check-ups',
              icon: Icons.medical_services_outlined,
            ),
            _buildCareCard(
              title: 'Vaccinations',
              subtitle: 'Vaccination history and due dates',
              icon: Icons.vaccines_outlined,
            ),
            _buildCareCard(
              title: 'Breeding Records',
              subtitle: 'Breeding and birth records',
              icon: Icons.pets_outlined,
            ),
            _buildCareCard(
              title: 'Feeding Records',
              subtitle: 'Feed types and feeding routines',
              icon: Icons.grass_outlined,
            ),
            _buildCareCard(
              title: 'Weight Records',
              subtitle: 'Growth and weight monitoring',
              icon: Icons.monitor_weight_outlined,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addLivestock,
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Livestock'),
      ),
    );
  }
}
