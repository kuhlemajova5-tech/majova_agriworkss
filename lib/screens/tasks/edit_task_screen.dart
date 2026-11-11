import 'package:flutter/material.dart';

import '../../models/farm_task.dart';

class EditTaskScreen extends StatefulWidget {
  final FarmTask task;

  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _assignedToController;
  late final TextEditingController _locationController;
  late final TextEditingController _relatedItemController;
  late final TextEditingController _descriptionController;

  final List<String> _categories = [
    'Crop Management',
    'Livestock',
    'Tractor & Machinery',
    'Irrigation',
    'Maintenance',
    'Harvesting',
    'Planting',
    'Market & Delivery',
    'Inventory',
    'Finance',
    'General Farm Work',
    'Other',
  ];

  final List<String> _priorities = [
    'Low',
    'Medium',
    'High',
    'Urgent',
  ];

  final List<String> _statuses = [
    'Pending',
    'In Progress',
    'Completed',
  ];

  late String _selectedCategory;
  late String _selectedPriority;
  late String _selectedStatus;

  late DateTime _selectedDueDate;
  late TimeOfDay _selectedDueTime;

  late bool _reminderEnabled;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.task.title,
    );

    _assignedToController = TextEditingController(
      text: widget.task.assignedTo,
    );

    _locationController = TextEditingController(
      text: widget.task.location,
    );

    _relatedItemController = TextEditingController(
      text: widget.task.relatedItem,
    );

    _descriptionController = TextEditingController(
      text: widget.task.description,
    );

    _selectedCategory = _safeValue(
      widget.task.category,
      _categories,
      'Other',
    );

    _selectedPriority = _safeValue(
      widget.task.priority,
      _priorities,
      'Medium',
    );

    _selectedStatus = _safeValue(
      widget.task.status,
      _statuses,
      'Pending',
    );

    _selectedDueDate = widget.task.dueDate;

    _selectedDueTime = _timeFromString(
      widget.task.dueTime,
    );

    _reminderEnabled = widget.task.reminderEnabled;
  }

  String _safeValue(
      String value,
      List<String> values,
      String fallback,
      ) {
    if (values.contains(value)) {
      return value;
    }

    return fallback;
  }

  TimeOfDay _timeFromString(String value) {
    try {
      final parts = value.split(':');

      if (parts.length != 2) {
        return const TimeOfDay(
          hour: 8,
          minute: 0,
        );
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return TimeOfDay(
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      return const TimeOfDay(
        hour: 8,
        minute: 0,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _assignedToController.dispose();
    _locationController.dispose();
    _relatedItemController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime now = DateTime.now();

    final DateTime initialDate =
    _selectedDueDate.isBefore(
      DateTime(
        now.year,
        now.month,
        now.day,
      ),
    )
        ? now
        : _selectedDueDate;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(
        now.year - 5,
      ),
      lastDate: DateTime(
        now.year + 10,
      ),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDueDate = pickedDate;
    });
  }

  Future<void> _selectDueTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime,
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _selectedDueTime = pickedTime;
    });
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final FarmTask updatedTask = FarmTask(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      status: _selectedStatus,
      dueDate: _selectedDueDate,
      dueTime: _formatTime(_selectedDueTime),
      assignedTo: _assignedToController.text.trim(),
      location: _locationController.text.trim(),
      relatedItem: _relatedItemController.text.trim(),
      description: _descriptionController.text.trim(),
      reminderEnabled: _reminderEnabled,
    );

    Navigator.pop(
      context,
      updatedTask,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Task',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17201A),
              ),
            ),
            Text(
              'Update your farming activity',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF66736A),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            15,
            20,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'Task Information',
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _titleController,
                label: 'Task Title',
                hint: 'Example: Water spinach',
                icon: Icons.task_alt_outlined,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter a task title.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              _buildDropdown(
                label: 'Category',
                icon: Icons.category_outlined,
                value: _selectedCategory,
                items: _categories,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Priority',
                      icon: Icons.flag_outlined,
                      value: _selectedPriority,
                      items: _priorities,
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedPriority = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildDropdown(
                      label: 'Status',
                      icon: Icons.pending_actions_outlined,
                      value: _selectedStatus,
                      items: _statuses,
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'Schedule',
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildSelectionCard(
                      icon: Icons.calendar_month_outlined,
                      label: 'Due Date',
                      value: _formatDate(
                        _selectedDueDate,
                      ),
                      onTap: _selectDueDate,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildSelectionCard(
                      icon: Icons.access_time_rounded,
                      label: 'Due Time',
                      value: _formatTime(
                        _selectedDueTime,
                      ),
                      onTap: _selectDueTime,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'Assignment',
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _assignedToController,
                label: 'Assigned To',
                hint: 'Example: Farm Manager',
                icon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter who is responsible.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _locationController,
                label: 'Farm Location',
                hint: 'Example: Spinach Field',
                icon: Icons.location_on_outlined,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter a farm location.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _relatedItemController,
                label: 'Related Farm Item',
                hint: 'Example: Spinach, MF 265 or Sheep Flock',
                icon: Icons.link_rounded,
              ),

              const SizedBox(height: 28),

              _buildSectionTitle(
                'Description',
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _descriptionController,
                label: 'Task Description',
                hint:
                'Describe what needs to be done...',
                icon: Icons.notes_rounded,
                maxLines: 5,
              ),

              const SizedBox(height: 24),

              _buildReminderCard(),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _saveTask,
                icon: const Icon(
                  Icons.save_rounded,
                ),
                label: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
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
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Farm Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.task.title,
                  style: const TextStyle(
                    color: Color(0xFFC8E6C9),
                    fontSize: 12,
                  ),
                ),
              ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: maxLines == 1
            ? Icon(icon)
            : null,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: const Color(0xFFE3E9E4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFF1B5E20),
              size: 23,
            ),

            const SizedBox(height: 10),

            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF66736A),
                fontSize: 10,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF17201A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Color(0xFF1B5E20),
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Reminder',
                  style: TextStyle(
                    color: Color(0xFF17201A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep a reminder enabled for this farm activity.',
                  style: TextStyle(
                    color: Color(0xFF66736A),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: _reminderEnabled,
            activeThumbColor: const Color(0xFF1B5E20),
            onChanged: (value) {
              setState(() {
                _reminderEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }
}