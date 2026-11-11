
import 'package:flutter/material.dart';

import '../../models/tractor.dart';
import 'add_tractor_screen.dart';
import 'edit_tractor_screen.dart';
import 'tractor_details_screen.dart';

class TractorScreen extends StatefulWidget {
  const TractorScreen({super.key});

  @override
  State<TractorScreen> createState() => _TractorScreenState();
}

class _TractorScreenState extends State<TractorScreen> {
  static const Color farmGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF4F7F4);
  static const Color darkText = Color(0xFF17201A);
  static const Color mutedText = Color(0xFF66736A);

  final List<Tractor> tractors = [
    Tractor(
      name: 'Main Ploughing Tractor',
      brand: 'Massey Ferguson',
      model: 'MF 265',
      registrationNumber: 'TR-001',
      year: 1985,
      engineHours: 4520,
      fuelType: 'Diesel',
      condition: 'Good',
      status: 'Operational',
      location: 'Main Shed',
      lastServiceDate: DateTime(2026, 8, 15),
      nextServiceDate: DateTime(2026, 11, 15),
      notes: 'Used mainly for ploughing and general farm work.',
    ),
    Tractor(
      name: 'Utility Tractor',
      brand: 'Massey Ferguson',
      model: 'MF 165',
      registrationNumber: 'TR-002',
      year: 1978,
      engineHours: 6180,
      fuelType: 'Diesel',
      condition: 'Fair',
      status: 'Operational',
      location: 'Machinery Shed',
      lastServiceDate: DateTime(2026, 7, 10),
      nextServiceDate: DateTime(2026, 10, 10),
      notes: 'Used for lighter farm operations.',
    ),
  ];

  final List<Map<String, String>> managementRecords = [];

  int get totalTractors => tractors.length;

  int get operationalTractors => tractors
      .where((tractor) => tractor.status == 'Operational')
      .length;

  int get serviceAlerts =>
      tractors.where((tractor) => tractor.needsService).length;

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      floatingLabelStyle: const TextStyle(color: farmGreen),
      filled: true,
      fillColor: Colors.white,
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
        borderSide: const BorderSide(color: farmGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: farmGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openAddTractorScreen() async {
    final newTractor = await Navigator.push<Tractor>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTractorScreen(),
      ),
    );

    if (!mounted || newTractor == null) return;

    setState(() => tractors.add(newTractor));
    _showMessage('${newTractor.displayName} added successfully.');
  }

  void _openTractorDetails(Tractor tractor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TractorDetailsScreen(tractor: tractor),
      ),
    );
  }

  Future<void> _openEditTractorScreen(int index) async {
    final updatedTractor = await Navigator.push<Tractor>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTractorScreen(
          tractor: tractors[index],
        ),
      ),
    );

    if (!mounted || updatedTractor == null) return;

    setState(() => tractors[index] = updatedTractor);
    _showMessage('${updatedTractor.displayName} updated successfully.');
  }

  void _deleteTractor(int index) {
    final removed = tractors[index];

    setState(() => tractors.removeAt(index));
    _showMessage('${removed.displayName} deleted.');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not scheduled';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _openManagementFeature(String feature) async {
    if (tractors.isEmpty) {
      _showMessage('Please add a tractor first.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    final detailsController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    String selectedTractor = tractors.first.registrationNumber;

    String selectedStatus =
    feature == 'Maintenance' || feature == 'Service History'
        ? 'Completed'
        : feature == 'Implements & Equipment'
        ? 'Good'
        : 'Normal';

    DateTime selectedDate = DateTime.now();

    final isEquipment = feature == 'Implements & Equipment';
    final isHours = feature == 'Engine Hours';
    final isFuel = feature == 'Fuel Records';
    final isMaintenance = feature == 'Maintenance';
    final isService = feature == 'Service History';

    late final String detailsLabel;
    late final String amountLabel;

    if (isEquipment) {
      detailsLabel = 'Equipment name (e.g. Plough)';
      amountLabel = 'Equipment type (e.g. Mounted)';
    } else if (isHours) {
      detailsLabel = 'Current engine-hour reading';
      amountLabel = 'Hours since previous reading (optional)';
    } else if (isFuel) {
      detailsLabel = 'Fuel quantity in litres';
      amountLabel = 'Total fuel cost (R)';
    } else if (isMaintenance) {
      detailsLabel = 'Maintenance or repair performed';
      amountLabel = 'Cost (R), if applicable';
    } else {
      detailsLabel = 'Service performed';
      amountLabel = 'Service cost (R), if applicable';
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                feature,
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
                          initialValue: selectedTractor,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black),
                          decoration: _inputDecoration('Select tractor'),
                          items: tractors.map((tractor) {
                            return DropdownMenuItem<String>(
                              value: tractor.registrationNumber,
                              child: Text(
                                '${tractor.displayName} '
                                    '(${tractor.registrationNumber})',
                                style: const TextStyle(color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(
                                    () => selectedTractor = value,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: detailsController,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: farmGreen,
                          keyboardType: isFuel || isHours
                              ? const TextInputType.numberWithOptions(
                            decimal: true,
                          )
                              : TextInputType.text,
                          decoration: _inputDecoration(detailsLabel),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'This field is required.';
                            }

                            if (isFuel || isHours) {
                              final number = double.tryParse(value.trim());

                              if (number == null || number < 0) {
                                return 'Enter a valid non-negative number.';
                              }
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: amountController,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: farmGreen,
                          keyboardType: isFuel ||
                              isMaintenance ||
                              isService ||
                              isHours
                              ? const TextInputType.numberWithOptions(
                            decimal: true,
                          )
                              : TextInputType.text,
                          decoration: _inputDecoration(amountLabel),
                          validator: (value) {
                            if (isFuel &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Please enter the fuel cost.';
                            }

                            if ((isFuel ||
                                isMaintenance ||
                                isService ||
                                isHours) &&
                                value != null &&
                                value.trim().isNotEmpty) {
                              final number = double.tryParse(value.trim());

                              if (number == null || number < 0) {
                                return 'Enter a valid non-negative number.';
                              }
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        if (isMaintenance || isService || isEquipment) ...[
                          DropdownButtonFormField<String>(
                            initialValue: selectedStatus,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Colors.black),
                            decoration: _inputDecoration(
                              isEquipment ? 'Equipment condition' : 'Status',
                            ),
                            items: (isEquipment
                                ? [
                              'Good',
                              'Fair',
                              'Poor',
                              'Needs Repair',
                            ]
                                : [
                              'Completed',
                              'Pending',
                              'In Progress',
                            ])
                                .map(
                                  (status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(
                                      () => selectedStatus = value,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: notesController,
                          style: const TextStyle(color: Colors.black),
                          cursorColor: farmGreen,
                          decoration: _inputDecoration('Notes (optional)'),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.calendar_month,
                              color: farmGreen,
                            ),
                            title: const Text(
                              'Record date',
                              style: TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(
                              _formatDate(selectedDate),
                              style: const TextStyle(color: Colors.black),
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: dialogContext,
                                initialDate: selectedDate,
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
                  onPressed: () => Navigator.pop(dialogContext),
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

                    final selected = tractors.firstWhere(
                          (tractor) =>
                      tractor.registrationNumber == selectedTractor,
                    );

                    Navigator.pop(dialogContext, {
                      'feature': feature,
                      'tractor': selected.displayName,
                      'registration': selected.registrationNumber,
                      'details': detailsController.text.trim(),
                      'amount': amountController.text.trim(),
                      'status': selectedStatus,
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
      managementRecords.insert(0, result);

      if (feature == 'Engine Hours') {
        final index = tractors.indexWhere(
              (tractor) =>
          tractor.registrationNumber == result['registration'],
        );

        if (index != -1) {
          final reading = double.tryParse(result['details'] ?? '');

          if (reading != null && reading >= 0) {
            final updated = tractors[index];

            tractors[index] = Tractor(
              name: updated.name,
              brand: updated.brand,
              model: updated.model,
              registrationNumber: updated.registrationNumber,
              year: updated.year,
              engineHours: reading,
              fuelType: updated.fuelType,
              condition: updated.condition,
              status: updated.status,
              location: updated.location,
              lastServiceDate: updated.lastServiceDate,
              nextServiceDate: updated.nextServiceDate,
              notes: updated.notes,
            );
          }
        }
      }
    });

    _showMessage('$feature record saved successfully.');
  }

  Widget _buildManagementHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        const Text(
          'Management Records',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        if (managementRecords.isEmpty)
          const Text(
            'Saved maintenance, service, fuel, engine-hour and equipment '
                'records will appear here.',
            style: TextStyle(color: Colors.black54),
          )
        else
          ...managementRecords.map((record) {
            final notes = record['notes'] ?? '';
            final amount = record['amount'] ?? '';
            final status = record['status'] ?? '';

            final details = StringBuffer()
              ..writeln('Tractor: ${record['tractor']}')
              ..writeln('Registration: ${record['registration']}')
              ..writeln('Details: ${record['details']}');

            if (amount.isNotEmpty) {
              details.writeln('Amount / Type: $amount');
            }

            if (status.isNotEmpty && status != 'Normal') {
              details.writeln('Status: $status');
            }

            details.write('Date: ${record['date']}');

            if (notes.isNotEmpty) {
              details.write('\nNotes: $notes');
            }

            return Card(
              color: Colors.white,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: lightGreen,
                  child: Icon(Icons.agriculture, color: farmGreen),
                ),
                title: Text(
                  record['feature'] ?? 'Record',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  details.toString(),
                  style: const TextStyle(
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                isThreeLine: true,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildOverviewCard() {
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
          const Row(
            children: [
              Icon(Icons.agriculture_rounded, color: Colors.white),
              SizedBox(width: 9),
              Text(
                'Machinery Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _OverviewItem(
                  value: totalTractors.toString(),
                  label: 'Tractors',
                ),
              ),
              const _OverviewDivider(),
              Expanded(
                child: _OverviewItem(
                  value: operationalTractors.toString(),
                  label: 'Operational',
                ),
              ),
              const _OverviewDivider(),
              Expanded(
                child: _OverviewItem(
                  value: serviceAlerts.toString(),
                  label: 'Service Alerts',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTractorCard(Tractor tractor, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _openTractorDetails(tractor),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: tractor.needsService
                ? const Color(0xFFFFCC80)
                : const Color(0xFFE3E9E4),
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.agriculture_rounded,
                    size: 31,
                    color: farmGreen,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tractor.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tractor.fullModelName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: mutedText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tractor.year} • ${tractor.registrationNumber}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (value) {
                    if (value == 'details') {
                      _openTractorDetails(tractor);
                    } else if (value == 'edit') {
                      _openEditTractorScreen(index);
                    } else if (value == 'delete') {
                      _deleteTractor(index);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'details',
                      child: Text(
                        'View Details',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Edit Tractor',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInformation(
                    'Engine Hours',
                    tractor.engineHoursText,
                  ),
                ),
                Expanded(
                  child: _buildInformation('Condition', tractor.condition),
                ),
                Expanded(
                  child: _buildInformation('Fuel', tractor.fuelType),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildStatusChip(tractor.status),
                const Spacer(),
                const Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: mutedText,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    tractor.location,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: mutedText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tractor.needsService
                    ? const Color(0xFFFFF8E1)
                    : const Color(0xFFF7F9F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    tractor.needsService
                        ? Icons.warning_amber_rounded
                        : Icons.event_available_outlined,
                    size: 19,
                    color: tractor.needsService
                        ? const Color(0xFFF57F17)
                        : farmGreen,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tractor.needsService
                              ? 'Service Attention'
                              : 'Next Service',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: tractor.needsService
                                ? const Color(0xFFF57F17)
                                : mutedText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(tractor.nextServiceDate),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformation(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: mutedText),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color background;
    Color foreground;

    if (status == 'Operational') {
      background = lightGreen;
      foreground = farmGreen;
    } else if (status == 'In Use') {
      background = const Color(0xFFE3F2FD);
      foreground = const Color(0xFF1565C0);
    } else if (status == 'Under Maintenance') {
      background = const Color(0xFFFFF8E1);
      foreground = const Color(0xFFF57F17);
    } else {
      background = const Color(0xFFFFEBEE);
      foreground = const Color(0xFFC62828);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE3E9E4)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: farmGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: mutedText,
            ),
          ],
        ),
      ),
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
            Icons.agriculture_outlined,
            size: 55,
            color: farmGreen,
          ),
          const SizedBox(height: 15),
          const Text(
            'No tractors registered',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first tractor to start tracking machinery.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: farmGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: _openAddTractorScreen,
            child: const Text('Add Tractor'),
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
              'Tractor Management',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: darkText,
              ),
            ),
            Text(
              'Manage tractors and farm machinery',
              style: TextStyle(fontSize: 12, color: mutedText),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Tractors',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                TextButton.icon(
                  onPressed: _openAddTractorScreen,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Tractor'),
                  style: TextButton.styleFrom(
                    foregroundColor: farmGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (tractors.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tractors.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 14),
                itemBuilder: (context, index) =>
                    _buildTractorCard(tractors[index], index),
              ),
            const SizedBox(height: 30),
            const Text(
              'Machinery Management',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: darkText,
              ),
            ),
            const SizedBox(height: 15),
            _buildManagementCard(
              icon: Icons.build_outlined,
              title: 'Maintenance',
              subtitle: 'Repairs, inspections and maintenance records',
              onTap: () => _openManagementFeature('Maintenance'),
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              icon: Icons.history_rounded,
              title: 'Service History',
              subtitle: 'Track previous and upcoming services',
              onTap: () => _openManagementFeature('Service History'),
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              icon: Icons.local_gas_station_outlined,
              title: 'Fuel Records',
              subtitle: 'Monitor tractor fuel usage and costs',
              onTap: () => _openManagementFeature('Fuel Records'),
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              icon: Icons.timer_outlined,
              title: 'Engine Hours',
              subtitle: 'Track machinery operating hours',
              onTap: () => _openManagementFeature('Engine Hours'),
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              icon: Icons.handyman_outlined,
              title: 'Implements & Equipment',
              subtitle: 'Manage ploughs, planters and other implements',
              onTap: () =>
                  _openManagementFeature('Implements & Equipment'),
            ),
            _buildManagementHistory(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTractorScreen,
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Tractor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final String value;
  final String label;

  const _OverviewItem({
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
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _OverviewDivider extends StatelessWidget {
  const _OverviewDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: Colors.white24,
    );
  }
}
