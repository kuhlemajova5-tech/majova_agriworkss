

import 'package:flutter/material.dart';

import '../../models/farm_field.dart';
import '../../services/database_service.dart';
import 'add_farm_field_screen.dart';
import 'edit_farm_field_screen.dart';

class FarmFieldsScreen extends StatefulWidget {
const FarmFieldsScreen({super.key});

@override
State<FarmFieldsScreen> createState() => _FarmFieldsScreenState();
}

class _FarmFieldsScreenState extends State<FarmFieldsScreen> {
static const Color _primaryGreen = Color(0xFF1B5E20);
static const Color _darkGreen = Color(0xFF0B3D1B);
static const Color _mediumGreen = Color(0xFF43A047);
static const Color _background = Color(0xFFF4F7F4);
static const Color _textPrimary = Color(0xFF17201A);
static const Color _textSecondary = Color(0xFF66736A);

final DatabaseService _databaseService =
DatabaseService.instance;

List<FarmField> _fields = [];

bool _isLoading = true;
String _selectedFilter = 'All';

final List<String> _filters = [
'All',
'Planned',
'Planted',
'Growing',
'Ready',
'Harvested',
];

@override
void initState() {
super.initState();
_loadFields();
}

Future<void> _loadFields() async {
if (mounted) {
setState(() {
_isLoading = true;
});
}

try {
final fields =
await _databaseService.getFarmFields();

if (!mounted) return;

setState(() {
_fields = fields;
_isLoading = false;
});
} catch (error) {
if (!mounted) return;

setState(() {
_isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Could not load farm fields.',
),
behavior: SnackBarBehavior.floating,
),
);
}
}

List<FarmField> get _filteredFields {
if (_selectedFilter == 'All') {
return _fields;
}

return _fields
    .where(
(field) => field.status == _selectedFilter,
)
    .toList();
}

double get _totalHectares {
return _fields.fold(
0,
(total, field) =>
total + field.sizeHectares,
);
}

int get _activeFields {
return _fields.where((field) {
return field.status != 'Harvested';
}).length;
}

int get _readyFields {
return _fields.where((field) {
return field.status == 'Ready';
}).length;
}

Future<void> _openAddFieldScreen() async {
final fieldAdded = await Navigator.push<bool>(
context,
MaterialPageRoute(
builder: (context) => const AddFarmFieldScreen(),
),
);

if (!mounted) return;

if (fieldAdded == true) {
await _loadFields();
}
}

Future<void> _openEditFieldScreen(
FarmField field,
) async {
final fieldUpdated = await Navigator.push<bool>(
context,
MaterialPageRoute(
builder: (context) => EditFarmFieldScreen(
field: field,
),
),
);

if (!mounted) return;

if (fieldUpdated == true) {
await _loadFields();
}
}

Future<void> _openFieldDetails(
FarmField field,
) async {
await showModalBottomSheet<void>(
context: context,
isScrollControlled: true,
backgroundColor: Colors.transparent,
builder: (context) {
return _buildFieldDetailsSheet(field);
},
);
}

Future<void> _deleteField(
FarmField field,
) async {
if (field.id == null) return;

final shouldDelete = await showDialog<bool>(
context: context,
builder: (context) {
return AlertDialog(
title: const Text('Delete Field?'),
content: Text(
'Are you sure you want to delete '
'${field.name}?',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(context, false);
},
child: const Text('Cancel'),
),
FilledButton(
onPressed: () {
Navigator.pop(context, true);
},
style: FilledButton.styleFrom(
backgroundColor: Colors.red.shade700,
),
child: const Text('Delete'),
),
],
);
},
);

if (shouldDelete != true) return;

await _databaseService.deleteFarmField(
field.id!,
);

await _loadFields();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Farm field deleted successfully.',
),
behavior: SnackBarBehavior.floating,
),
);
}

String _formatDate(DateTime date) {
final day =
date.day.toString().padLeft(2, '0');

final month =
date.month.toString().padLeft(2, '0');

return '$day/$month/${date.year}';
}

Color _statusColor(String status) {
switch (status) {
case 'Planned':
return const Color(0xFF1565C0);

case 'Planted':
return const Color(0xFF6A1B9A);

case 'Growing':
return const Color(0xFF2E7D32);

case 'Ready':
return const Color(0xFFEF6C00);

case 'Harvested':
return const Color(0xFF5D4037);

default:
return _textSecondary;
}
}

Color _statusBackground(String status) {
switch (status) {
case 'Planned':
return const Color(0xFFE3F2FD);

case 'Planted':
return const Color(0xFFF3E5F5);

case 'Growing':
return const Color(0xFFE8F5E9);

case 'Ready':
return const Color(0xFFFFF3E0);

case 'Harvested':
return const Color(0xFFEFEBE9);

default:
return const Color(0xFFF1F3F1);
}
}

IconData _cropIcon(String crop) {
switch (crop.toLowerCase()) {
case 'cabbage':
return Icons.eco_rounded;

case 'spinach':
return Icons.grass_rounded;

case 'onions':
case 'onion':
return Icons.spa_rounded;

default:
return Icons.agriculture_rounded;
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
'Fields & Planting',
style: TextStyle(
color: _textPrimary,
fontWeight: FontWeight.w900,
),
),
actions: [
IconButton(
tooltip: 'Refresh',
onPressed: _loadFields,
icon: const Icon(
Icons.refresh_rounded,
),
),
const SizedBox(width: 6),
],
),
floatingActionButton: FloatingActionButton.extended(
onPressed: _openAddFieldScreen,
backgroundColor: _primaryGreen,
foregroundColor: Colors.white,
icon: const Icon(
Icons.add_rounded,
),
label: const Text(
'Add Field',
style: TextStyle(
fontWeight: FontWeight.w900,
),
),
),
body: RefreshIndicator(
onRefresh: _loadFields,
color: _primaryGreen,
child: _isLoading
? const Center(
child: CircularProgressIndicator(
color: _primaryGreen,
),
)
    : SingleChildScrollView(
physics:
const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.fromLTRB(
18,
8,
18,
110,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_buildHeader(),

const SizedBox(height: 22),

_buildStatistics(),

const SizedBox(height: 25),

_buildPlantingOverview(),

const SizedBox(height: 25),

_buildFilterSection(),

const SizedBox(height: 18),

_buildFieldsSection(),
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
'Planting Planner',
style: TextStyle(
color: Colors.white,
fontSize: 25,
fontWeight: FontWeight.w900,
),
),
SizedBox(height: 7),
Text(
'Plan fields, monitor crops and prepare for harvest.',
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
Icons.landscape_rounded,
color: Colors.white,
size: 55,
),
],
),
);
}

Widget _buildStatistics() {
return Row(
children: [
Expanded(
child: _statCard(
title: 'Fields',
value: '${_fields.length}',
icon: Icons.grid_view_rounded,
),
),
const SizedBox(width: 10),
Expanded(
child: _statCard(
title: 'Hectares',
value:
_totalHectares.toStringAsFixed(1),
icon: Icons.square_foot_rounded,
),
),
const SizedBox(width: 10),
Expanded(
child: _statCard(
title: 'Active',
value: '$_activeFields',
icon: Icons.eco_rounded,
),
),
],
);
}

Widget _statCard({
required String title,
required String value,
required IconData icon,
}) {
return Container(
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 16,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: const Color(0xFFE3E9E4),
),
),
child: Column(
children: [
Icon(
icon,
color: _primaryGreen,
size: 22,
),
const SizedBox(height: 8),
FittedBox(
child: Text(
value,
style: const TextStyle(
color: _textPrimary,
fontSize: 20,
fontWeight: FontWeight.w900,
),
),
),
const SizedBox(height: 3),
Text(
title,
style: const TextStyle(
color: _textSecondary,
fontSize: 9.5,
fontWeight: FontWeight.w700,
),
),
],
),
);
}

Widget _buildPlantingOverview() {
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
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Row(
children: [
Icon(
Icons.agriculture_rounded,
color: _primaryGreen,
),
SizedBox(width: 9),
Text(
'Farm Planting Overview',
style: TextStyle(
color: _textPrimary,
fontSize: 15,
fontWeight: FontWeight.w900,
),
),
],
),

const SizedBox(height: 16),

_overviewRow(
title: 'Total fields',
value: '${_fields.length}',
),

const Divider(height: 22),

_overviewRow(
title: 'Land under management',
value:
'${_totalHectares.toStringAsFixed(2)} ha',
),

const Divider(height: 22),

_overviewRow(
title: 'Ready for harvest',
value: '$_readyFields',
),
],
),
);
}

Widget _overviewRow({
required String title,
required String value,
}) {
return Row(
children: [
Expanded(
child: Text(
title,
style: const TextStyle(
color: _textSecondary,
fontSize: 11,
fontWeight: FontWeight.w600,
),
),
),
Text(
value,
style: const TextStyle(
color: _textPrimary,
fontSize: 12,
fontWeight: FontWeight.w900,
),
),
],
);
}

Widget _buildFilterSection() {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Field Status',
style: TextStyle(
color: _textPrimary,
fontSize: 18,
fontWeight: FontWeight.w900,
),
),

const SizedBox(height: 12),

SizedBox(
height: 40,
child: ListView.separated(
scrollDirection: Axis.horizontal,
itemCount: _filters.length,
separatorBuilder: (_, _) =>
const SizedBox(width: 8),
itemBuilder: (context, index) {
final filter = _filters[index];

final selected =
filter == _selectedFilter;

return ChoiceChip(
label: Text(filter),
selected: selected,
onSelected: (_) {
setState(() {
_selectedFilter = filter;
});
},
selectedColor:
const Color(0xFFE8F5E9),
backgroundColor: Colors.white,
side: BorderSide(
color: selected
? const Color(0xFFA5D6A7)
    : const Color(0xFFE3E9E4),
),
labelStyle: TextStyle(
color: selected
? _primaryGreen
    : _textSecondary,
fontSize: 11,
fontWeight: selected
? FontWeight.w900
    : FontWeight.w700,
),
);
},
),
),
],
);
}

Widget _buildFieldsSection() {
final fields = _filteredFields;

return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
const Expanded(
child: Text(
'My Fields',
style: TextStyle(
color: _textPrimary,
fontSize: 19,
fontWeight: FontWeight.w900,
),
),
),
Text(
'${fields.length} field${fields.length == 1 ? '' : 's'}',
style: const TextStyle(
color: _textSecondary,
fontSize: 11,
fontWeight: FontWeight.w700,
),
),
],
),

const SizedBox(height: 14),

if (fields.isEmpty)
_buildEmptyState()
else
...fields.map(_buildFieldCard),
],
);
}

Widget _buildEmptyState() {
return Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(
horizontal: 24,
vertical: 38,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(24),
border: Border.all(
color: const Color(0xFFE3E9E4),
),
),
child: Column(
children: [
Container(
width: 72,
height: 72,
decoration: BoxDecoration(
color: const Color(0xFFE8F5E9),
borderRadius: BorderRadius.circular(22),
),
child: const Icon(
Icons.landscape_outlined,
color: _primaryGreen,
size: 38,
),
),

const SizedBox(height: 17),

Text(
_selectedFilter == 'All'
? 'No Fields Added Yet'
    : 'No $_selectedFilter Fields',
textAlign: TextAlign.center,
style: const TextStyle(
color: _textPrimary,
fontSize: 17,
fontWeight: FontWeight.w900,
),
),

const SizedBox(height: 7),

Text(
_selectedFilter == 'All'
? 'Create your first farm field and start planning your crops.'
    : 'There are currently no fields with this status.',
textAlign: TextAlign.center,
style: const TextStyle(
color: _textSecondary,
fontSize: 11,
height: 1.5,
),
),

if (_selectedFilter == 'All') ...[
const SizedBox(height: 18),
FilledButton.icon(
onPressed: _openAddFieldScreen,
style: FilledButton.styleFrom(
backgroundColor: _primaryGreen,
),
icon: const Icon(
Icons.add_rounded,
),
label: const Text(
'Create First Field',
),
),
],
],
),
);
}

Widget _buildFieldCard(
FarmField field,
) {
final statusColor =
_statusColor(field.status);

return Container(
margin: const EdgeInsets.only(bottom: 13),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
border: Border.all(
color: const Color(0xFFE3E9E4),
),
),
child: InkWell(
borderRadius: BorderRadius.circular(22),
onTap: () {
_openFieldDetails(field);
},
child: Padding(
padding: const EdgeInsets.all(17),
child: Column(
children: [
Row(
children: [
Container(
width: 51,
height: 51,
decoration: BoxDecoration(
color:
const Color(0xFFE8F5E9),
borderRadius:
BorderRadius.circular(16),
),
child: Icon(
_cropIcon(field.crop),
color: _primaryGreen,
size: 27,
),
),

const SizedBox(width: 13),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
field.name,
style: const TextStyle(
color: _textPrimary,
fontSize: 15,
fontWeight:
FontWeight.w900,
),
),
const SizedBox(height: 4),
Text(
'${field.crop} • '
'${field.sizeHectares.toStringAsFixed(2)} ha',
style: const TextStyle(
color: _textSecondary,
fontSize: 11,
fontWeight:
FontWeight.w600,
),
),
],
),
),

PopupMenuButton<String>(
onSelected: (value) {
if (value == 'details') {
_openFieldDetails(field);
}

if (value == 'edit') {
_openEditFieldScreen(field);
}

if (value == 'delete') {
_deleteField(field);
}
},
itemBuilder: (context) => [
const PopupMenuItem(
value: 'details',
child: Row(
children: [
Icon(
Icons.visibility_outlined,
),
SizedBox(width: 10),
Text('View Details'),
],
),
),
const PopupMenuItem(
value: 'edit',
child: Row(
children: [
Icon(
Icons.edit_outlined,
),
SizedBox(width: 10),
Text('Edit Field'),
],
),
),
const PopupMenuItem(
value: 'delete',
child: Row(
children: [
Icon(
Icons.delete_outline,
color: Colors.red,
),
SizedBox(width: 10),
Text(
'Delete',
style: TextStyle(
color: Colors.red,
),
),
],
),
),
],
),
],
),

const SizedBox(height: 15),

Row(
children: [
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 6,
),
decoration: BoxDecoration(
color: _statusBackground(
field.status,
),
borderRadius:
BorderRadius.circular(20),
),
child: Text(
field.status,
style: TextStyle(
color: statusColor,
fontSize: 9.5,
fontWeight: FontWeight.w900,
),
),
),

const Spacer(),

Icon(
field.hasLocation
? Icons.location_on_rounded
    : Icons.location_off_outlined,
size: 16,
color: field.hasLocation
? _primaryGreen
    : _textSecondary,
),

const SizedBox(width: 4),

Text(
field.hasLocation
? 'GPS'
    : 'No GPS',
style: TextStyle(
color: field.hasLocation
? _primaryGreen
    : _textSecondary,
fontSize: 9.5,
fontWeight: FontWeight.w700,
),
),
],
),

const SizedBox(height: 15),

const Divider(height: 1),

const SizedBox(height: 13),

Row(
children: [
Expanded(
child: _dateItem(
label: 'Planted',
value: _formatDate(
field.plantingDate,
),
icon:
Icons.calendar_today_outlined,
),
),
Expanded(
child: _dateItem(
label: 'Harvest',
value: _formatDate(
field.expectedHarvestDate,
),
icon:
Icons.event_available_outlined,
),
),
],
),
],
),
),
),
);
}

Widget _dateItem({
required String label,
required String value,
required IconData icon,
}) {
return Row(
children: [
Icon(
icon,
size: 17,
color: _primaryGreen,
),
const SizedBox(width: 7),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
label,
style: const TextStyle(
color: _textSecondary,
fontSize: 8.5,
fontWeight: FontWeight.w700,
),
),
const SizedBox(height: 2),
Text(
value,
style: const TextStyle(
color: _textPrimary,
fontSize: 10.5,
fontWeight: FontWeight.w800,
),
),
],
),
),
],
);
}

Widget _buildFieldDetailsSheet(
FarmField field,
) {
return DraggableScrollableSheet(
initialChildSize: 0.78,
minChildSize: 0.55,
maxChildSize: 0.94,
builder: (
context,
scrollController,
) {
return Container(
decoration: const BoxDecoration(
color: _background,
borderRadius: BorderRadius.vertical(
top: Radius.circular(30),
),
),
child: ListView(
controller: scrollController,
padding: const EdgeInsets.fromLTRB(
20,
14,
20,
30,
),
children: [
Center(
child: Container(
width: 46,
height: 5,
decoration: BoxDecoration(
color: const Color(0xFFCDD5CF),
borderRadius:
BorderRadius.circular(20),
),
),
),

const SizedBox(height: 22),

Row(
children: [
Container(
width: 58,
height: 58,
decoration: BoxDecoration(
color:
const Color(0xFFE8F5E9),
borderRadius:
BorderRadius.circular(18),
),
child: Icon(
_cropIcon(field.crop),
color: _primaryGreen,
size: 31,
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
field.name,
style: const TextStyle(
color: _textPrimary,
fontSize: 21,
fontWeight:
FontWeight.w900,
),
),
const SizedBox(height: 4),
Text(
field.crop,
style: const TextStyle(
color: _textSecondary,
fontSize: 12,
fontWeight:
FontWeight.w700,
),
),
],
),
),

IconButton(
onPressed: () {
Navigator.pop(context);
},
icon: const Icon(
Icons.close_rounded,
),
),
],
),

const SizedBox(height: 24),

_detailsCard(
children: [
_detailRow(
'Status',
field.status,
),
_detailDivider(),
_detailRow(
'Field Size',
'${field.sizeHectares.toStringAsFixed(2)} ha',
),
_detailDivider(),
_detailRow(
'Planting Date',
_formatDate(
field.plantingDate,
),
),
_detailDivider(),
_detailRow(
'Expected Harvest',
_formatDate(
field.expectedHarvestDate,
),
),
_detailDivider(),
_detailRow(
'Growing Period',
'${field.growingDays} days',
),
],
),

const SizedBox(height: 16),

_detailsCard(
children: [
_detailRow(
'GPS Location',
field.hasLocation
? 'Saved'
    : 'Not assigned',
),
if (field.hasLocation) ...[
_detailDivider(),
_detailRow(
'Latitude',
field.latitude!
    .toStringAsFixed(6),
),
_detailDivider(),
_detailRow(
'Longitude',
field.longitude!
    .toStringAsFixed(6),
),
],
],
),

if (field.notes.trim().isNotEmpty) ...[
const SizedBox(height: 16),
Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(22),
border: Border.all(
color:
const Color(0xFFE3E9E4),
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Field Notes',
style: TextStyle(
color: _textPrimary,
fontSize: 14,
fontWeight:
FontWeight.w900,
),
),
const SizedBox(height: 8),
Text(
field.notes,
style: const TextStyle(
color: _textSecondary,
fontSize: 11,
height: 1.5,
),
),
],
),
),
],

const SizedBox(height: 20),

SizedBox(
height: 50,
child: FilledButton.icon(
onPressed: () {
Navigator.pop(context);

_openEditFieldScreen(field);
},
style: FilledButton.styleFrom(
backgroundColor: _primaryGreen,
foregroundColor: Colors.white,
),
icon: const Icon(
Icons.edit_outlined,
),
label: const Text(
'Edit Field',
),
),
),

const SizedBox(height: 10),

SizedBox(
height: 50,
child: OutlinedButton.icon(
onPressed: () {
Navigator.pop(context);

_deleteField(field);
},
style: OutlinedButton.styleFrom(
foregroundColor:
Colors.red.shade700,
side: BorderSide(
color: Colors.red.shade200,
),
),
icon: const Icon(
Icons.delete_outline_rounded,
),
label: const Text(
'Delete Field',
),
),
),
],
),
);
},
);
}

Widget _detailsCard({
required List<Widget> children,
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
child: Column(
children: children,
),
);
}

Widget _detailRow(
String title,
String value,
) {
return Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Expanded(
child: Text(
title,
style: const TextStyle(
color: _textSecondary,
fontSize: 11,
fontWeight: FontWeight.w600,
),
),
),
const SizedBox(width: 15),
Flexible(
child: Text(
value,
textAlign: TextAlign.right,
style: const TextStyle(
color: _textPrimary,
fontSize: 11.5,
fontWeight: FontWeight.w900,
),
),
),
],
);
}

Widget _detailDivider() {
return const Divider(height: 24);
}
}

