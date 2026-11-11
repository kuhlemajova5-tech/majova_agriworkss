import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color _primaryGreen = Color(0xFF1B5E20);
  static const Color _darkGreen = Color(0xFF0B3D1B);
  static const Color _mediumGreen = Color(0xFF43A047);
  static const Color _background = Color(0xFFF4F7F4);
  static const Color _textPrimary = Color(0xFF17201A);
  static const Color _textSecondary = Color(0xFF66736A);

  String selectedFilter = 'All';

  final List<_FarmNotification> notifications = [
    _FarmNotification(
      title: 'Water Spinach Today',
      message:
      'Field A spinach is scheduled for watering this morning.',
      time: '08:00',
      category: 'Tasks',
      icon: Icons.water_drop_rounded,
      iconColor: Color(0xFF1565C0),
      iconBackground: Color(0xFFE3F2FD),
      isRead: false,
    ),
    _FarmNotification(
      title: 'Low Inventory Alert',
      message:
      'NPK fertiliser stock is running low. Consider restocking soon.',
      time: '09:15',
      category: 'Inventory',
      icon: Icons.inventory_2_rounded,
      iconColor: Color(0xFFF57F17),
      iconBackground: Color(0xFFFFF3E0),
      isRead: false,
    ),
    _FarmNotification(
      title: 'MF 265 Maintenance',
      message:
      'Your Massey Ferguson MF 265 is due for a maintenance inspection.',
      time: '10:30',
      category: 'Machinery',
      icon: Icons.agriculture_rounded,
      iconColor: Color(0xFF6A1B9A),
      iconBackground: Color(0xFFF3E5F5),
      isRead: false,
    ),
    _FarmNotification(
      title: 'Livestock Health Check',
      message:
      'Remember to inspect the sheep flock and update health records.',
      time: 'Yesterday',
      category: 'Livestock',
      icon: Icons.pets_rounded,
      iconColor: Color(0xFF5D4037),
      iconBackground: Color(0xFFEFEBE9),
      isRead: true,
    ),
    _FarmNotification(
      title: 'Cabbage Crop Update',
      message:
      'Review cabbage growth progress and record the latest field activity.',
      time: 'Yesterday',
      category: 'Crops',
      icon: Icons.eco_rounded,
      iconColor: Color(0xFF2E7D32),
      iconBackground: Color(0xFFE8F5E9),
      isRead: true,
    ),
    _FarmNotification(
      title: 'Marketplace Reminder',
      message:
      'Review your available produce listings and update quantities if required.',
      time: '2 days ago',
      category: 'Market',
      icon: Icons.storefront_rounded,
      iconColor: Color(0xFF00838F),
      iconBackground: Color(0xFFE0F7FA),
      isRead: true,
    ),
  ];

  List<_FarmNotification> get filteredNotifications {
    if (selectedFilter == 'All') {
      return notifications;
    }

    if (selectedFilter == 'Unread') {
      return notifications.where((item) => !item.isRead).toList();
    }

    return notifications
        .where((item) => item.category == selectedFilter)
        .toList();
  }

  int get unreadCount {
    return notifications.where((item) => !item.isRead).length;
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in notifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _markAsRead(_FarmNotification notification) {
    if (notification.isRead) {
      return;
    }

    setState(() {
      notification.isRead = true;
    });
  }

  void _deleteNotification(_FarmNotification notification) {
    setState(() {
      notifications.remove(notification);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification removed.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAllNotifications() {
    if (notifications.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Clear Notifications?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'This will remove all notifications currently displayed in the app.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  notifications.clear();
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
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
          'Farm Alerts',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'read') {
                _markAllAsRead();
              }

              if (value == 'clear') {
                _clearAllNotifications();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all_rounded),
                      SizedBox(width: 12),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFC62828),
                      ),
                      SizedBox(width: 12),
                      Text('Clear notifications'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        0,
                      ),
                      child: _buildHeader(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        24,
                        20,
                        0,
                      ),
                      child: _buildSummary(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 22,
                        bottom: 16,
                      ),
                      child: _buildFilters(),
                    ),
                  ),

                  if (filteredNotifications.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        35,
                      ),
                      sliver: SliverList.separated(
                        itemCount: filteredNotifications.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          final notification =
                          filteredNotifications[index];

                          return _buildNotificationCard(
                            notification,
                          );
                        },
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 19,
                        minHeight: 19,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD54F),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Color(0xFF3E3300),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Farm Alerts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  unreadCount == 0
                      ? 'You are all caught up.'
                      : '$unreadCount unread farm alerts need your attention.',
                  style: const TextStyle(
                    color: Color(0xFFD7EED9),
                    fontSize: 12.5,
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
            value: '${notifications.length}',
            label: 'Total Alerts',
            icon: Icons.notifications_none_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            value: '$unreadCount',
            label: 'Unread',
            icon: Icons.mark_email_unread_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            value: '${notifications.length - unreadCount}',
            label: 'Read',
            icon: Icons.done_all_rounded,
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
        horizontal: 8,
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
            size: 22,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    const filters = [
      'All',
      'Unread',
      'Tasks',
      'Inventory',
      'Crops',
      'Livestock',
      'Machinery',
      'Market',
    ];

    return SizedBox(
      height: 39,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) {
              setState(() {
                selectedFilter = filter;
              });
            },
            selectedColor: _primaryGreen,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? _primaryGreen
                  : const Color(0xFFDDE4DE),
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : _textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      _FarmNotification notification,
      ) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        _deleteNotification(notification);
      },
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
          size: 27,
        ),
      ),
      child: InkWell(
        onTap: () {
          _markAsRead(notification);
          _showNotificationDetails(notification);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : const Color(0xFFF8FFF8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notification.isRead
                  ? const Color(0xFFE3E9E4)
                  : const Color(0xFFA5D6A7),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: notification.iconBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 25,
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
                            notification.title,
                            style: TextStyle(
                              color: _textPrimary,
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w700
                                  : FontWeight.w900,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            notification.category,
                            style: const TextStyle(
                              color: _primaryGreen,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const Spacer(),

                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: Color(0xFF98A19A),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          notification.time,
                          style: const TextStyle(
                            color: Color(0xFF98A19A),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: _primaryGreen,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Farm Alerts',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'There are no notifications in this category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetails(
      _FarmNotification notification,
      ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              8,
              22,
              30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: notification.iconBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        notification.icon,
                        color: notification.iconColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  notification.message,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      color: _primaryGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      notification.category,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.schedule_rounded,
                      color: _textSecondary,
                      size: 17,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      notification.time,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Done',
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
  }
}

class _FarmNotification {
  static int _nextId = 0;

  final int id;
  final String title;
  final String message;
  final String time;
  final String category;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  bool isRead;

  _FarmNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.isRead,
  }) : id = _nextId++;
}