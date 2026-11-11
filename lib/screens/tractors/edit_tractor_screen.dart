import 'package:flutter/material.dart';

import '../../models/tractor.dart';

class EditTractorScreen extends StatefulWidget {
  final Tractor tractor;

  const EditTractorScreen({
    super.key,
    required this.tractor,
  });

  @override
  State<EditTractorScreen> createState() => _EditTractorScreenState();
}

class _EditTractorScreenState extends State<EditTractorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController modelController;
  late final TextEditingController registrationController;
  late final TextEditingController yearController;
  late final TextEditingController engineHoursController;
  late final TextEditingController locationController;
  late final TextEditingController notesController;

  late String selectedBrand;
  late String fuelType;
  late String condition;
  late String status;

  DateTime? lastServiceDate;
  DateTime? nextServiceDate;

  final List<String> brands = [
    'Massey Ferguson',
    'John Deere',
    'New Holland',
    'Case IH',
    'Deutz-Fahr',
    'Mahindra',
    'Landini',
    'Kubota',
    'Ford',
    'Fiat',
    'Other',
  ];

  final List<String> fuelTypes = [
    'Diesel',
    'Petrol',
    'Electric',
    'Other',
  ];

  final List<String> conditions = [
    'Excellent',
    'Good',
    'Fair',
    'Poor',
    'Needs Repair',
  ];

  final List<String> statuses = [
    'Operational',
    'In Use',
    'Under Maintenance',
    'Out of Service',
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.tractor.name,
    );

    modelController = TextEditingController(
      text: widget.tractor.model,
    );

    registrationController = TextEditingController(
      text: widget.tractor.registrationNumber,
    );

    yearController = TextEditingController(
      text: widget.tractor.year.toString(),
    );

    engineHoursController = TextEditingController(
      text: widget.tractor.engineHours.toString(),
    );

    locationController = TextEditingController(
      text: widget.tractor.location,
    );

    notesController = TextEditingController(
      text: widget.tractor.notes,
    );

    selectedBrand = widget.tractor.brand;
    fuelType = widget.tractor.fuelType;
    condition = widget.tractor.condition;
    status = widget.tractor.status;

    lastServiceDate = widget.tractor.lastServiceDate;
    nextServiceDate = widget.tractor.nextServiceDate;
  }

  @override
  void dispose() {
    nameController.dispose();
    modelController.dispose();
    registrationController.dispose();
    yearController.dispose();
    engineHoursController.dispose();
    locationController.dispose();
    notesController.dispose();

    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _selectLastServiceDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: lastServiceDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        lastServiceDate = selectedDate;
      });
    }
  }

  Future<void> _selectNextServiceDate() async {
    final today = DateTime.now();

    DateTime initialDate =
        nextServiceDate ?? today.add(const Duration(days: 90));

    if (initialDate.isBefore(today)) {
      initialDate = today;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(2040),
    );

    if (selectedDate != null) {
      setState(() {
        nextServiceDate = selectedDate;
      });
    }
  }

  void _updateTractor() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final int? year = int.tryParse(
      yearController.text.trim(),
    );

    final double? engineHours = double.tryParse(
      engineHoursController.text.trim(),
    );

    if (year == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid tractor year.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    if (engineHours == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid engine hours.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final updatedTractor = Tractor(
      name: nameController.text.trim(),
      brand: selectedBrand,
      model: modelController.text.trim(),
      registrationNumber:
      registrationController.text.trim(),
      year: year,
      engineHours: engineHours,
      fuelType: fuelType,
      condition: condition,
      status: status,
      location: locationController.text.trim(),
      lastServiceDate: lastServiceDate,
      nextServiceDate: nextServiceDate,
      notes: notesController.text.trim(),
    );

    Navigator.pop(
      context,
      updatedTractor,
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
          'Edit Tractor',
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
                'Tractor Information',
              ),

              const SizedBox(height: 15),

              _buildLabel('Tractor Name'),

              const SizedBox(height: 8),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Example: Main Ploughing Tractor',
                  prefixIcon: Icon(
                    Icons.agriculture_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter a tractor name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('Brand'),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedBrand,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.factory_outlined,
                  ),
                ),
                items: brands.map((brand) {
                  return DropdownMenuItem<String>(
                    value: brand,
                    child: Text(brand),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedBrand = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('Model'),

              const SizedBox(height: 8),

              TextFormField(
                controller: modelController,
                decoration: const InputDecoration(
                  hintText: 'Example: MF 265',
                  prefixIcon: Icon(
                    Icons.settings_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter the tractor model';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _buildLabel(
                'Registration / Fleet Number',
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: registrationController,
                decoration: const InputDecoration(
                  hintText: 'Example: TR-001',
                  prefixIcon: Icon(
                    Icons.confirmation_number_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter a registration or fleet number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('Year'),

              const SizedBox(height: 8),

              TextFormField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Example: 1985',
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter the tractor year';
                  }

                  final year = int.tryParse(
                    value.trim(),
                  );

                  if (year == null ||
                      year < 1900 ||
                      year > 2100) {
                    return 'Please enter a valid year';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              _buildSectionTitle(
                'Operating Information',
              ),

              const SizedBox(height: 15),

              _buildLabel('Engine Hours'),

              const SizedBox(height: 8),

              TextFormField(
                controller: engineHoursController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Example: 4520',
                  prefixIcon: Icon(
                    Icons.timer_outlined,
                  ),
                  suffixText: 'hrs',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter engine hours';
                  }

                  final hours = double.tryParse(
                    value.trim(),
                  );

                  if (hours == null || hours < 0) {
                    return 'Please enter valid engine hours';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('Fuel Type'),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: fuelType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.local_gas_station_outlined,
                  ),
                ),
                items: fuelTypes.map((fuel) {
                  return DropdownMenuItem<String>(
                    value: fuel,
                    child: Text(fuel),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    fuelType = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('Condition'),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: condition,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.build_circle_outlined,
                  ),
                ),
                items: conditions.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    condition = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('Status'),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.info_outline_rounded,
                  ),
                ),
                items: statuses.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    status = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('Current Location'),

              const SizedBox(height: 8),

              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: 'Example: Main Shed',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter the tractor location';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              _buildSectionTitle(
                'Service & Maintenance',
              ),

              const SizedBox(height: 15),

              _buildDateSelector(
                title: 'Last Service Date',
                value: _formatDate(
                  lastServiceDate,
                ),
                icon: Icons.history_rounded,
                onTap: _selectLastServiceDate,
              ),

              const SizedBox(height: 14),

              _buildDateSelector(
                title: 'Next Service Date',
                value: _formatDate(
                  nextServiceDate,
                ),
                icon: Icons.event_available_outlined,
                onTap: _selectNextServiceDate,
              ),

              const SizedBox(height: 30),

              _buildSectionTitle(
                'Additional Notes',
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: notesController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText:
                  'Enter tractor notes, repairs, work performed or other information...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _updateTractor,
                  icon: const Icon(
                    Icons.save_outlined,
                  ),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 54,
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
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'Update Tractor',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            widget.tractor.displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFC8E6C9),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Keep your machinery information accurate and up to date.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF17201A),
      ),
    );
  }

  Widget _buildDateSelector({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE3E8E4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF1B5E20),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF66736A),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17201A),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.calendar_month_outlined,
              color: Color(0xFF66736A),
            ),
          ],
        ),
      ),
    );
  }
}