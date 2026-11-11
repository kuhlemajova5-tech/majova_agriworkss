import 'package:flutter/material.dart';

import '../../models/livestock.dart';

class AddLivestockScreen extends StatefulWidget {
  const AddLivestockScreen({super.key});

  @override
  State<AddLivestockScreen> createState() =>
      _AddLivestockScreenState();
}

class _AddLivestockScreenState
    extends State<AddLivestockScreen> {
  final _formKey = GlobalKey<FormState>();

  final identificationController = TextEditingController();
  final breedController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final weightController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();

  String recordType = 'Individual';
  String? selectedAnimalType;
  String? selectedGender;
  String healthStatus = 'Healthy';

  DateTime? selectedDateOfBirth;

  final List<String> animalTypes = [
    'Cattle',
    'Sheep',
    'Goats',
    'Pigs',
    'Poultry',
    'Rabbits',
    'Horses',
    'Donkeys',
    'Other',
  ];

  final List<String> genders = [
    'Male',
    'Female',
    'Mixed',
    'Unknown',
  ];

  final List<String> healthStatuses = [
    'Healthy',
    'Under Treatment',
    'Sick',
    'Recovering',
    'Needs Attention',
  ];

  @override
  void dispose() {
    identificationController.dispose();
    breedController.dispose();
    quantityController.dispose();
    weightController.dispose();
    locationController.dispose();
    notesController.dispose();

    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _selectDateOfBirth() async {
    final today = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? today,
      firstDate: DateTime(1990),
      lastDate: today,
    );

    if (selectedDate != null) {
      setState(() {
        selectedDateOfBirth = selectedDate;
      });
    }
  }

  void _changeRecordType(String type) {
    setState(() {
      recordType = type;

      if (recordType == 'Individual') {
        quantityController.text = '1';

        if (selectedGender == 'Mixed') {
          selectedGender = null;
        }
      } else {
        if (quantityController.text.trim() == '1') {
          quantityController.clear();
        }
      }
    });
  }

  void _saveLivestock() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity =
        int.tryParse(quantityController.text.trim()) ?? 1;

    final weight =
        double.tryParse(weightController.text.trim()) ?? 0;

    final newLivestock = Livestock(
      animalType: selectedAnimalType!,
      recordType: recordType,
      identification: identificationController.text.trim(),
      breed: breedController.text.trim(),
      gender: selectedGender ?? 'Unknown',
      quantity: recordType == 'Individual' ? 1 : quantity,
      weightKg: weight,
      dateOfBirth: selectedDateOfBirth,
      healthStatus: healthStatus,
      location: locationController.text.trim(),
      notes: notesController.text.trim(),
    );

    Navigator.pop(context, newLivestock);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: const Text(
          'Add Livestock',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF17201A),
          ),
        ),
      ),

      body: Form(
        key: _formKey,
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
              _buildHeader(),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'Record Type',
                'Choose how you want to register your livestock.',
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildRecordTypeCard(
                      title: 'Individual',
                      subtitle: 'One animal',
                      icon: Icons.pets_rounded,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildRecordTypeCard(
                      title: 'Group',
                      subtitle: 'Herd, flock or batch',
                      icon: Icons.groups_2_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              _buildSectionTitle(
                'Animal Information',
                'Enter the basic livestock information.',
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: selectedAnimalType,
                decoration: const InputDecoration(
                  labelText: 'Animal Type',
                  prefixIcon: Icon(
                    Icons.pets_outlined,
                  ),
                ),
                items: animalTypes.map((animal) {
                  return DropdownMenuItem(
                    value: animal,
                    child: Text(animal),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAnimalType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an animal type';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: identificationController,
                decoration: InputDecoration(
                  labelText: recordType == 'Individual'
                      ? 'Tag / Identification Number'
                      : 'Group / Herd / Flock Name',
                  hintText: recordType == 'Individual'
                      ? 'Example: C001'
                      : 'Example: Broiler Batch 01',
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return recordType == 'Individual'
                        ? 'Please enter an identification number'
                        : 'Please enter a group name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: breedController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  hintText: 'Example: Bonsmara',
                  prefixIcon: Icon(
                    Icons.category_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter the breed';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(
                    Icons.wc_rounded,
                  ),
                ),
                items: genders
                    .where(
                      (gender) =>
                  recordType == 'Group' ||
                      gender != 'Mixed',
                )
                    .map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select gender';
                  }

                  return null;
                },
              ),

              if (recordType == 'Group') ...[
                const SizedBox(height: 16),

                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of Animals',
                    hintText: 'Example: 100',
                    prefixIcon: Icon(
                      Icons.numbers_rounded,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter the number of animals';
                    }

                    final quantity =
                    int.tryParse(value.trim());

                    if (quantity == null ||
                        quantity <= 0) {
                      return 'Enter a valid quantity';
                    }

                    return null;
                  },
                ),
              ],

              const SizedBox(height: 16),

              TextFormField(
                controller: weightController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: recordType == 'Individual'
                      ? 'Weight (kg)'
                      : 'Average Weight (kg)',
                  hintText: 'Optional',
                  prefixIcon: const Icon(
                    Icons.monitor_weight_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return null;
                  }

                  final weight =
                  double.tryParse(value.trim());

                  if (weight == null || weight < 0) {
                    return 'Enter a valid weight';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _selectDateOfBirth,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: recordType == 'Individual'
                        ? 'Date of Birth'
                        : 'Group Start / Birth Date',
                    prefixIcon: const Icon(
                      Icons.calendar_month_outlined,
                    ),
                    suffixIcon: selectedDateOfBirth != null
                        ? IconButton(
                      onPressed: () {
                        setState(() {
                          selectedDateOfBirth = null;
                        });
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    )
                        : const Icon(
                      Icons.arrow_drop_down_rounded,
                    ),
                  ),
                  child: Text(
                    selectedDateOfBirth == null
                        ? 'Select date (optional)'
                        : _formatDate(
                      selectedDateOfBirth!,
                    ),
                    style: TextStyle(
                      color: selectedDateOfBirth == null
                          ? const Color(0xFF66736A)
                          : const Color(0xFF17201A),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              _buildSectionTitle(
                'Health & Farm Details',
                'Record the current condition and location.',
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: healthStatus,
                decoration: const InputDecoration(
                  labelText: 'Health Status',
                  prefixIcon: Icon(
                    Icons.health_and_safety_outlined,
                  ),
                ),
                items: healthStatuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      healthStatus = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: locationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Farm Location',
                  hintText: 'Example: Camp A',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter the farm location';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: notesController,
                minLines: 3,
                maxLines: 5,
                textCapitalization:
                TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText:
                  'Add any additional livestock information...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(
                      bottom: 55,
                    ),
                    child: Icon(
                      Icons.notes_rounded,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _saveLivestock,
                  icon: const Icon(
                    Icons.save_outlined,
                  ),
                  label: Text(
                    recordType == 'Individual'
                        ? 'Save Animal'
                        : 'Save Livestock Group',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                    const Color(0xFF1B5E20),
                    side: const BorderSide(
                      color: Color(0xFF1B5E20),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
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
      padding: const EdgeInsets.all(20),
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
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register Livestock',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Keep accurate records of animals on your farm.',
                  style: TextStyle(
                    color: Colors.white70,
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
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF17201A),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF66736A),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = recordType == title;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        _changeRecordType(title);
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8F5E9)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1B5E20)
                : const Color(0xFFE3E9E4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected
                  ? const Color(0xFF1B5E20)
                  : const Color(0xFF66736A),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? const Color(0xFF1B5E20)
                    : const Color(0xFF17201A),
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF66736A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}