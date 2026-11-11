
import 'package:flutter/material.dart';

import '../../models/farm_task.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'task_details_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  static const Color farmGreen = Color(0xFF1B5E20);
  static const Color darkGreen = Color(0xFF0B3D1B);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF4F7F4);
  static const Color textBlack = Color(0xFF17201A);
  static const Color mutedText = Color(0xFF66736A);

  String selectedFilter = 'All';

  final List<String> filters = [
    'All',
    'Today',
    'Pending',
    'In Progress',
    'Completed',
  ];

  final List<FarmTask> tasks = [
    FarmTask(
      title: 'Water Spinach',
      category: 'Crops',
      priority: 'High',
      status: 'Pending',
      dueDate: DateTime.now(),
      dueTime: '08:00 AM',
      assignedTo: 'Farm owner',
      location: 'Vegetable garden',
      relatedItem: 'Spinach',
      description: 'Water the spinach plants and check soil moisture.',
      reminderEnabled: true,
    ),
    FarmTask(
      title: 'Inspect MF 265',
      category: 'Machinery',
      priority: 'Medium',
      status: 'In Progress',
      dueDate: DateTime.now(),
      dueTime: '10:00 AM',
      assignedTo: 'Farm owner',
      location: 'Farm shed',
      relatedItem: 'Massey Ferguson 265',
      description: 'Inspect the tractor, tyres, oil and fuel levels.',
      reminderEnabled: true,
    ),
    FarmTask(
      title: 'Check Sheep Flock',
      category: 'Livestock',
      priority: 'High',
      status: 'Pending',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      dueTime: '07:00 AM',
      assignedTo: 'Farm owner',
      location: 'Sheep kraal',
      relatedItem: 'Sheep',
      description: 'Check animal health, feed and drinking water.',
      reminderEnabled: true,
    ),
  ];

  List<FarmTask> get filteredTasks {
    final now = DateTime.now();

    switch (selectedFilter) {
      case 'Today':
        return tasks.where((task) {
          return task.dueDate.year == now.year &&
              task.dueDate.month == now.month &&
              task.dueDate.day == now.day;
        }).toList();

      case 'Pending':
        return tasks
            .where((task) => task.status == 'Pending')
            .toList();

      case 'In Progress':
        return tasks
            .where((task) => task.status == 'In Progress')
            .toList();

      case 'Completed':
        return tasks
            .where((task) => task.isCompleted)
            .toList();

      default:
        return List<FarmTask>.from(tasks);
    }
  }

  int get completedCount =>
      tasks.where((task) => task.isCompleted).length;

  int get pendingCount =>
      tasks.where((task) => task.status == 'Pending').length;

  int get inProgressCount =>
      tasks.where((task) => task.status == 'In Progress').length;

  Future<void> _addTask() async {
    final result = await Navigator.push<FarmTask>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTaskScreen(),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        tasks.add(result);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully.')),
      );
    }
  }

  Future<void> _editTask(FarmTask task) async {
    final result = await Navigator.push<FarmTask>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTaskScreen(task: task),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      final index = tasks.indexOf(task);

      if (index != -1) {
        setState(() {
          tasks[index] = result;
        });
      }
    }
  }

  void _openTaskDetails(FarmTask task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailsScreen(task: task),
      ),
    );
  }

  void _markCompleted(FarmTask task) {
    setState(() {
      final index = tasks.indexOf(task);

      if (index != -1) {
        tasks[index] = FarmTask(
          title: task.title,
          category: task.category,
          priority: task.priority,
          status: 'Completed',
          dueDate: task.dueDate,
          dueTime: task.dueTime,
          assignedTo: task.assignedTo,
          location: task.location,
          relatedItem: task.relatedItem,
          description: task.description,
          reminderEnabled: task.reminderEnabled,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task marked as completed.')),
    );
  }

  Future<void> _deleteTask(FarmTask task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Task',
          style: TextStyle(color: textBlack),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
          style: const TextStyle(color: textBlack),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      tasks.remove(task);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted.')),
    );
  }

  void _openFarmCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FarmCalendarPage(tasks: tasks),
      ),
    );
  }

  void _openReminders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TaskRemindersPage(tasks: tasks),
      ),
    );
  }

  void _openAssignments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TaskAssignmentsPage(
          tasks: tasks,
          onEdit: _editTask,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Task Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Add task',
            onPressed: _addTask,
            icon: const Icon(Icons.add_task),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildSectionTitle('Task Overview'),
          const SizedBox(height: 12),
          _buildOverviewGrid(),
          const SizedBox(height: 24),
          _buildSectionTitle('Your Tasks'),
          const SizedBox(height: 12),
          _buildFilters(),
          const SizedBox(height: 12),
          if (filteredTasks.isEmpty)
            _buildEmptyState()
          else
            ...filteredTasks.map(_buildTaskCard),
          const SizedBox(height: 24),
          _buildSectionTitle('Task Management Tools'),
          const SizedBox(height: 12),
          _buildManagementCard(
            icon: Icons.calendar_month,
            title: 'Farm Calendar',
            subtitle: 'View tasks by scheduled date',
            onTap: _openFarmCalendar,
          ),
          _buildManagementCard(
            icon: Icons.notifications_active,
            title: 'Reminders',
            subtitle: 'View tasks with reminders enabled',
            onTap: _openReminders,
          ),
          _buildManagementCard(
            icon: Icons.assignment_ind,
            title: 'Assignments',
            subtitle: 'View who is responsible for each task',
            onTap: _openAssignments,
          ),
          const SizedBox(height: 24),
          _buildAddTaskButton(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [farmGreen, darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.agriculture, color: Colors.white, size: 34),
          SizedBox(height: 12),
          Text(
            'Manage Your Farm Tasks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Organise your daily farming activities, '
                'livestock care and machinery maintenance.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
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
        color: textBlack,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOverviewGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _buildSummaryCard(
          'Total Tasks',
          '${tasks.length}',
          Icons.task_alt,
          farmGreen,
        ),
        _buildSummaryCard(
          'Pending',
          '$pendingCount',
          Icons.pending_actions,
          Colors.orange.shade700,
        ),
        _buildSummaryCard(
          'In Progress',
          '$inProgressCount',
          Icons.autorenew,
          Colors.blue.shade700,
        ),
        _buildSummaryCard(
          'Completed',
          '$completedCount',
          Icons.check_circle,
          Colors.teal.shade700,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8E1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: textBlack,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: mutedText,
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

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              selectedColor: farmGreen,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : textBlack,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: selected ? farmGreen : Colors.grey.shade300,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskCard(FarmTask task) {
    final completed = task.isCompleted;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openTaskDetails(task),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        color: textBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: textBlack),
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          _openTaskDetails(task);
                          break;
                        case 'edit':
                          _editTask(task);
                          break;
                        case 'complete':
                          _markCompleted(task);
                          break;
                        case 'delete':
                          _deleteTask(task);
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Text('View details'),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit task'),
                      ),
                      if (!completed)
                        const PopupMenuItem(
                          value: 'complete',
                          child: Text('Mark completed'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete task'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildTag(task.category, lightGreen, farmGreen),
                  _buildTag(
                    task.status,
                    completed
                        ? const Color(0xFFE0F2F1)
                        : const Color(0xFFFFF3E0),
                    completed ? Colors.teal.shade800 : Colors.deepOrange,
                  ),
                  _buildTag(
                    task.priority,
                    const Color(0xFFFCE4EC),
                    Colors.red.shade800,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.calendar_today,
                'Due: ${task.formattedDate}',
              ),
              const SizedBox(height: 6),
              _buildInfoRow(
                Icons.access_time,
                'Time: ${task.dueTime}',
              ),
              const SizedBox(height: 6),
              _buildInfoRow(
                Icons.person_outline,
                'Assigned to: ${task.assignedTo.isEmpty ? "Not assigned" : task.assignedTo}',
              ),
              if (task.reminderEnabled) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: farmGreen,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Reminder enabled',
                      style: TextStyle(
                        color: farmGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _editTask(task),
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: farmGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: completed
                          ? null
                          : () => _markCompleted(task),
                      icon: const Icon(Icons.check, size: 17),
                      label: Text(completed ? 'Completed' : 'Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: farmGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: textBlack,
                      ),
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

  Widget _buildTag(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: mutedText),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: textBlack,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: CircleAvatar(
          backgroundColor: lightGreen,
          child: Icon(icon, color: farmGreen),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: mutedText, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: farmGreen,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.task_alt, size: 50, color: farmGreen),
          const SizedBox(height: 12),
          const Text(
            'No tasks found',
            style: TextStyle(
              color: textBlack,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add a task or choose another filter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedText),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _addTask,
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: farmGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTaskButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Add New Task'),
        style: ElevatedButton.styleFrom(
          backgroundColor: farmGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// FARM CALENDAR PAGE

class _FarmCalendarPage extends StatelessWidget {
  final List<FarmTask> tasks;

  const _FarmCalendarPage({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final sortedTasks = List<FarmTask>.from(tasks)
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text('Farm Calendar'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: sortedTasks.isEmpty
          ? const Center(
        child: Text(
          'No scheduled tasks.',
          style: TextStyle(color: Colors.black),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedTasks.length,
        itemBuilder: (context, index) {
          final task = sortedTasks[index];

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(
                  Icons.calendar_month,
                  color: Color(0xFF1B5E20),
                ),
              ),
              title: Text(
                task.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${task.formattedDate} • ${task.dueTime}\n'
                    '${task.category} • ${task.status}',
                style: const TextStyle(color: Colors.black87),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

// REMINDERS PAGE

class _TaskRemindersPage extends StatelessWidget {
  final List<FarmTask> tasks;

  const _TaskRemindersPage({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final reminders = tasks
        .where((task) => task.reminderEnabled)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text('Task Reminders'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: reminders.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No reminders are enabled for your tasks.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final task = reminders[index];

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Icon(
                  Icons.notifications_active,
                  color: Colors.deepOrange,
                ),
              ),
              title: Text(
                task.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Due: ${task.formattedDate} at ${task.dueTime}',
                style: const TextStyle(color: Colors.black87),
              ),
              trailing: const Icon(
                Icons.notifications_active,
                color: Color(0xFF1B5E20),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ASSIGNMENTS PAGE

class _TaskAssignmentsPage extends StatelessWidget {
  final List<FarmTask> tasks;
  final Future<void> Function(FarmTask task) onEdit;

  const _TaskAssignmentsPage({
    required this.tasks,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text('Task Assignments'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Text(
          'There are no tasks to display.',
          style: TextStyle(color: Colors.black),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final assignee = task.assignedTo.trim().isEmpty
              ? 'Not assigned'
              : task.assignedTo;

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(
                  Icons.assignment_ind,
                  color: Color(0xFF1B5E20),
                ),
              ),
              title: Text(
                task.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Assigned to: $assignee\n'
                    'Status: ${task.status}\n'
                    'Due: ${task.formattedDate}',
                style: const TextStyle(color: Colors.black87),
              ),
              isThreeLine: true,
              trailing: IconButton(
                tooltip: 'Edit assignment',
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xFF1B5E20),
                ),
                onPressed: () => onEdit(task),
              ),
            ),
          );
        },
      ),
    );
  }
}
