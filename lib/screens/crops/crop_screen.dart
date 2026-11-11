
import 'package:flutter/material.dart';

import '../../models/crop.dart';
import 'add_crop_screen.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  static const Color farmGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF4F7F4);
  static const Color darkText = Color(0xFF17201A);
  static const Color mutedText = Color(0xFF66736A);

  final List<Crop> crops = [
    Crop(
      cropName: 'Cabbage',
      variety: 'Green Cabbage',
      field: 'Field A',
      area: 0.8,
      plantingDate: DateTime(2026, 9, 15),
      harvestDate: DateTime(2026, 11, 26),
      notes: 'Monitor irrigation and fertiliser application.',
    ),
    Crop(
      cropName: 'Spinach',
      variety: 'Fordhook Giant',
      field: 'Field B',
      area: 0.5,
      plantingDate: DateTime(2026, 9, 5),
      harvestDate: DateTime(2026, 10, 22),
      notes: 'Harvest leaves regularly when mature.',
    ),
    Crop(
      cropName: 'Onion',
      variety: 'Brown Onion',
      field: 'Field C',
      area: 0.5,
      plantingDate: DateTime(2026, 9, 20),
      harvestDate: DateTime(2026, 12, 16),
      notes: 'Keep field weed free.',
    ),
  ];

  final List<Map<String, String>> actionRecords = [];

  // White textboxes, black text and green focus borders.
  InputDecoration _whiteInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      floatingLabelStyle: const TextStyle(color: farmGreen),
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.grey),
      errorStyle: const TextStyle(color: Colors.red),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: farmGreen,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

  Future<void> _openAddCropScreen() async {
    final Crop? newCrop = await Navigator.push<Crop>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCropScreen(),
      ),
    );

    if (!mounted || newCrop == null) return;

    setState(() {
      crops.add(newCrop);
    });

    _showMessage('${newCrop.cropName} added to My Crops.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: farmGreen,
      ),
    );
  }

  void _deleteCrop(int index) {
    final deletedCrop = crops[index];

    setState(() {
      crops.removeAt(index);
    });

    _showMessage('${deletedCrop.cropName} removed.');
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  double _calculateProgress(Crop crop) {
    final totalDays =
        crop.harvestDate.difference(crop.plantingDate).inDays;

    if (totalDays <= 0) return 1;

    final elapsedDays =
        DateTime.now().difference(crop.plantingDate).inDays;

    if (elapsedDays <= 0) return 0;

    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }

  double get totalArea =>
      crops.fold<double>(0, (total, crop) => total + crop.area);

  int get totalFields => crops
      .map((crop) => crop.field.toLowerCase())
      .toSet()
      .length;

  Future<void> _openQuickAction(String action) async {
    if (crops.isEmpty) {
      _showMessage('Please add a crop before creating a record.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    final detailsController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    String selectedCrop = crops.first.cropName;
    String extraValue = '';
    DateTime selectedDate = DateTime.now();

    String detailsLabel;
    String extraLabel;
    String notesLabel;

    switch (action) {
      case 'Irrigation':
        detailsLabel = 'Watering method';
        extraLabel = 'Water amount (e.g. 20 litres)';
        notesLabel = 'Additional notes';
        break;
      case 'Pest Report':
        detailsLabel = 'Pest observed and symptoms';
        extraLabel = 'Pest severity';
        notesLabel = 'Treatment or action taken';
        break;
      case 'Fertiliser':
        detailsLabel = 'Fertiliser type';
        extraLabel = 'Amount applied (e.g. 5 kg)';
        notesLabel = 'Application notes';
        break;
      default:
        detailsLabel = 'Activity description';
        extraLabel = 'Priority';
        notesLabel = 'Additional notes';
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                action,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedCrop,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black),
                          decoration: _whiteInputDecoration(
                            'Select crop',
                          ),
                          items: crops.map((crop) {
                            return DropdownMenuItem<String>(
                              value: crop.cropName,
                              child: Text(
                                '${crop.cropName} - ${crop.field}',
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedCrop = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: detailsController,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          cursorColor: farmGreen,
                          decoration: _whiteInputDecoration(
                            detailsLabel,
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter $detailsLabel.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        if (action == 'Pest Report') ...[
                          DropdownButtonFormField<String>(
                            value: extraValue.isEmpty
                                ? null
                                : extraValue,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: _whiteInputDecoration(
                              'Pest severity',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Low',
                                child: Text(
                                  'Low',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Medium',
                                child: Text(
                                  'Medium',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'High',
                                child: Text(
                                  'High',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                            validator: (value) {
                              if (value == null) {
                                return 'Please select severity.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setDialogState(() {
                                extraValue = value ?? '';
                              });
                            },
                          ),
                        ] else if (action == 'Schedule') ...[
                          DropdownButtonFormField<String>(
                            value: extraValue.isEmpty
                                ? 'Normal'
                                : extraValue,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            decoration: _whiteInputDecoration(
                              'Priority',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Low',
                                child: Text(
                                  'Low',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Normal',
                                child: Text(
                                  'Normal',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'High',
                                child: Text(
                                  'High',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                extraValue = value ?? 'Normal';
                              });
                            },
                          ),
                        ] else ...[
                          TextFormField(
                            controller: amountController,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            cursorColor: farmGreen,
                            decoration: _whiteInputDecoration(
                              extraLabel,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter $extraLabel.';
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: notesController,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          cursorColor: farmGreen,
                          decoration: _whiteInputDecoration(
                            notesLabel,
                          ),
                          maxLines: 3,
                        ),

                        const SizedBox(height: 14),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.calendar_month,
                              color: farmGreen,
                            ),
                            title: const Text(
                              'Activity date',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              _formatDate(selectedDate),
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: dialogContext,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme:
                                      const ColorScheme.light(
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

                              if (picked != null) {
                                setDialogState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    if (!formKey.currentState!.validate()) return;

                    Navigator.pop(dialogContext, {
                      'action': action,
                      'crop': selectedCrop,
                      'details': detailsController.text.trim(),
                      'extra': action == 'Pest Report' ||
                          action == 'Schedule'
                          ? (extraValue.isEmpty
                          ? 'Normal'
                          : extraValue)
                          : amountController.text.trim(),
                      'notes': notesController.text.trim(),
                      'date': _formatDate(selectedDate),
                    });
                  },
                  child: const Text('Save Record'),
                ),
              ],
            );
          },
        );
      },
    );

    detailsController.dispose();
    amountController.dispose();
    notesController.dispose();

    if (!mounted || result == null) return;

    setState(() {
      actionRecords.insert(0, result);
    });

    _showMessage('$action record saved successfully.');
  }

  Widget _buildSummaryCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crop Overview',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  value: crops.length.toString(),
                  label: 'Active Crops',
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _SummaryItem(
                  value: totalFields.toString(),
                  label: 'Fields',
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _SummaryItem(
                  value: '${totalArea.toStringAsFixed(1)} ha',
                  label: 'Planted',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(Crop crop, int index) {
    final progress = _calculateProgress(crop);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: farmGreen,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.cropName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${crop.variety} • ${crop.field}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: Colors.white,
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteCrop(index);
                  }
                  if (value == 'view') {
                    _showCropDetails(crop);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'view',
                    child: Text(
                      'View Details',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete Crop',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Planted: ${_formatDate(crop.plantingDate)}',
            style: const TextStyle(
              fontSize: 12,
              color: mutedText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Area: ${crop.areaText}',
            style: const TextStyle(
              fontSize: 12,
              color: mutedText,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Growth Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: farmGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: lightGreen,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF43A047),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            crop.daysUntilHarvest == 0
                ? 'Ready for harvest'
                : '${crop.daysUntilHarvest} days until expected harvest',
            style: const TextStyle(
              fontSize: 11,
              color: mutedText,
            ),
          ),
        ],
      ),
    );
  }

  void _showCropDetails(Crop crop) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          crop.cropName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Variety: ${crop.variety}\n'
              'Field: ${crop.field}\n'
              'Area: ${crop.areaText}\n'
              'Planting date: ${_formatDate(crop.plantingDate)}\n'
              'Expected harvest: ${_formatDate(crop.harvestDate)}\n'
              'Notes: ${crop.notes}',
          style: const TextStyle(
            color: Colors.black,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Close',
              style: TextStyle(color: farmGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openQuickAction(title),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE3E9E4),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: farmGreen, size: 27),
            const SizedBox(height: 9),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text(
          'Recent Activity Records',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        if (actionRecords.isEmpty)
          const Text(
            'Your irrigation, pest, fertiliser and schedule records '
                'will appear here.',
            style: TextStyle(color: Colors.black54),
          )
        else
          ...actionRecords.map(
                (record) => Card(
              color: Colors.white,
              elevation: 1,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: lightGreen,
                  child: Icon(
                    Icons.check_circle,
                    color: farmGreen,
                  ),
                ),
                title: Text(
                  record['action'] ?? '',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${record['crop']} • ${record['date']}\n'
                      '${record['details']}\n'
                      '${record['action'] == 'Pest Report' ? 'Severity' : record['action'] == 'Schedule' ? 'Priority' : record['action'] == 'Irrigation' ? 'Water amount' : 'Amount applied'}: ${record['extra']}\n'
                      '${(record['notes'] ?? '').isNotEmpty ? record['notes'] : 'No additional notes.'}',
                  style: const TextStyle(
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                isThreeLine: true,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.eco_outlined,
            size: 55,
            color: farmGreen,
          ),
          const SizedBox(height: 15),
          const Text(
            'No Crops Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first crop to start monitoring production.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: farmGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: _openAddCropScreen,
            child: const Text('Add Crop'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crop Management',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: darkText,
              ),
            ),
            Text(
              'Manage your farm crops',
              style: TextStyle(
                fontSize: 12,
                color: mutedText,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Crops',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: farmGreen,
                  ),
                  onPressed: _openAddCropScreen,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Crop'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (crops.isEmpty)
              _buildEmptyState()
            else
              ...List.generate(
                crops.length,
                    (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildCropCard(crops[index], index),
                ),
              ),
            const SizedBox(height: 25),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: darkText,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.water_drop_outlined,
                    title: 'Irrigation',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.bug_report_outlined,
                    title: 'Pest Report',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.science_outlined,
                    title: 'Fertiliser',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.calendar_month_outlined,
                    title: 'Schedule',
                  ),
                ),
              ],
            ),
            _buildActionHistory(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCropScreen,
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Crop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 1,
      color: Colors.white24,
    );
  }
}
