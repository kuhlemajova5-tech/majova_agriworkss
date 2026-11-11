import 'package:flutter/material.dart';

import '../../models/livestock.dart';

class EditLivestockScreen extends StatefulWidget {
  final Livestock livestock;

  const EditLivestockScreen({
    super.key,
    required this.livestock,
  });

  @override
  State<EditLivestockScreen> createState() =>
      _EditLivestockScreenState();
}

class _EditLivestockScreenState
    extends State<EditLivestockScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController identificationController;
  late final TextEditingController breedController;
  late final TextEditingController quantityController;
  late final TextEditingController weightController;
  late final TextEditingController locationController;
  late final TextEditingController notesController;

  late String recordType;
  late String selectedAnimalType;
  late String selectedGender;
  late String healthStatus;

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
  void initState() {
    super.initState();

    recordType = widget.livestock.recordType;
    selectedAnimalType = widget.livestock.animalType;
    selectedGender = widget.livestock.gender;
    healthStatus = widget.livestock.healthStatus;

    selectedDateOfBirth = widget.livestock.dateOfBirth;

    identificationController = TextEditingController(
      text: widget.livestock.identification,
    );

    breedController = TextEditingController(
      text: widget.livestock.breed,
    );

    quantityController = TextEditingController(
      text: widget.livestock.quantity.toString(),
    );

    weightController = TextEditingController(
      text: widget.livestock.weightKg > 0
          ? widget.livestock.weightKg.toString()
          : '',
    );

    locationController = TextEditingController(
      text: widget.livestock.location,
    );

    notesController = TextEditingController(
      text: widget.livestock.notes,
    );
  }

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
          selectedGender = 'Unknown';
        }
      }
    });
  }

  void _updateLivestock() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity =
        int.tryParse(quantityController.text.trim()) ?? 1;

    final weight =
        double.tryParse(weightController.text.trim()) ?? 0;

    final updatedLivestock = Livestock(
      animalType: selectedAnimalType,
      recordType: recordType,
      identification: identificationController.text.trim(),
      breed: breedController.text.trim(),
      gender: selectedGender,
      quantity: recordType == 'Individual' ? 1 : quantity,
      weightKg: weight,
      dateOfBirth: selectedDateOfBirth,
      healthStatus: healthStatus,
      location: locationController.text.trim(),
      notes: notesController.text.trim(),
    );

    Navigator.pop(
      context,
      updatedLivestock,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: const Text(
          'Edit Livestock',
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

              const Text(
                'Record Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF17201A),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Update how this livestock record is managed.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF66736A),
                ),
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

              const SizedBox(height: 28),

              DropdownButtonFormField<String>(
                initialValue: selectedAnimalType,
                decoration: const InputDecoration(
                  labelText: 'Animal Type',
                  prefixIcon: Icon(Icons.pets_outlined),
                ),
                items: animalTypes.map((animal) {
                  return DropdownMenuItem<String>(
                    value: animal,
                    child: Text(animal),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedAnimalType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: identificationController,
                decoration: InputDecoration(
                  labelText: recordType == 'Individual'
                      ? 'Tag / Identification Number'
                      : 'Group / Herd / Flock Name',
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter identification';
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
                  prefixIcon: Icon(
                    Icons.category_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
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
                  prefixIcon: Icon(Icons.wc_rounded),
                ),
                items: genders
                    .where(
                      (gender) =>
                  recordType == 'Group' ||
                      gender != 'Mixed',
                )
                    .map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedGender = value;
                    });
                  }
                },
              ),

              if (recordType == 'Group') ...[
                const SizedBox(height: 16),

                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of Animals',
                    prefixIcon: Icon(
                      Icons.numbers_rounded,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter quantity';
                    }

                    final quantity = int.tryParse(value.trim());

                    if (quantity == null || quantity <= 0) {
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
                  prefixIcon: const Icon(
                    Icons.monitor_weight_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }

                  final weight = double.tryParse(value.trim());

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
                    suffixIcon: selectedDateOfBirth == null
                        ? const Icon(
                      Icons.arrow_drop_down_rounded,
                    )
                        : IconButton(
                      onPressed: () {
                        setState(() {
                          selectedDateOfBirth = null;
                        });
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ),
                  child: Text(
                    selectedDateOfBirth == null
                        ? 'Not recorded'
                        : _formatDate(
                      selectedDateOfBirth!,
                    ),
                  ),
                ),
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
                  return DropdownMenuItem<String>(
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
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter farm location';
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
                  hintText: 'Update livestock notes...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 55),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _updateLivestock,
                  icon: const Icon(
                    Icons.save_outlined,
                  ),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(
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
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Livestock Record',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.livestock.displayName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        duration: const Duration(milliseconds: 200),
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