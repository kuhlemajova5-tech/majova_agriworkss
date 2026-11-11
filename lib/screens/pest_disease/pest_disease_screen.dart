import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/pest_disease_record.dart';
import '../../services/database_service.dart';
import '../../services/photo_storage_service.dart';
import 'add_pest_disease_record_screen.dart';
import 'edit_pest_disease_record_screen.dart';

class PestDiseaseScreen extends StatefulWidget {
  const PestDiseaseScreen({super.key});

  @override
  State<PestDiseaseScreen> createState() => _PestDiseaseScreenState();
}

class _PestDiseaseScreenState extends State<PestDiseaseScreen> {
  static const Color _primaryGreen = Color(0xFF1B5E20);
  static const Color _lightGreen = Color(0xFFE8F5E9);
  static const Color _darkText = Color(0xFF1D2A22);

  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = const [
    'All',
    'Pests',
    'Diseases',
    'Active',
    'Resolved',
  ];

  List<PestDiseaseRecord> _records = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final records =
      await DatabaseService.instance.getPestDiseaseRecords();

      if (!mounted) {
        return;
      }

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Could not load pest and disease records.',
        isError: true,
      );
    }
  }

  List<PestDiseaseRecord> get _filteredRecords {
    return _records.where((record) {
      final bool matchesFilter;

      switch (_selectedFilter) {
        case 'Pests':
          matchesFilter = record.recordType == 'Pest';
          break;
        case 'Diseases':
          matchesFilter = record.recordType == 'Disease';
          break;
        case 'Active':
          matchesFilter = record.status != 'Resolved';
          break;
        case 'Resolved':
          matchesFilter = record.status == 'Resolved';
          break;
        case 'All':
        default:
          matchesFilter = true;
      }

      if (!matchesFilter) {
        return false;
      }

      final query = _searchQuery.trim().toLowerCase();

      if (query.isEmpty) {
        return true;
      }

      return record.problemName.toLowerCase().contains(query) ||
          record.crop.toLowerCase().contains(query) ||
          record.fieldName.toLowerCase().contains(query) ||
          record.recordType.toLowerCase().contains(query) ||
          record.status.toLowerCase().contains(query) ||
          record.severity.toLowerCase().contains(query);
    }).toList();
  }

  int get _activeCount {
    return _records
        .where((record) => record.status != 'Resolved')
        .length;
  }

  int get _criticalCount {
    return _records
        .where(
          (record) =>
      record.severity == 'Critical' &&
          record.status != 'Resolved',
    )
        .length;
  }

  Future<void> _openAddRecord() async {
    final bool? added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddPestDiseaseRecordScreen(),
      ),
    );

    if (added == true) {
      await _loadRecords();
    }
  }

  Future<void> _openEditRecord(
      PestDiseaseRecord record,
      ) async {
    final bool? updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPestDiseaseRecordScreen(
          record: record,
        ),
      ),
    );

    if (updated == true) {
      await _loadRecords();

      if (!mounted) {
        return;
      }

      _showMessage('Record updated successfully.');
    }
  }

  Future<void> _deleteRecord(
      PestDiseaseRecord record,
      ) async {
    if (record.id == null) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Record?'),
          content: Text(
            'Delete the ${record.recordType.toLowerCase()} '
                'record "${record.problemName}"? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await DatabaseService.instance.deletePestDiseaseRecord(
        record.id!,
      );

      try {
        await PhotoStorageService.instance.deletePhoto(
          record.photoPath,
        );
      } catch (_) {
        // The database record has already been removed.
      }

      if (!mounted) {
        return;
      }

      await _loadRecords();

      if (!mounted) {
        return;
      }

      _showMessage('Record deleted.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not delete the record.',
        isError: true,
      );
    }
  }

  void _openDetails(
      PestDiseaseRecord record,
      ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                30,
              ),
              children: [
                _buildDetailsHeader(record),
                const SizedBox(height: 18),
                if (record.hasPhoto) ...[
                  _buildDetailsPhoto(record),
                  const SizedBox(height: 18),
                ],
                _buildDetailsSection(
                  title: 'Problem Information',
                  icon: Icons.bug_report_outlined,
                  children: [
                    _detailRow(
                      'Type',
                      record.recordType,
                    ),
                    _detailRow(
                      'Problem',
                      record.problemName,
                    ),
                    _detailRow(
                      'Crop',
                      record.crop,
                    ),
                    _detailRow(
                      'Field',
                      record.fieldName,
                    ),
                    _detailRow(
                      'Severity',
                      record.severity,
                    ),
                    _detailRow(
                      'Status',
                      record.status,
                    ),
                    _detailRow(
                      'Detected',
                      _formatDate(record.detectionDate),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildDetailsSection(
                  title: 'Symptoms',
                  icon: Icons.visibility_outlined,
                  children: [
                    Text(
                      record.symptoms.trim().isEmpty
                          ? 'No symptoms recorded.'
                          : record.symptoms,
                      style: const TextStyle(
                        height: 1.5,
                        color: _darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildDetailsSection(
                  title: 'Treatment & Monitoring',
                  icon: Icons.medical_services_outlined,
                  children: [
                    _detailRow(
                      'Treatment',
                      record.treatment.trim().isEmpty
                          ? 'Not recorded'
                          : record.treatment,
                    ),
                    _detailRow(
                      'Treatment Date',
                      record.treatmentDate == null
                          ? 'Not recorded'
                          : _formatDate(record.treatmentDate!),
                    ),
                  ],
                ),
                if (record.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildDetailsSection(
                    title: 'Notes',
                    icon: Icons.notes_outlined,
                    children: [
                      Text(
                        record.notes,
                        style: const TextStyle(
                          height: 1.5,
                          color: _darkText,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await _openEditRecord(record);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text(
                    'Edit Record',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(
                      color: Colors.red.shade200,
                    ),
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await _deleteRecord(record);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(
                    'Delete Record',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: const Text(
          'Pest & Disease Records',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _darkText,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadRecords,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddRecord,
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Record',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecords,
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: _primaryGreen,
          ),
        )
            : ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            110,
          ),
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildSummary(),
            const SizedBox(height: 18),
            _buildSearch(),
            const SizedBox(height: 14),
            _buildFilters(),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Crop Health Records',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: _darkText,
                    ),
                  ),
                ),
                Text(
                  '${records.length} shown',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (records.isEmpty)
              _buildEmptyState()
            else
              ...records.map(
                    (record) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: _buildRecordCard(record),
                ),
              ),
          ],
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
            radius: 29,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.health_and_safety_outlined,
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
                  'Crop Health Centre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Monitor pests, diseases, treatment and recovery.',
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

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: 'Total',
            value: '${_records.length}',
            icon: Icons.folder_copy_outlined,
            color: _primaryGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            title: 'Active',
            value: '$_activeCount',
            icon: Icons.warning_amber_rounded,
            color: Colors.orange.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            title: 'Critical',
            value: '$_criticalCount',
            icon: Icons.crisis_alert_outlined,
            color: Colors.red.shade700,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search problem, crop or field...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _primaryGreen,
        ),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
          onPressed: () {
            _searchController.clear();
            setState(() {
              _searchQuery = '';
            });
          },
          icon: const Icon(Icons.close_rounded),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _primaryGreen,
            width: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = filter == _selectedFilter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            selectedColor: _lightGreen,
            labelStyle: TextStyle(
              color: selected
                  ? _primaryGreen
                  : Colors.grey.shade800,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(
              color: selected
                  ? _primaryGreen.withValues(alpha: 0.35)
                  : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(
      PestDiseaseRecord record,
      ) {
    final severityColor = _severityColor(record.severity);
    final statusColor = _statusColor(record.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _openDetails(record),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(record),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.problemName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: _darkText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${record.recordType} • ${record.crop}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.landscape_outlined,
                          size: 15,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            record.fieldName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _badge(
                          record.severity,
                          severityColor,
                        ),
                        _badge(
                          record.status,
                          statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'Detected ${_formatDate(record.detectionDate)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(
      PestDiseaseRecord record,
      ) {
    final path = record.photoPath;

    if (path != null && path.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.file(
          File(path),
          width: 88,
          height: 105,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _photoPlaceholder();
          },
        ),
      );
    }

    return _photoPlaceholder();
  }

  Widget _photoPlaceholder() {
    return Container(
      width: 88,
      height: 105,
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.pest_control_outlined,
        color: _primaryGreen,
        size: 34,
      ),
    );
  }

  Widget _badge(
      String text,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool hasSearchOrFilter =
        _searchQuery.trim().isNotEmpty ||
            _selectedFilter != 'All';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: _lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: _primaryGreen,
              size: 38,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            hasSearchOrFilter
                ? 'No matching records'
                : 'No pest or disease records yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchOrFilter
                ? 'Try another search or filter.'
                : 'Record crop health problems early so you can monitor treatment and recovery.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.45,
            ),
          ),
          if (!hasSearchOrFilter) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _openAddRecord,
              style: FilledButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add First Record'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsHeader(
      PestDiseaseRecord record,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _lightGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            record.recordType == 'Disease'
                ? Icons.coronavirus_outlined
                : Icons.pest_control_outlined,
            color: _primaryGreen,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.problemName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${record.recordType} • ${record.crop}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsPhoto(
      PestDiseaseRecord record,
      ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(
        File(record.photoPath!),
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            height: 190,
            alignment: Alignment.center,
            color: Colors.grey.shade200,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 42,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text('Photo is unavailable'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: _primaryGreen,
                size: 21,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _severityColor(
      String severity,
      ) {
    switch (severity) {
      case 'Moderate':
        return Colors.orange.shade700;
      case 'High':
        return Colors.deepOrange.shade700;
      case 'Critical':
        return Colors.red.shade700;
      case 'Low':
      default:
        return Colors.green.shade700;
    }
  }

  Color _statusColor(
      String status,
      ) {
    switch (status) {
      case 'Monitoring':
        return Colors.blue.shade700;
      case 'Treated':
        return Colors.purple.shade700;
      case 'Resolved':
        return Colors.green.shade700;
      case 'Active':
      default:
        return Colors.orange.shade800;
    }
  }

  String _formatDate(
      DateTime date,
      ) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
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
}

