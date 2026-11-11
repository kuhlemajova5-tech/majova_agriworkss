import 'package:flutter/material.dart';
import '../../models/farm_calendar_event.dart';

class FarmCalendarScreen extends StatefulWidget {
  const FarmCalendarScreen({super.key});

  @override
  State<FarmCalendarScreen> createState() => _FarmCalendarScreenState();
}

class _FarmCalendarScreenState extends State<FarmCalendarScreen> {
  static const Color _primaryGreen = Color(0xFF1B5E20);
  static const Color _darkGreen = Color(0xFF0B3D1B);
  static const Color _mediumGreen = Color(0xFF43A047);
  static const Color _background = Color(0xFFF4F7F4);
  static const Color _textPrimary = Color(0xFF17201A);
  static const Color _textSecondary = Color(0xFF66736A);

  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Crops',
    'Livestock',
    'Machinery',
    'Tasks',
    'Market',
    'Finance',
  ];

  late List<FarmCalendarEvent> _events;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    _displayedMonth = DateTime(
      now.year,
      now.month,
    );

    _events = _createDemoEvents(now);
  }

  List<FarmCalendarEvent> _createDemoEvents(DateTime now) {
    return [
      FarmCalendarEvent(
        id: '1',
        title: 'Water Spinach',
        description: 'Morning irrigation for the spinach field.',
        date: DateTime(now.year, now.month, now.day),
        category: 'Crops',
        priority: 'High',
        relatedItem: 'Spinach',
      ),
      FarmCalendarEvent(
        id: '2',
        title: 'Inspect Cabbage',
        description: 'Check cabbage leaves for pests and disease.',
        date: DateTime(now.year, now.month, now.day),
        category: 'Crops',
        priority: 'Medium',
        relatedItem: 'Cabbage',
      ),
      FarmCalendarEvent(
        id: '3',
        title: 'MF 265 Inspection',
        description: 'Check oil, tyres, coolant and fuel level.',
        date: DateTime(now.year, now.month, now.day + 1),
        category: 'Machinery',
        priority: 'Medium',
        relatedItem: 'MF 265',
      ),
      FarmCalendarEvent(
        id: '4',
        title: 'Sheep Health Check',
        description: 'Inspect the flock and record health observations.',
        date: DateTime(now.year, now.month, now.day + 2),
        category: 'Livestock',
        priority: 'High',
        relatedItem: 'Sheep',
      ),
      FarmCalendarEvent(
        id: '5',
        title: 'Buy NPK Fertiliser',
        description: 'Restock fertiliser before the next application.',
        date: DateTime(now.year, now.month, now.day + 3),
        category: 'Tasks',
        priority: 'Medium',
      ),
      FarmCalendarEvent(
        id: '6',
        title: 'Market Delivery',
        description: 'Prepare cabbage and spinach for customer delivery.',
        date: DateTime(now.year, now.month, now.day + 5),
        category: 'Market',
        priority: 'High',
      ),
      FarmCalendarEvent(
        id: '7',
        title: 'Record Farm Expenses',
        description: 'Capture diesel, feed and fertiliser expenses.',
        date: DateTime(now.year, now.month, now.day + 6),
        category: 'Finance',
        priority: 'Low',
      ),
    ];
  }

  List<FarmCalendarEvent> get _selectedDateEvents {
    return _events.where((event) {
      final sameDate = _isSameDay(
        event.date,
        _selectedDate,
      );

      final matchesFilter =
          _selectedFilter == 'All' ||
              event.category == _selectedFilter;

      return sameDate && matchesFilter;
    }).toList()
      ..sort(
            (a, b) => _priorityValue(
          b.priority,
        ).compareTo(
          _priorityValue(a.priority),
        ),
      );
  }

  int get _pendingCount {
    return _events.where((event) => !event.isCompleted).length;
  }

  int get _completedCount {
    return _events.where((event) => event.isCompleted).length;
  }

  int get _thisMonthCount {
    return _events.where((event) {
      return event.date.year == _displayedMonth.year &&
          event.date.month == _displayedMonth.month;
    }).length;
  }

  int _priorityValue(String priority) {
    switch (priority) {
      case 'High':
        return 3;
      case 'Medium':
        return 2;
      default:
        return 1;
    }
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  void _goToToday() {
    final now = DateTime.now();

    setState(() {
      _selectedDate = DateTime(
        now.year,
        now.month,
        now.day,
      );

      _displayedMonth = DateTime(
        now.year,
        now.month,
      );
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _toggleCompleted(FarmCalendarEvent event) {
    setState(() {
      event.isCompleted = !event.isCompleted;
    });
  }

  void _deleteEvent(FarmCalendarEvent event) {
    setState(() {
      _events.removeWhere(
            (item) => item.id == event.id,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${event.title} removed from the calendar.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddEventSheet() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final relatedController = TextEditingController();

    String category = 'Crops';
    String priority = 'Medium';
    DateTime eventDate = _selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight:
                MediaQuery.of(context).size.height * 0.90,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  MediaQuery.of(context).viewInsets.bottom + 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8DDD9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Add Farm Event',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Schedule an activity, reminder or important farm date.',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        label: 'Event title',
                        icon: Icons.title_rounded,
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: descriptionController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        label: 'Description',
                        icon: Icons.notes_rounded,
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: _inputDecoration(
                        label: 'Category',
                        icon: Icons.category_outlined,
                      ),
                      items: [
                        'Crops',
                        'Livestock',
                        'Machinery',
                        'Tasks',
                        'Market',
                        'Finance',
                      ].map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setSheetState(() {
                          category = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: _inputDecoration(
                        label: 'Priority',
                        icon: Icons.flag_outlined,
                      ),
                      items: [
                        'Low',
                        'Medium',
                        'High',
                      ].map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setSheetState(() {
                          priority = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: eventDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );

                        if (pickedDate != null) {
                          setSheetState(() {
                            eventDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          label: 'Event date',
                          icon: Icons.calendar_month_rounded,
                        ),
                        child: Text(
                          _formatFullDate(eventDate),
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: relatedController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        label: 'Related crop, animal or machine (optional)',
                        icon: Icons.link_rounded,
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          final title = titleController.text.trim();

                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter an event title.',
                                ),
                              ),
                            );
                            return;
                          }

                          final event = FarmCalendarEvent(
                            id: DateTime.now()
                                .microsecondsSinceEpoch
                                .toString(),
                            title: title,
                            description:
                            descriptionController.text.trim().isEmpty
                                ? 'No description provided.'
                                : descriptionController.text.trim(),
                            date: DateTime(
                              eventDate.year,
                              eventDate.month,
                              eventDate.day,
                            ),
                            category: category,
                            priority: priority,
                            relatedItem:
                            relatedController.text.trim().isEmpty
                                ? null
                                : relatedController.text.trim(),
                          );

                          setState(() {
                            _events.add(event);
                            _selectedDate = event.date;
                            _displayedMonth = DateTime(
                              event.date.year,
                              event.date.month,
                            );
                          });

                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${event.title} added to the Farm Calendar.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add_task_rounded,
                        ),
                        label: const Text(
                          'Add Farm Event',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: _primaryGreen,
      ),
      filled: true,
      fillColor: const Color(0xFFF7F9F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE1E7E2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE1E7E2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _primaryGreen,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Farm Calendar',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _goToToday,
            child: const Text(
              'Today',
              style: TextStyle(
                color: _primaryGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventSheet,
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add Event',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            110,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 18),

              _buildSummary(),

              const SizedBox(height: 24),

              _buildCalendar(),

              const SizedBox(height: 22),

              _buildFilters(),

              const SizedBox(height: 22),

              _buildSelectedDayHeader(),

              const SizedBox(height: 12),

              _buildEventList(),
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm Planner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Plan crops, livestock, machinery, markets and farm activities in one place.',
                  style: TextStyle(
                    color: Color(0xFFD7EED9),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Icon(
            Icons.calendar_month_rounded,
            color: Colors.white,
            size: 54,
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
            value: '$_thisMonthCount',
            label: 'This Month',
            icon: Icons.event_note_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            value: '$_pendingCount',
            label: 'Pending',
            icon: Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            value: '$_completedCount',
            label: 'Completed',
            icon: Icons.task_alt_rounded,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
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
          Icon(
            icon,
            color: _primaryGreen,
            size: 21,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    final leadingEmptyDays = firstDay.weekday % 7;

    final totalCells = leadingEmptyDays + daysInMonth;

    final rowCount = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(
                  Icons.chevron_left_rounded,
                ),
              ),
              Expanded(
                child: Text(
                  '${_monthName(_displayedMonth.month)} ${_displayedMonth.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Row(
            children: [
              _WeekDay('Sun'),
              _WeekDay('Mon'),
              _WeekDay('Tue'),
              _WeekDay('Wed'),
              _WeekDay('Thu'),
              _WeekDay('Fri'),
              _WeekDay('Sat'),
            ],
          ),

          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rowCount * 7,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) {
              final dayNumber =
                  index - leadingEmptyDays + 1;

              if (dayNumber < 1 ||
                  dayNumber > daysInMonth) {
                return const SizedBox();
              }

              final date = DateTime(
                _displayedMonth.year,
                _displayedMonth.month,
                dayNumber,
              );

              final isSelected = _isSameDay(
                date,
                _selectedDate,
              );

              final isToday = _isSameDay(
                date,
                DateTime.now(),
              );

              final dayEvents = _events.where((event) {
                return _isSameDay(
                  event.date,
                  date,
                );
              }).toList();

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _selectDate(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _primaryGreen
                        : isToday
                        ? const Color(0xFFE8F5E9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: isToday && !isSelected
                        ? Border.all(
                      color: const Color(0xFFA5D6A7),
                    )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : _textPrimary,
                          fontSize: 12,
                          fontWeight: isToday || isSelected
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      if (dayEvents.isNotEmpty)
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: dayEvents
                              .take(3)
                              .map(
                                (event) => Container(
                              width: 4,
                              height: 4,
                              margin:
                              const EdgeInsets.symmetric(
                                horizontal: 1,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : _categoryColor(
                                  event.category,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },
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
            selectedColor: const Color(0xFFE8F5E9),
            side: BorderSide(
              color: selected
                  ? const Color(0xFFA5D6A7)
                  : const Color(0xFFE3E9E4),
            ),
            labelStyle: TextStyle(
              color: selected
                  ? _primaryGreen
                  : _textSecondary,
              fontSize: 10.5,
              fontWeight: selected
                  ? FontWeight.w900
                  : FontWeight.w600,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scheduled Activities',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatFullDate(_selectedDate),
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_selectedDateEvents.length} event${_selectedDateEvents.length == 1 ? '' : 's'}',
            style: const TextStyle(
              color: _primaryGreen,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventList() {
    final events = _selectedDateEvents;

    if (events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 36,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE3E9E4),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.event_available_rounded,
              color: Color(0xFF9EAAA1),
              size: 45,
            ),
            const SizedBox(height: 12),
            const Text(
              'No activities scheduled',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Select another date or add a new farm event.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: _showAddEventSheet,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'Add Event',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: events.map((event) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Dismissible(
            key: ValueKey(event.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 22),
              decoration: BoxDecoration(
                color: const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) {
              _deleteEvent(event);
            },
            child: _eventCard(event),
          ),
        );
      }).toList(),
    );
  }

  Widget _eventCard(FarmCalendarEvent event) {
    final categoryColor = _categoryColor(
      event.category,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _toggleCompleted(event),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: event.isCompleted
                    ? const Color(0xFFE8F5E9)
                    : categoryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                event.isCompleted
                    ? Icons.check_circle_rounded
                    : _categoryIcon(event.category),
                color: event.isCompleted
                    ? _primaryGreen
                    : categoryColor,
                size: 23,
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: TextStyle(
                          color: event.isCompleted
                              ? _textSecondary
                              : _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          decoration: event.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    _priorityBadge(event.priority),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  event.description,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _smallBadge(
                      icon: _categoryIcon(event.category),
                      label: event.category,
                      color: categoryColor,
                    ),
                    if (event.relatedItem != null)
                      _smallBadge(
                        icon: Icons.link_rounded,
                        label: event.relatedItem!,
                        color: const Color(0xFF546E7A),
                      ),
                    _smallBadge(
                      icon: event.isCompleted
                          ? Icons.check_rounded
                          : Icons.schedule_rounded,
                      label: event.isCompleted
                          ? 'Completed'
                          : 'Pending',
                      color: event.isCompleted
                          ? _primaryGreen
                          : const Color(0xFFF57C00),
                    ),
                  ],
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'complete') {
                _toggleCompleted(event);
              } else if (value == 'delete') {
                _deleteEvent(event);
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'complete',
                  child: Row(
                    children: [
                      Icon(
                        event.isCompleted
                            ? Icons.undo_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        event.isCompleted
                            ? 'Mark Pending'
                            : 'Mark Complete',
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFC62828),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  Widget _priorityBadge(String priority) {
    Color color;
    Color background;

    switch (priority) {
      case 'High':
        color = const Color(0xFFC62828);
        background = const Color(0xFFFFEBEE);
        break;
      case 'Medium':
        color = const Color(0xFFEF6C00);
        background = const Color(0xFFFFF3E0);
        break;
      default:
        color = const Color(0xFF2E7D32);
        background = const Color(0xFFE8F5E9);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _smallBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Crops':
        return const Color(0xFF2E7D32);
      case 'Livestock':
        return const Color(0xFF6A1B9A);
      case 'Machinery':
        return const Color(0xFF455A64);
      case 'Tasks':
        return const Color(0xFFF57C00);
      case 'Market':
        return const Color(0xFF1565C0);
      case 'Finance':
        return const Color(0xFF00838F);
      default:
        return _primaryGreen;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Crops':
        return Icons.eco_rounded;
      case 'Livestock':
        return Icons.pets_rounded;
      case 'Machinery':
        return Icons.agriculture_rounded;
      case 'Tasks':
        return Icons.task_alt_rounded;
      case 'Market':
        return Icons.storefront_rounded;
      case 'Finance':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  String _formatFullDate(DateTime date) {
    return '${_dayName(date.weekday)}, '
        '${date.day} '
        '${_monthName(date.month)} '
        '${date.year}';
  }

  String _dayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[weekday - 1];
  }

  String _monthName(int month) {
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

    return months[month - 1];
  }
}

class _WeekDay extends StatelessWidget {
  final String label;

  const _WeekDay(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF78837B),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}