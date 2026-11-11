class FarmCalendarEvent {
  final String id;
  String title;
  String description;
  DateTime date;
  String category;
  String priority;
  bool isCompleted;
  String? relatedItem;
  String? notes;

  FarmCalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.priority,
    this.isCompleted = false,
    this.relatedItem,
    this.notes,
  });

  FarmCalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? category,
    String? priority,
    bool? isCompleted,
    String? relatedItem,
    String? notes,
  }) {
    return FarmCalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      relatedItem: relatedItem ?? this.relatedItem,
      notes: notes ?? this.notes,
    );
  }
}