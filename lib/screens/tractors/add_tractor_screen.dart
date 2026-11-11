import 'package:flutter/material.dart';

import '../../models/tractor.dart';

class AddTractorScreen extends StatefulWidget {
  const AddTractorScreen({super.key});

  @override
  State<AddTractorScreen> createState() => _AddTractorScreenState();
}

class _AddTractorScreenState extends State<AddTractorScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final modelController = TextEditingController();
  final registrationController = TextEditingController();
  final yearController = TextEditingController();
  final engineHoursController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();

  String? selectedBrand;
  String fuelType = 'Diesel';
  String condition = 'Good';
  String status = 'Operational';

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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _selectLastServiceDate() async {
    final today = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: lastServiceDate ?? today,
      firstDate: DateTime(1990),
      lastDate: today,
    );

    if (selectedDate != null) {
      setState(() {
        lastServiceDate = selectedDate;
      });
    }
  }

  Future<void> _selectNextServiceDate() async {
    final today = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
      nextServiceDate ?? today.add(const Duration(days: 90)),
      firstDate: today,
      lastDate: DateTime(2040),
    );

    if (selectedDate != null) {
      setState(() {
        nextServiceDate = selectedDate;
      });
    }
  }

  void _saveTractor() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final year = int.tryParse(
      yearController.text.trim(),
    ) ??
        DateTime.now().year;

    final engineHours = double.tryParse(
      engineHoursController.text.trim(),
    ) ??
        0;

    final tractor = Tractor(
      name: nameController.text.trim(),
      brand: selectedBrand!,
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
      tractor,
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
          'Add Tractor',
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
                'Enter the basic details of the tractor.',
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Tractor Name',
                  hintText: 'Example: Main Ploughing Tractor',
                  prefixIcon: Icon(
                    Icons.agriculture_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a tractor name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: selectedBrand,
                decoration: const InputDecoration(
                  labelText: 'Brand',
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
                  setState(() {
                    selectedBrand = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a tractor brand';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: modelController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'Example: MF 265',
                  prefixIcon: Icon(
                    Icons.settings_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the tractor model';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: registrationController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Registration / Fleet Number',
                  hintText: 'Example: TR-001',
                  prefixIcon: Icon(
                    Icons.confirmation_number_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a registration or fleet number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  hintText: 'Example: 1995',
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the tractor year';
                  }

                  final year = int.tryParse(value.trim());
                  final currentYear = DateTime.now().year;

                  if (year == null ||
                      year < 1900 ||
                      year > currentYear + 1) {
                    return 'Please enter a valid year';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'Operating Information',
                'Record the tractor condition and usage.',
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: engineHoursController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Engine Hours',
                  hintText: 'Example: 4520',
                  prefixIcon: Icon(
                    Icons.timer_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter engine hours';
                  }

                  final hours = double.tryParse(value.trim());

                  if (hours == null || hours < 0) {
                    return 'Please enter valid engine hours';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: fuelType,
                decoration: const InputDecoration(
                  labelText: 'Fuel Type',
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
                  if (value != null) {
                    setState(() {
                      fuelType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: condition,
                decoration: const InputDecoration(
                  labelText: 'Condition',
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
                  if (value != null) {
                    setState(() {
                      condition = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(
                  labelText: 'Operating Status',
                  prefixIcon: Icon(
                    Icons.power_settings_new_rounded,
                  ),
                ),
                items: statuses.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: locationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Current Location',
                  hintText: 'Example: Main Shed',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter tractor location';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'Service & Maintenance',
                'Keep track of tractor servicing.',
              ),

              const SizedBox(height: 16),

              _buildDateField(
                title: 'Last Service Date',
                date: lastServiceDate,
                onTap: _selectLastServiceDate,
                allowClear: true,
                onClear: () {
                  setState(() {
                    lastServiceDate = null;
                  });
                },
              ),

              const SizedBox(height: 16),

              _buildDateField(
                title: 'Next Service Date',
                date: nextServiceDate,
                onTap: _selectNextServiceDate,
                allowClear: true,
                onClear: () {
                  setState(() {
                    nextServiceDate = null;
                  });
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
                  'Repairs, service information or other notes...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 55),
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
                  onPressed: _saveTractor,
                  icon: const Icon(
                    Icons.save_outlined,
                  ),
                  label: const Text(
                    'Save Tractor',
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
                    foregroundColor:
                    const Color(0xFF1B5E20),
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
      child: const Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
              size: 33,
            ),
          ),

          SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register Tractor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Manage machinery, usage and maintenance.',
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

  Widget _buildDateField({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
    required bool allowClear,
    required VoidCallback onClear,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          prefixIcon: const Icon(
            Icons.calendar_month_outlined,
          ),
          suffixIcon: date != null && allowClear
              ? IconButton(
            onPressed: onClear,
            icon: const Icon(
              Icons.close_rounded,
            ),
          )
              : const Icon(
            Icons.arrow_drop_down_rounded,
          ),
        ),
        child: Text(
          date == null
              ? 'Select date (optional)'
              : _formatDate(date),
          style: TextStyle(
            color: date == null
                ? const Color(0xFF66736A)
                : const Color(0xFF17201A),
          ),
        ),
      ),
    );
  }
}