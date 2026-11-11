import 'package:flutter/material.dart';

import '../../models/farm_field.dart';
import '../../services/database_service.dart';

class AddFarmFieldScreen extends StatefulWidget {
  const AddFarmFieldScreen({super.key});

  @override
  State<AddFarmFieldScreen> createState() =>
      _AddFarmFieldScreenState();
}

class _AddFarmFieldScreenState
    extends State<AddFarmFieldScreen> {
  static const Color _primaryGreen = Color(0xFF1B5E20);
  static const Color _darkGreen = Color(0xFF0B3D1B);
  static const Color _mediumGreen = Color(0xFF43A047);
  static const Color _background = Color(0xFFF4F7F4);
  static const Color _textPrimary = Color(0xFF17201A);
  static const Color _textSecondary = Color(0xFF66736A);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fieldNameController =
  TextEditingController();

  final TextEditingController _sizeController =
  TextEditingController();

  final TextEditingController _notesController =
  TextEditingController();

  final List<String> _crops = [
    'Cabbage',
    'Spinach',
    'Onions',
    'Other',
  ];

  final List<String> _statuses = [
    'Planned',
    'Planted',
    'Growing',
    'Ready',
    'Harvested',
  ];

  String _selectedCrop = 'Cabbage';
  String _selectedStatus = 'Planned';

  DateTime _plantingDate = DateTime.now();

  late DateTime _expectedHarvestDate;

  bool _useSavedFarmLocation = false;
  bool _isLoadingLocation = true;
  bool _isSaving = false;

  double? _farmLatitude;
  double? _farmLongitude;

  @override
  void initState() {
    super.initState();

    _expectedHarvestDate =
        DateTime.now().add(const Duration(days: 90));

    _loadSavedFarmLocation();
  }

  @override
  void dispose() {
    _fieldNameController.dispose();
    _sizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedFarmLocation() async {
    try {
      final location =
      await DatabaseService.instance.getFarmLocation();

      if (!mounted) return;

      if (location == null) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      final latitude = location['latitude'];
      final longitude = location['longitude'];

      setState(() {
        _farmLatitude =
        latitude is num ? latitude.toDouble() : null;

        _farmLongitude =
        longitude is num ? longitude.toDouble() : null;

        _isLoadingLocation = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  bool get _hasSavedFarmLocation {
    return _farmLatitude != null &&
        _farmLongitude != null;
  }

  Future<void> _selectPlantingDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _plantingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      helpText: 'Select Planting Date',
    );

    if (selectedDate == null) return;

    setState(() {
      _plantingDate = selectedDate;

      if (!_expectedHarvestDate.isAfter(
        _plantingDate,
      )) {
        _expectedHarvestDate =
            _plantingDate.add(
              const Duration(days: 90),
            );
      }
    });
  }

  Future<void> _selectHarvestDate() async {
    final minimumHarvestDate =
    _plantingDate.add(const Duration(days: 1));

    final initialDate =
    _expectedHarvestDate.isAfter(_plantingDate)
        ? _expectedHarvestDate
        : minimumHarvestDate;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minimumHarvestDate,
      lastDate: DateTime(2040),
      helpText: 'Select Expected Harvest Date',
    );

    if (selectedDate == null) return;

    setState(() {
      _expectedHarvestDate = selectedDate;
    });
  }

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  int get _growingDays {
    return _expectedHarvestDate
        .difference(_plantingDate)
        .inDays;
  }

  Future<void> _saveField() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_expectedHarvestDate.isAfter(
      _plantingDate,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Expected harvest date must be after the planting date.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final size = double.tryParse(
      _sizeController.text.trim(),
    );

    if (size == null || size <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid field size.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final field = FarmField(
        name: _fieldNameController.text.trim(),
        crop: _selectedCrop,
        sizeHectares: size,
        plantingDate: _plantingDate,
        expectedHarvestDate:
        _expectedHarvestDate,
        status: _selectedStatus,
        notes: _notesController.text.trim(),
        latitude: _useSavedFarmLocation
            ? _farmLatitude
            : null,
        longitude: _useSavedFarmLocation
            ? _farmLongitude
            : null,
      );

      await DatabaseService.instance.addFarmField(
        field,
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${field.name} added successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save the farm field.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Add Farm Field',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              120,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  title: 'Field Information',
                  subtitle:
                  'Enter the basic information about this field.',
                ),

                const SizedBox(height: 14),

                _buildFieldInformation(),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  title: 'Planting Plan',
                  subtitle:
                  'Choose the crop and important farming dates.',
                ),

                const SizedBox(height: 14),

                _buildPlantingPlan(),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  title: 'Farm GPS',
                  subtitle:
                  'Optionally attach your saved farm location.',
                ),

                const SizedBox(height: 14),

                _buildGpsSection(),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  title: 'Field Notes',
                  subtitle:
                  'Add any useful information about this field.',
                ),

                const SizedBox(height: 14),

                _buildNotesSection(),

                const SizedBox(height: 28),

                _buildSaveButton(),
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
            _darkGreen,
            _primaryGreen,
            _mediumGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Field',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Build a digital record for your planting area.',
                  style: TextStyle(
                    color: Color(0xFFD7EED9),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Icon(
            Icons.add_location_alt_rounded,
            color: Colors.white,
            size: 52,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 10.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldInformation() {
    return _formCard(
      children: [
        TextFormField(
          controller: _fieldNameController,
          textCapitalization:
          TextCapitalization.words,
          decoration: _inputDecoration(
            label: 'Field Name',
            hint: 'Example: North Field',
            icon: Icons.landscape_outlined,
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Please enter a field name.';
            }

            if (value.trim().length < 2) {
              return 'Field name is too short.';
            }

            return null;
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _sizeController,
          keyboardType:
          const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: _inputDecoration(
            label: 'Field Size',
            hint: 'Example: 1.5',
            icon: Icons.square_foot_rounded,
            suffixText: 'ha',
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Please enter the field size.';
            }

            final size = double.tryParse(
              value.trim(),
            );

            if (size == null || size <= 0) {
              return 'Enter a valid size greater than 0.';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPlantingPlan() {
    return _formCard(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedCrop,
          decoration: _inputDecoration(
            label: 'Crop',
            icon: Icons.eco_outlined,
          ),
          items: _crops.map((crop) {
            return DropdownMenuItem<String>(
              value: crop,
              child: Text(crop),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedCrop = value;
            });
          },
        ),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _selectedStatus,
          decoration: _inputDecoration(
            label: 'Field Status',
            icon: Icons.timeline_rounded,
          ),
          items: _statuses.map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedStatus = value;
            });
          },
        ),

        const SizedBox(height: 18),

        _dateSelector(
          title: 'Planting Date',
          value: _formatDate(_plantingDate),
          icon: Icons.calendar_today_outlined,
          onTap: _selectPlantingDate,
        ),

        const SizedBox(height: 12),

        _dateSelector(
          title: 'Expected Harvest',
          value:
          _formatDate(_expectedHarvestDate),
          icon: Icons.event_available_outlined,
          onTap: _selectHarvestDate,
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: _primaryGreen,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Planned growing period: '
                      '$_growingDays days',
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGpsSection() {
    if (_isLoadingLocation) {
      return _formCard(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _primaryGreen,
                  ),
                ),
                SizedBox(width: 13),
                Expanded(
                  child: Text(
                    'Checking for a saved farm location...',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (!_hasSavedFarmLocation) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFE082),
          ),
        ),
        child: const Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_off_outlined,
              color: Color(0xFFF57F17),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Saved Farm GPS',
                    style: TextStyle(
                      color: Color(0xFF6D4C00),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'You can still create this field. Save your farm location from the Farm GPS screen if you want to attach GPS information later.',
                    style: TextStyle(
                      color: Color(0xFF795F21),
                      fontSize: 10.5,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _formCard(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _useSavedFarmLocation,
          activeThumbColor: _primaryGreen,
          title: const Text(
            'Attach Saved Farm GPS',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Use the farm location stored on this device.',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 10.5,
              ),
            ),
          ),
          secondary: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: _primaryGreen,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _useSavedFarmLocation = value;
            });
          },
        ),

        if (_useSavedFarmLocation) ...[
          const Divider(height: 24),

          const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: _primaryGreen,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Saved farm GPS will be attached to this field.',
                  style: TextStyle(
                    color: _primaryGreen,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection() {
    return _formCard(
      children: [
        TextFormField(
          controller: _notesController,
          minLines: 4,
          maxLines: 7,
          textCapitalization:
          TextCapitalization.sentences,
          decoration: _inputDecoration(
            label: 'Notes',
            hint:
            'Soil condition, irrigation, fertiliser plan, field preparation...',
            icon: Icons.notes_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _isSaving ? null : _saveField,
        style: FilledButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: _isSaving
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.save_rounded,
        ),
        label: Text(
          _isSaving
              ? 'Saving Field...'
              : 'Save Farm Field',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _formCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _dateSelector({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF7F9F7),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE0E6E1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: _primaryGreen,
                size: 21,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffixText,
      prefixIcon: Icon(
        icon,
        color: _primaryGreen,
      ),
      filled: true,
      fillColor: const Color(0xFFF7F9F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE0E6E1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE0E6E1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _primaryGreen,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }
}