import 'package:flutter/material.dart';

import '../../models/crop.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController varietyController =
  TextEditingController();

  final TextEditingController fieldController =
  TextEditingController();

  final TextEditingController areaController =
  TextEditingController();

  final TextEditingController plantingDateController =
  TextEditingController();

  final TextEditingController harvestDateController =
  TextEditingController();

  final TextEditingController notesController =
  TextEditingController();

  String? selectedCrop;

  DateTime? selectedPlantingDate;
  DateTime? selectedHarvestDate;

  final List<String> cropTypes = [
    'Cabbage',
    'Spinach',
    'Onion',
    'Maize',
    'Potato',
    'Carrot',
    'Tomato',
    'Other',
  ];

  @override
  void dispose() {
    varietyController.dispose();
    fieldController.dispose();
    areaController.dispose();
    plantingDateController.dispose();
    harvestDateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _selectPlantingDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedPlantingDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (date == null) {
      return;
    }

    setState(() {
      selectedPlantingDate = date;
      plantingDateController.text = _formatDate(date);

      if (selectedHarvestDate != null &&
          selectedHarvestDate!.isBefore(date)) {
        selectedHarvestDate = null;
        harvestDateController.clear();
      }
    });
  }

  Future<void> _selectHarvestDate() async {
    final DateTime firstAllowedDate =
        selectedPlantingDate ?? DateTime.now();

    final DateTime initialDate =
    firstAllowedDate.add(const Duration(days: 60));

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstAllowedDate,
      lastDate: DateTime(2035),
    );

    if (date == null) {
      return;
    }

    setState(() {
      selectedHarvestDate = date;
      harvestDateController.text = _formatDate(date);
    });
  }

  void _saveCrop() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCrop == null ||
        selectedPlantingDate == null ||
        selectedHarvestDate == null) {
      return;
    }

    final double? area =
    double.tryParse(areaController.text.trim());

    if (area == null || area <= 0) {
      return;
    }

    final Crop newCrop = Crop(
      cropName: selectedCrop!,
      variety: varietyController.text.trim(),
      field: fieldController.text.trim(),
      area: area,
      plantingDate: selectedPlantingDate!,
      harvestDate: selectedHarvestDate!,
      notes: notesController.text.trim(),
    );

    Navigator.pop(context, newCrop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: const Text(
          'Add New Crop',
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
            15,
            20,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),

              const SizedBox(height: 30),

              const Text(
                'Crop Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF17201A),
                ),
              ),

              const SizedBox(height: 20),

              _buildLabel('Crop Type'),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedCrop,
                decoration: const InputDecoration(
                  hintText: 'Select crop',
                  prefixIcon: Icon(
                    Icons.eco_outlined,
                  ),
                ),
                items: cropTypes.map((crop) {
                  return DropdownMenuItem<String>(
                    value: crop,
                    child: Text(crop),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCrop = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a crop';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildLabel('Variety'),

              const SizedBox(height: 8),

              TextFormField(
                controller: varietyController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Example: Green Cabbage',
                  prefixIcon: Icon(
                    Icons.grass_rounded,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the crop variety';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildLabel('Field / Plot'),

              const SizedBox(height: 8),

              TextFormField(
                controller: fieldController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Example: Field A',
                  prefixIcon: Icon(
                    Icons.landscape_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the field or plot';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildLabel('Area Planted'),

              const SizedBox(height: 8),

              TextFormField(
                controller: areaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Example: 0.5',
                  prefixIcon: Icon(
                    Icons.square_foot_rounded,
                  ),
                  suffixText: 'ha',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the planted area';
                  }

                  final area = double.tryParse(value.trim());

                  if (area == null || area <= 0) {
                    return 'Enter a valid area';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              const Text(
                'Planting Schedule',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF17201A),
                ),
              ),

              const SizedBox(height: 20),

              _buildLabel('Planting Date'),

              const SizedBox(height: 8),

              TextFormField(
                controller: plantingDateController,
                readOnly: true,
                onTap: _selectPlantingDate,
                decoration: const InputDecoration(
                  hintText: 'Select planting date',
                  prefixIcon: Icon(
                    Icons.calendar_month_outlined,
                  ),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down_rounded,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the planting date';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildLabel('Expected Harvest Date'),

              const SizedBox(height: 8),

              TextFormField(
                controller: harvestDateController,
                readOnly: true,
                onTap: _selectHarvestDate,
                decoration: const InputDecoration(
                  hintText: 'Select expected harvest date',
                  prefixIcon: Icon(
                    Icons.event_available_outlined,
                  ),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down_rounded,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the harvest date';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF17201A),
                ),
              ),

              const SizedBox(height: 20),

              _buildLabel('Notes'),

              const SizedBox(height: 8),

              TextFormField(
                controller: notesController,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText:
                  'Add irrigation, fertiliser, soil or other crop notes...',
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _saveCrop,
                  icon: const Icon(
                    Icons.save_outlined,
                  ),
                  label: const Text(
                    'Save Crop',
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

  Widget _buildHeaderCard() {
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
              Icons.eco_rounded,
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
                  'Register a Crop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Record planting information and monitor crop production.',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF17201A),
      ),
    );
  }
}