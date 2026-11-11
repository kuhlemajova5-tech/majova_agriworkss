import 'package:flutter/material.dart';

import '../../models/farm_task.dart';

class TaskDetailsScreen extends StatelessWidget {
  final FarmTask task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: const Text(
          'Task Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF17201A),
          ),
        ),
      ),
      body: SingleChildScrollView(
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

            const SizedBox(height: 14),

            _buildInformationCard(
              children: [
                _buildInformationRow(
                  icon: Icons.task_alt_outlined,
                  label: 'Task Title',
                  value: task.title,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  value: task.category,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.flag_outlined,
                  label: 'Priority',
                  value: task.priority,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.pending_actions_outlined,
                  label: 'Status',
                  value: task.status,
                ),
              ],
            ),

            const SizedBox(height: 28),

            _buildSectionTitle('Schedule'),

            const SizedBox(height: 14),

            _buildInformationCard(
              children: [
                _buildInformationRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Due Date',
                  value: task.formattedDate,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.access_time_rounded,
                  label: 'Due Time',
                  value: task.dueTime,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.notifications_active_outlined,
                  label: 'Reminder',
                  value: task.reminderEnabled
                      ? 'Enabled'
                      : 'Disabled',
                ),
              ],
            ),

            const SizedBox(height: 28),

            _buildSectionTitle('Farm Assignment'),

            const SizedBox(height: 14),

            _buildInformationCard(
              children: [
                _buildInformationRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Assigned To',
                  value: task.assignedTo,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: task.location,
                ),
                _buildDivider(),
                _buildInformationRow(
                  icon: Icons.link_rounded,
                  label: 'Related Farm Item',
                  value: task.relatedItem.trim().isEmpty
                      ? 'Not specified'
                      : task.relatedItem,
                ),
              ],
            ),

            const SizedBox(height: 28),

            _buildSectionTitle('Task Description'),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE3E9E4),
                ),
              ),
              child: Text(
                task.description.trim().isEmpty
                    ? 'No description provided for this task.'
                    : task.description,
                style: const TextStyle(
                  color: Color(0xFF66736A),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 28),

            _buildSectionTitle('Task Status'),

            const SizedBox(height: 14),

            _buildStatusCard(),

            const SizedBox(height: 28),

            _buildQuickInformation(),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                ),
                label: const Text(
                  'Back to Tasks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B5E20),
                  side: const BorderSide(
                    color: Color(0xFF1B5E20),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
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
            child: Icon(
              _categoryIcon(task.category),
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            task.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            task.category,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFC8E6C9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHeaderChip(
                task.priority,
                Icons.flag_outlined,
              ),
              _buildHeaderChip(
                task.status,
                Icons.info_outline_rounded,
              ),
              if (task.isOverdue)
                _buildHeaderChip(
                  'Overdue',
                  Icons.warning_amber_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(
      String text,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.16,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInformationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1B5E20),
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF66736A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF17201A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color backgroundColor;
    Color iconColor;
    IconData icon;
    String title;
    String message;

    if (task.isCompleted) {
      backgroundColor = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF1B5E20);
      icon = Icons.task_alt_rounded;
      title = 'Task Completed';
      message =
      'This farming activity has been marked as completed.';
    } else if (task.isOverdue) {
      backgroundColor = const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFC62828);
      icon = Icons.warning_amber_rounded;
      title = 'Task Overdue';
      message =
      'This task has passed its due date and still requires attention.';
    } else if (task.isDueToday) {
      backgroundColor = const Color(0xFFFFF8E1);
      iconColor = const Color(0xFFF57F17);
      icon = Icons.today_rounded;
      title = 'Due Today';
      message =
      'This farming activity is scheduled to be completed today.';
    } else if (task.isInProgress) {
      backgroundColor = const Color(0xFFE3F2FD);
      iconColor = const Color(0xFF1565C0);
      icon = Icons.timelapse_rounded;
      title = 'Work In Progress';
      message =
      'Work has started on this farming activity.';
    } else {
      backgroundColor = const Color(0xFFF7F9F7);
      iconColor = const Color(0xFF1B5E20);
      icon = Icons.schedule_rounded;
      title = 'Upcoming Task';
      message =
      'This farming activity is scheduled for a future date.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 28,
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF66736A),
                    fontSize: 11,
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

  Widget _buildQuickInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF17201A),
            ),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _buildQuickItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'Date',
                  value: task.formattedDate,
                ),
              ),
              Expanded(
                child: _buildQuickItem(
                  icon: Icons.access_time_rounded,
                  title: 'Time',
                  value: task.dueTime,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildQuickItem(
                  icon: Icons.flag_outlined,
                  title: 'Priority',
                  value: task.priority,
                ),
              ),
              Expanded(
                child: _buildQuickItem(
                  icon: task.reminderEnabled
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  title: 'Reminder',
                  value: task.reminderEnabled
                      ? 'On'
                      : 'Off',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF1B5E20),
          size: 25,
        ),
        const SizedBox(height: 7),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF66736A),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF17201A),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: Color(0xFFE8ECE9),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Crop Management':
      case 'Planting':
      case 'Harvesting':
        return Icons.eco_outlined;

      case 'Livestock':
        return Icons.pets_outlined;

      case 'Tractor & Machinery':
        return Icons.agriculture_rounded;

      case 'Irrigation':
        return Icons.water_drop_outlined;

      case 'Maintenance':
        return Icons.build_outlined;

      case 'Market & Delivery':
        return Icons.local_shipping_outlined;

      case 'Inventory':
        return Icons.inventory_2_outlined;

      case 'Finance':
        return Icons.account_balance_wallet_outlined;

      default:
        return Icons.task_alt_outlined;
    }
  }
}