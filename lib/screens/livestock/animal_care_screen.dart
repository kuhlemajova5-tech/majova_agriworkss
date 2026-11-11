
import 'package:flutter/material.dart';

class AnimalCareScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AnimalCareScreen({
    super.key,
    this.title = 'Animal Care',
    this.subtitle =
    'Manage the health and wellbeing of your livestock.',
    this.icon = Icons.pets_outlined,
  });

  @override
  State<AnimalCareScreen> createState() =>
      _AnimalCareScreenState();
}

class _AnimalCareScreenState extends State<AnimalCareScreen> {
  static const Color farmGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);

  final List<Map<String, String>> _records = [];

  final TextEditingController _animalController =
  TextEditingController();
  final TextEditingController _detailsController =
  TextEditingController();
  final TextEditingController _notesController =
  TextEditingController();

  String _selectedCategory = 'Health Records';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Health Records',
    'Vaccinations',
    'Breeding Records',
    'Feeding Records',
    'Weight Records',
  ];

  @override
  void dispose() {
    _animalController.dispose();
    _detailsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: farmGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddRecordDialog() {
    _animalController.clear();
    _detailsController.clear();
    _notesController.clear();
    _selectedDate = DateTime.now();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Add Animal Care Record',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Record Category',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _animalController,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Animal name or ID',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        hintText: 'e.g. Sheep 001',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _detailsController,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Record details',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        hintText:
                        'e.g. Vaccination, weight or feed',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _notesController,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Additional notes',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.calendar_month,
                        color: farmGreen,
                      ),
                      label: Text(
                        'Date: ${_formatDate(_selectedDate)}',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: farmGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_animalController.text.trim().isEmpty ||
                        _detailsController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter the animal ID and record details.',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _records.insert(0, {
                        'category': _selectedCategory,
                        'animal': _animalController.text.trim(),
                        'details': _detailsController.text.trim(),
                        'notes': _notesController.text.trim(),
                        'date': _formatDate(_selectedDate),
                      });
                    });

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Care record added successfully.'),
                      ),
                    );
                  },
                  child: const Text('Save Record'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Health Records':
        return Icons.medical_services_outlined;
      case 'Vaccinations':
        return Icons.vaccines_outlined;
      case 'Breeding Records':
        return Icons.pets_outlined;
      case 'Feeding Records':
        return Icons.grass_outlined;
      case 'Weight Records':
        return Icons.monitor_weight_outlined;
      default:
        return Icons.notes_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      appBar: AppBar(
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Animal Care',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: lightGreen,
                  child: Icon(
                    widget.icon,
                    color: farmGreen,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Total Records',
                  _records.length.toString(),
                  Icons.folder_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  'Categories',
                  _records
                      .map((record) => record['category'])
                      .toSet()
                      .length
                      .toString(),
                  Icons.category_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Care Management',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ..._categories.map((category) {
            final count = _records
                .where((record) => record['category'] == category)
                .length;

            return Card(
              color: Colors.white,
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: lightGreen,
                  child: Icon(
                    _categoryIcon(category),
                    color: farmGreen,
                  ),
                ),
                title: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '$count ${count == 1 ? 'record' : 'records'}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: farmGreen,
                  size: 17,
                ),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });

                  _showCategoryRecords(category);
                },
              ),
            );
          }),

          const SizedBox(height: 18),
          const Text(
            'Recent Care Records',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (_records.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    color: farmGreen,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No care records yet',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Add your first animal care record to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            )
          else
            ..._records.map((record) {
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: lightGreen,
                    child: Icon(
                      _categoryIcon(record['category']!),
                      color: farmGreen,
                    ),
                  ),
                  title: Text(
                    record['animal']!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${record['category']}\n'
                        '${record['details']}\n'
                        'Date: ${record['date']}',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text(
                            record['animal']!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Text(
                              'Category: ${record['category']}\n\n'
                                  'Details: ${record['details']}\n\n'
                                  'Date: ${record['date']}\n\n'
                                  'Notes: ${record['notes']!.isEmpty ? 'No additional notes' : record['notes']}',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext),
                              child: const Text(
                                'Close',
                                style: TextStyle(color: farmGreen),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            }),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRecordDialog,
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Care Record'),
      ),
    );
  }

  Widget _summaryCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: farmGreen, size: 25),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryRecords(String category) {
    final matchingRecords = _records
        .where((record) => record['category'] == category)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: matchingRecords.isEmpty
                      ? const Center(
                    child: Text(
                      'No records in this category yet.',
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                      : ListView.builder(
                    itemCount: matchingRecords.length,
                    itemBuilder: (context, index) {
                      final record = matchingRecords[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.pets,
                          color: farmGreen,
                        ),
                        title: Text(
                          record['animal']!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${record['details']}\n'
                              'Date: ${record['date']}',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
