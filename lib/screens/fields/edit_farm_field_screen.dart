import 'package:flutter/material.dart';

import '../../models/farm_field.dart';
import '../../services/database_service.dart';

class EditFarmFieldScreen extends StatefulWidget {
  final FarmField field;

  const EditFarmFieldScreen({
    super.key,
    required this.field,
  });

  @override
  State<EditFarmFieldScreen> createState() =>
      _EditFarmFieldScreenState();
}

class _EditFarmFieldScreenState
    extends State<EditFarmFieldScreen> {
  static const Color _primaryGreen = Color(0xFF1B5E20);
  static const Color _darkGreen = Color(0xFF0B3D1B);
  static const Color _mediumGreen = Color(0xFF43A047);
  static const Color _background = Color(0xFFF4F7F4);
  static const Color _textPrimary = Color(0xFF17201A);
  static const Color _textSecondary = Color(0xFF66736A);

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final DatabaseService _databaseService =
      DatabaseService.instance;

  late final TextEditingController _fieldNameController;
  late final TextEditingController _sizeController;
  late final TextEditingController _notesController;

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

  late String _selectedCrop;
  late String _selectedStatus;

  late DateTime _plantingDate;
  late DateTime _expectedHarvestDate;

  double? _latitude;
  double? _longitude;

  bool _isSaving = false;
  bool _hasSavedFarmLocation = false;
  bool _attachSavedFarmLocation = false;

  double? _savedFarmLatitude;
  double? _savedFarmLongitude;

  @override
  void initState() {
    super.initState();

    _fieldNameController = TextEditingController(
      text: widget.field.name,
    );

    _sizeController = TextEditingController(
      text: widget.field.sizeHectares.toString(),
    );

    _notesController = TextEditingController(
      text: widget.field.notes,
    );

    _selectedCrop = _normaliseCrop(widget.field.crop);
    _selectedStatus =
        _normaliseStatus(widget.field.status);

    _plantingDate = widget.field.plantingDate;
    _expectedHarvestDate =
        widget.field.expectedHarvestDate;

    _latitude = widget.field.latitude;
    _longitude = widget.field.longitude;

    _loadSavedFarmLocation();
  }

  String _normaliseCrop(String crop) {
    if (_crops.contains(crop)) {
      return crop;
    }

    if (crop.toLowerCase() == 'onion') {
      return 'Onions';
    }

    return 'Other';
  }

  String _normaliseStatus(String status) {
    if (_statuses.contains(status)) {
      return status;
    }

    return 'Planned';
  }

  Future<void> _loadSavedFarmLocation() async {
    try {
      final location =
      await _databaseService.getFarmLocation();

      if (!mounted) return;

      if (location == null) {
        setState(() {
          _hasSavedFarmLocation = false;
        });

        return;
      }

      final latitude = location['latitude'];
      final longitude = location['longitude'];

      if (latitude is! num || longitude is! num) {
        return;
      }

      setState(() {
        _hasSavedFarmLocation = true;

        _savedFarmLatitude =
            latitude.toDouble();

        _savedFarmLongitude =
            longitude.toDouble();

        if (!widget.field.hasLocation) {
          _attachSavedFarmLocation = false;
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasSavedFarmLocation = false;
      });
    }
  }

  @override
  void dispose() {
    _fieldNameController.dispose();
    _sizeController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _selectPlantingDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _plantingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Select Planting Date',
    );

    if (selectedDate == null || !mounted) {
      return;
    }

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
    final minimumDate =
    _plantingDate.add(
      const Duration(days: 1),
    );

    final initialDate =
    _expectedHarvestDate.isAfter(
      _plantingDate,
    )
        ? _expectedHarvestDate
        : minimumDate;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minimumDate,
      lastDate: DateTime(2036),
      helpText: 'Select Expected Harvest Date',
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _expectedHarvestDate = selectedDate;
    });
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.field.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This farm field cannot be updated because it has no database ID.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

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
      double? latitude = _latitude;
      double? longitude = _longitude;

      if (_attachSavedFarmLocation &&
          _savedFarmLatitude != null &&
          _savedFarmLongitude != null) {
        latitude = _savedFarmLatitude;
        longitude = _savedFarmLongitude;
      }

      final updatedField = FarmField(
        id: widget.field.id,
        name: _fieldNameController.text.trim(),
        crop: _selectedCrop,
        sizeHectares: size,
        plantingDate: _plantingDate,
        expectedHarvestDate:
        _expectedHarvestDate,
        status: _selectedStatus,
        notes: _notesController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        createdAt: widget.field.createdAt,
      );

      await _databaseService.updateFarmField(
        updatedField,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update the farm field. Please try again.',
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
          'Edit Farm Field',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              120,
            ),
            children: [
              _buildHeader(),

              const SizedBox(height: 22),

              _buildSectionTitle(
                icon: Icons.landscape_outlined,
                title: 'Field Information',
                subtitle:
                'Update the basic details of this farm field.',
              ),

              const SizedBox(height: 13),

              _buildFieldInformationCard(),

              const SizedBox(height: 24),

              _buildSectionTitle(
                icon: Icons.calendar_month_outlined,
                title: 'Planting Schedule',
                subtitle:
                'Update planting and expected harvest dates.',
              ),

              const SizedBox(height: 13),

              _buildScheduleCard(),

              const SizedBox(height: 24),

              _buildSectionTitle(
                icon: Icons.location_on_outlined,
                title: 'Field Location',
                subtitle:
                'Keep the existing GPS location or attach the saved farm location.',
              ),

              const SizedBox(height: 13),

              _buildLocationCard(),

              const SizedBox(height: 24),

              _buildSectionTitle(
                icon: Icons.notes_rounded,
                title: 'Field Notes',
                subtitle:
                'Update any important information about this field.',
              ),

              const SizedBox(height: 13),

              _buildNotesCard(),

              const SizedBox(height: 26),

              _buildSaveButton(),
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
            _darkGreen,
            _primaryGreen,
            _mediumGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
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
                  'Update Field',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Keep your field records accurate as the farming season progresses.',
                  style: TextStyle(
                    color: Color(0xFFD7EED9),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14),
          Icon(
            Icons.edit_note_rounded,
            color: Colors.white,
            size: 52,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: _primaryGreen,
            size: 21,
          ),
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
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 10.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldInformationCard() {
    return _buildCard(
      child: Column(
        children: [
          TextFormField(
            controller: _fieldNameController,
            textCapitalization:
            TextCapitalization.words,
            decoration: _inputDecoration(
              label: 'Field Name',
              hint: 'Example: Field A',
              icon: Icons.badge_outlined,
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Please enter the field name.';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedCrop,
            decoration: _inputDecoration(
              label: 'Crop',
              hint: 'Select crop',
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
              final size = double.tryParse(
                value?.trim() ?? '',
              );

              if (size == null || size <= 0) {
                return 'Enter a valid field size.';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: _inputDecoration(
              label: 'Field Status',
              hint: 'Select status',
              icon: Icons.flag_outlined,
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
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return _buildCard(
      child: Column(
        children: [
          _buildDateTile(
            title: 'Planting Date',
            value: _formatDate(_plantingDate),
            icon: Icons.calendar_today_outlined,
            onTap: _selectPlantingDate,
          ),

          const Divider(height: 28),

          _buildDateTile(
            title: 'Expected Harvest',
            value: _formatDate(
              _expectedHarvestDate,
            ),
            icon: Icons.event_available_outlined,
            onTap: _selectHarvestDate,
          ),

          const Divider(height: 28),

          Row(
            children: [
              const Icon(
                Icons.timelapse_rounded,
                color: _primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Growing Period',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${_expectedHarvestDate.difference(_plantingDate).inDays} days',
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final hasCurrentLocation =
        _latitude != null && _longitude != null;

    return _buildCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasCurrentLocation
                    ? Icons.location_on_rounded
                    : Icons.location_off_outlined,
                color: hasCurrentLocation
                    ? _primaryGreen
                    : _textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasCurrentLocation
                      ? 'This field already has a GPS location.'
                      : 'This field does not currently have a GPS location.',
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          if (hasCurrentLocation) ...[
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.offline_pin_outlined,
                    color: _primaryGreen,
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'The existing field GPS location will be kept unless you attach the saved farm location below.',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_hasSavedFarmLocation) ...[
            const SizedBox(height: 14),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _attachSavedFarmLocation,
              activeThumbColor: _primaryGreen,
              title: const Text(
                'Attach Saved Farm GPS',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: const Text(
                'Replace the field location with the GPS location saved in Farm GPS & Location.',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _attachSavedFarmLocation = value;
                });
              },
            ),
          ] else ...[
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFFECB3),
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFF57F17),
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'No saved farm GPS location is available. You can save one from Farm GPS & Location.',
                      style: TextStyle(
                        color: Color(0xFF6D5B00),
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return _buildCard(
      child: TextFormField(
        controller: _notesController,
        minLines: 4,
        maxLines: 7,
        textCapitalization:
        TextCapitalization.sentences,
        decoration: _inputDecoration(
          label: 'Notes',
          hint:
          'Add soil, irrigation, fertiliser or field notes...',
          icon: Icons.notes_rounded,
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: _primaryGreen,
                size: 20,
              ),
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
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit_calendar_outlined,
              color: _primaryGreen,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: _primaryGreen,
      ),
      suffixText: suffixText,
      filled: true,
      fillColor: const Color(0xFFF8FAF8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFDDE5DE),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFDDE5DE),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _primaryGreen,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 56,
      child: FilledButton.icon(
        onPressed: _isSaving
            ? null
            : _saveChanges,
        style: FilledButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          _primaryGreen.withValues(
            alpha: 0.55,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: _isSaving
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.save_outlined,
        ),
        label: Text(
          _isSaving
              ? 'Saving Changes...'
              : 'Save Changes',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}