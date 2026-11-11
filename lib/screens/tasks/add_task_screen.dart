import 'package:flutter/material.dart';

import '../../models/farm_task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController assignedToController =
  TextEditingController();

  final TextEditingController locationController =
  TextEditingController();

  final TextEditingController relatedItemController =
  TextEditingController();

  final TextEditingController descriptionController =
  TextEditingController();

  String selectedCategory = 'Crop Management';
  String selectedPriority = 'Medium';
  String selectedStatus = 'Pending';

  DateTime selectedDueDate = DateTime.now();

  TimeOfDay selectedDueTime = const TimeOfDay(
    hour: 8,
    minute: 0,
  );

  bool reminderEnabled = true;

  final List<String> categories = [
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

  final List<String> priorities = [
    'Low',
    'Medium',
    'High',
    'Urgent',
  ];

  final List<String> statuses = [
    'Pending',
    'In Progress',
    'Completed',
  ];

  @override
  void dispose() {
    titleController.dispose();
    assignedToController.dispose();
    locationController.dispose();
    relatedItemController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _selectDueDate() async {
    final DateTime today = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate,
      firstDate: DateTime(
        today.year,
        today.month,
        today.day,
      ),
      lastDate: DateTime(today.year + 10),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      selectedDueDate = selectedDate;
    });
  }

  Future<void> _selectDueTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: selectedDueTime,
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      selectedDueTime = selectedTime;
    });
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final FarmTask newTask = FarmTask(
      title: titleController.text.trim(),
      category: selectedCategory,
      priority: selectedPriority,
      status: selectedStatus,
      dueDate: selectedDueDate,
      dueTime: _formatTime(selectedDueTime),
      assignedTo: assignedToController.text.trim(),
      location: locationController.text.trim(),
      relatedItem: relatedItemController.text.trim(),
      description: descriptionController.text.trim(),
      reminderEnabled: reminderEnabled,
    );

    Navigator.pop(
      context,
      newTask,
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
          'Add Farm Task',
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

              _buildSectionTitle('Task Information'),

              const SizedBox(height: 16),

              _buildLabel('Task Title'),

              const SizedBox(height: 8),

              TextFormField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Example: Water Spinach',
                  prefixIcon: Icon(
                    Icons.task_alt_rounded,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter the task title';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('Category'),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.category_outlined,
                  ),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('Priority'),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedPriority,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.flag_outlined,
                  ),
                ),
                items: priorities.map((priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedPriority = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('Status'),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.pending_actions_outlined,
                  ),
                ),
                items: statuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              _buildSectionTitle('Schedule'),

              const SizedBox(height: 16),

              _buildDateTimeSelector(
                title: 'Due Date',
                value: _formatDate(selectedDueDate),
                icon: Icons.calendar_month_outlined,
                onTap: _selectDueDate,
              ),

              const SizedBox(height: 14),

              _buildDateTimeSelector(
                title: 'Due Time',
                value: _formatTime(selectedDueTime),
                icon: Icons.access_time_rounded,
                onTap: _selectDueTime,
              ),

              const SizedBox(height: 30),

              _buildSectionTitle('Farm Assignment'),

              const SizedBox(height: 16),

              _buildLabel('Assigned To'),

              const SizedBox(height: 8),

              TextFormField(
                controller: assignedToController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Example: Farm Manager',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter who is responsible';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('Location'),

              const SizedBox(height: 8),

              TextFormField(
                controller: locationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Example: Spinach Field',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter the task location';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _buildLabel('Related Farm Item'),

              const SizedBox(height: 8),

              TextFormField(
                controller: relatedItemController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText:
                  'Example: Spinach, Sheep Flock or MF 265',
                  prefixIcon: Icon(
                    Icons.link_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              _buildSectionTitle('Task Description'),

              const SizedBox(height: 16),

              TextFormField(
                controller: descriptionController,
                minLines: 4,
                maxLines: 6,
                textCapitalization:
                TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText:
                  'Describe what needs to be done...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 24),

              _buildReminderCard(),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saveTask,
                  icon: const Icon(
                    Icons.save_outlined,
                  ),
                  label: const Text(
                    'Save Task',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
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
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.add_task_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'Create Farm Task',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Plan farm activities, assign responsibilities and keep important work on schedule.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3E8E4),
        ),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: reminderEnabled,
        activeThumbColor: const Color(0xFF1B5E20),
        onChanged: (value) {
          setState(() {
            reminderEnabled = value;
          });
        },
        secondary: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.notifications_active_outlined,
            color: Color(0xFF1B5E20),
          ),
        ),
        title: const Text(
          'Task Reminder',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF17201A),
          ),
        ),
        subtitle: const Text(
          'Enable a reminder for this farm activity.',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF66736A),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE3E8E4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF1B5E20),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF66736A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17201A),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF66736A),
            ),
          ],
        ),
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF17201A),
      ),
    );
  }
}