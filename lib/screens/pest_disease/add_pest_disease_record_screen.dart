import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/farm_field.dart';
import '../../models/pest_disease_record.dart';
import '../../services/database_service.dart';
import '../../services/photo_storage_service.dart';

class AddPestDiseaseRecordScreen extends StatefulWidget {
  const AddPestDiseaseRecordScreen({super.key});

  @override
  State<AddPestDiseaseRecordScreen> createState() =>
      _AddPestDiseaseRecordScreenState();
}

class _AddPestDiseaseRecordScreenState
    extends State<AddPestDiseaseRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _problemNameController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  static const Color _primaryGreen = Color(0xFF1B5E20);
  static const Color _lightGreen = Color(0xFFE8F5E9);
  static const Color _darkText = Color(0xFF1D2A22);

  final List<String> _recordTypes = [
    'Pest',
    'Disease',
  ];

  final List<String> _crops = [
    'Cabbage',
    'Spinach',
    'Onions',
    'Other',
  ];

  final List<String> _severityLevels = [
    'Low',
    'Moderate',
    'High',
    'Critical',
  ];

  final List<String> _statuses = [
    'Active',
    'Monitoring',
    'Treated',
    'Resolved',
  ];

  String _selectedRecordType = 'Pest';
  String _selectedCrop = 'Cabbage';
  String _selectedSeverity = 'Low';
  String _selectedStatus = 'Active';

  String _selectedFieldName = 'Not linked to a field';

  DateTime _detectionDate = DateTime.now();
  DateTime? _treatmentDate;

  String? _photoPath;

  bool _isLoadingFields = true;
  bool _isSaving = false;

  List<FarmField> _farmFields = [];

  @override
  void initState() {
    super.initState();
    _loadFarmFields();
  }

  @override
  void dispose() {
    _problemNameController.dispose();
    _symptomsController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _loadFarmFields() async {
    try {
      final fields =
      await DatabaseService.instance.getFarmFields();

      if (!mounted) {
        return;
      }

      setState(() {
        _farmFields = fields;
        _isLoadingFields = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingFields = false;
      });

      _showMessage(
        'Could not load farm fields.',
        isError: true,
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo =
      await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (photo == null || !mounted) {
        return;
      }

      setState(() {
        _photoPath = photo.path;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not open the camera.',
        isError: true,
      );
    }
  }

  Future<void> _choosePhotoFromGallery() async {
    try {
      final XFile? photo =
      await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (photo == null || !mounted) {
        return;
      }

      setState(() {
        _photoPath = photo.path;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not open the photo gallery.',
        isError: true,
      );
    }
  }

  Future<void> _showPhotoSourceOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Photo Evidence',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Take a new photo or choose an existing '
                      'photo of the affected crop.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _sourceIcon(
                    Icons.camera_alt_outlined,
                  ),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Use the phone camera',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _sourceIcon(
                    Icons.photo_library_outlined,
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Select an existing photo',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _choosePhotoFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sourceIcon(
      IconData icon,
      ) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: _primaryGreen,
      ),
    );
  }

  void _removePhoto() {
    setState(() {
      _photoPath = null;
    });
  }

  Future<void> _selectDetectionDate() async {
    final DateTime? selectedDate =
    await showDatePicker(
      context: context,
      initialDate: _detectionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _detectionDate = selectedDate;
    });
  }

  Future<void> _selectTreatmentDate() async {
    final DateTime initialDate =
        _treatmentDate ?? DateTime.now();

    final DateTime? selectedDate =
    await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _treatmentDate = selectedDate;
    });
  }

  Future<void> _saveRecord() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String? permanentPhotoPath;

    try {
      if (_photoPath != null &&
          _photoPath!.trim().isNotEmpty) {
        permanentPhotoPath =
        await PhotoStorageService.instance.savePhoto(
          _photoPath!,
        );
      }

      final now = DateTime.now();

      final record = PestDiseaseRecord(
        recordType: _selectedRecordType,
        problemName:
        _problemNameController.text.trim(),
        crop: _selectedCrop,
        fieldName: _selectedFieldName,
        symptoms: _symptomsController.text.trim(),
        severity: _selectedSeverity,
        status: _selectedStatus,
        detectionDate: _detectionDate,
        treatment:
        _treatmentController.text.trim(),
        treatmentDate: _treatmentDate,
        notes: _notesController.text.trim(),
        photoPath: permanentPhotoPath,
        createdAt: now,
        updatedAt: now,
      );

      await DatabaseService.instance
          .addPestDiseaseRecord(record);

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (permanentPhotoPath != null) {
        try {
          await PhotoStorageService.instance.deletePhoto(
            permanentPhotoPath,
          );
        } catch (_) {
          // Keep the database save error as the main failure.
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Could not save the pest or disease record.',
        isError: true,
      );
    }
  }

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? Colors.red.shade700 : _primaryGreen,
      ),
    );
  }

  String _formatDate(
      DateTime date,
      ) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: const Text(
          'Add Pest & Disease Record',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _darkText,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              120,
            ),
            children: [
              _buildHeader(),

              const SizedBox(height: 18),

              _buildPhotoSection(),

              const SizedBox(height: 18),

              _buildSection(
                title: 'Problem Information',
                icon: Icons.bug_report_outlined,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue:
                      _selectedRecordType,
                      decoration: _inputDecoration(
                        label: 'Record Type',
                        icon:
                        Icons.category_outlined,
                      ),
                      items: _recordTypes
                          .map(
                            (type) =>
                            DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                      )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedRecordType =
                              value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller:
                      _problemNameController,
                      textCapitalization:
                      TextCapitalization.words,
                      decoration: _inputDecoration(
                        label: _selectedRecordType ==
                            'Pest'
                            ? 'Pest Name'
                            : 'Disease Name',
                        hint:
                        _selectedRecordType ==
                            'Pest'
                            ? 'e.g. Aphids'
                            : 'e.g. Black Rot',
                        icon:
                        Icons.warning_amber_rounded,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter the problem name.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedCrop,
                      decoration: _inputDecoration(
                        label: 'Affected Crop',
                        icon:
                        Icons.eco_outlined,
                      ),
                      items: _crops
                          .map(
                            (crop) =>
                            DropdownMenuItem(
                              value: crop,
                              child: Text(crop),
                            ),
                      )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedCrop = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    _buildFieldSelector(),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _buildSection(
                title: 'Symptoms & Severity',
                icon: Icons.health_and_safety_outlined,
                child: Column(
                  children: [
                    TextFormField(
                      controller:
                      _symptomsController,
                      maxLines: 4,
                      textCapitalization:
                      TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        label:
                        'Symptoms / Observations',
                        hint:
                        'Describe what you can see on the crop...',
                        icon:
                        Icons.visibility_outlined,
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please describe the symptoms.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue:
                      _selectedSeverity,
                      decoration: _inputDecoration(
                        label: 'Severity',
                        icon:
                        Icons.speed_outlined,
                      ),
                      items: _severityLevels
                          .map(
                            (severity) =>
                            DropdownMenuItem(
                              value: severity,
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration:
                                    BoxDecoration(
                                      color:
                                      _severityColor(
                                        severity,
                                      ),
                                      shape:
                                      BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(severity),
                                ],
                              ),
                            ),
                      )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedSeverity =
                              value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    _buildDateTile(
                      title: 'Date Detected',
                      value:
                      _formatDate(_detectionDate),
                      icon:
                      Icons.calendar_today_outlined,
                      onTap: _selectDetectionDate,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _buildSection(
                title: 'Treatment & Monitoring',
                icon: Icons.medical_services_outlined,
                child: Column(
                  children: [
                    TextFormField(
                      controller:
                      _treatmentController,
                      maxLines: 3,
                      textCapitalization:
                      TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        label:
                        'Treatment / Action Taken',
                        hint:
                        'e.g. Removed affected leaves or applied treatment...',
                        icon:
                        Icons.healing_outlined,
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _buildDateTile(
                      title: 'Treatment Date',
                      value: _treatmentDate == null
                          ? 'Not recorded'
                          : _formatDate(
                        _treatmentDate!,
                      ),
                      icon:
                      Icons.event_available_outlined,
                      onTap: _selectTreatmentDate,
                      trailing: _treatmentDate == null
                          ? null
                          : IconButton(
                        tooltip:
                        'Remove treatment date',
                        onPressed: () {
                          setState(() {
                            _treatmentDate =
                            null;
                          });
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue:
                      _selectedStatus,
                      decoration: _inputDecoration(
                        label: 'Record Status',
                        icon:
                        Icons.fact_check_outlined,
                      ),
                      items: _statuses
                          .map(
                            (status) =>
                            DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                      )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _buildSection(
                title: 'Additional Notes',
                icon: Icons.notes_outlined,
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  textCapitalization:
                  TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    label: 'Notes',
                    hint:
                    'Add follow-up notes, recommendations or observations...',
                    icon:
                    Icons.edit_note_outlined,
                    alignLabelWithHint: true,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B5E20),
            Color(0xFF2E7D32),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.pest_control_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Crop Health Record',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Record pests, diseases, symptoms, '
                      'treatments and photo evidence.',
                  style: TextStyle(
                    color: Colors.white70,
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

  Widget _buildPhotoSection() {
    final String? path = _photoPath;

    return _buildSection(
      title: 'Photo Evidence',
      icon: Icons.camera_alt_outlined,
      child: Column(
        children: [
          if (path == null)
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _showPhotoSourceOptions,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius:
                  BorderRadius.circular(18),
                  border: Border.all(
                    color: _primaryGreen.withValues(
                      alpha: 0.18,
                    ),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 42,
                      color: _primaryGreen,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Add Photo of the Problem',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _darkText,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Take a photo or choose one '
                          'from your gallery.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(18),
                  child: Image.file(
                    File(path),
                    width: double.infinity,
                    height: 230,
                    fit: BoxFit.cover,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Container(
                        height: 230,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            Icon(
                              Icons
                                  .broken_image_outlined,
                              size: 42,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Unable to preview photo',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                        _showPhotoSourceOptions,
                        icon: const Icon(
                          Icons
                              .photo_camera_outlined,
                        ),
                        label: const Text(
                          'Replace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _removePhoto,
                        icon: const Icon(
                          Icons.delete_outline,
                        ),
                        label: const Text(
                          'Remove',
                        ),
                        style:
                        OutlinedButton.styleFrom(
                          foregroundColor:
                          Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 17,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Photo evidence can help you monitor '
                      'how the pest or disease changes over time.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSelector() {
    if (_isLoadingFields) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Loading farm fields...',
            ),
          ],
        ),
      );
    }

    final fieldNames = <String>[
      'Not linked to a field',
      ..._farmFields
          .map((field) => field.name)
          .where(
            (name) => name.trim().isNotEmpty,
      ),
    ].toSet().toList();

    if (!fieldNames.contains(_selectedFieldName)) {
      _selectedFieldName =
      'Not linked to a field';
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedFieldName,
      isExpanded: true,
      decoration: _inputDecoration(
        label: 'Farm Field',
        icon: Icons.landscape_outlined,
      ),
      items: fieldNames
          .map(
            (fieldName) => DropdownMenuItem(
          value: fieldName,
          child: Text(
            fieldName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _selectedFieldName = value;
        });
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius:
                  BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: _primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _darkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: alignLabelWithHint,
      prefixIcon: Icon(
        icon,
        color: _primaryGreen,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAF8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _primaryGreen,
          width: 1.7,
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: const Color(0xFFF8FAF8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: _primaryGreen,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 56,
      child: FilledButton.icon(
        onPressed:
        _isSaving ? null : _saveRecord,
        style: FilledButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: _isSaving
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.3,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.save_outlined,
        ),
        label: Text(
          _isSaving
              ? 'Saving Record...'
              : 'Save Pest & Disease Record',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Color _severityColor(
      String severity,
      ) {
    switch (severity) {
      case 'Moderate':
        return Colors.orange;
      case 'High':
        return Colors.deepOrange;
      case 'Critical':
        return Colors.red;
      case 'Low':
      default:
        return Colors.green;
    }
  }
}