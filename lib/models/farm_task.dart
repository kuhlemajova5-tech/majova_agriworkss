class FarmTask {
  final String title;
  final String category;
  final String priority;
  final String status;
  final DateTime dueDate;
  final String dueTime;
  final String assignedTo;
  final String location;
  final String relatedItem;
  final String description;
  final bool reminderEnabled;

  const FarmTask({
    required this.title,
    required this.category,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.dueTime,
    required this.assignedTo,
    required this.location,
    required this.relatedItem,
    required this.description,
    required this.reminderEnabled,
  });

  bool get isCompleted => status == 'Completed';

  bool get isPending => status == 'Pending';

  bool get isInProgress => status == 'In Progress';

  bool get isOverdue {
    if (isCompleted) {
      return false;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final taskDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    );

    return taskDate.isBefore(today);
  }

  bool get isDueToday {
    final now = DateTime.now();

    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  String get formattedDate {
    final day = dueDate.day.toString().padLeft(2, '0');
    final month = dueDate.month.toString().padLeft(2, '0');

    return '$day/$month/${dueDate.year}';
  }

  String get scheduleText {
    return '$formattedDate • $dueTime';
  }
}