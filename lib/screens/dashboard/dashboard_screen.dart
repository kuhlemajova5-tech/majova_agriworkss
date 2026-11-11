import 'package:flutter/material.dart';
import '../../widgets/farm_weather_card.dart';
import '../farm/farm_screen.dart';
import '../analytics/analytics_screen.dart';
import '../crops/crop_screen.dart';
import '../finance/finance_screen.dart';
import '../inventory/inventory_screen.dart';
import '../livestock/livestock_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../tasks/task_screen.dart';
import '../tractors/tractor_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notification_screen.dart';
import '../weather/weather_screen.dart';
import '../calender/farm_calendar_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color backgroundColor = Color(0xFFF4F7F4);
  static const Color textColor = Color(0xFF17201A);
  static const Color mutedColor = Color(0xFF66736A);
  static const Color borderColor = Color(0xFFE6EBE7);

  void _openManagementModule(String title) {
    Widget? screen;

    switch (title) {
      case 'Crops':
        screen = const CropScreen();
        break;
      case 'Livestock':
        screen = const LivestockScreen();
        break;
      case 'Tractors':
        screen = const TractorScreen();
        break;
      case 'Tasks':
        screen = const TaskScreen();
        break;
      case 'Inventory':
        screen = const InventoryScreen();
        break;
      case 'Finance':
        screen = const FinanceScreen();
        break;
    }

    if (screen == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen!),
    );
  }

  void _openMarketplace() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MarketplaceScreen(),
      ),
    );
  }

  void _openAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AnalyticsScreen(),
      ),
    );
  }

  void _openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FarmCalendarScreen(),
      ),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationScreen(),
      ),
    );
  }

  void _openWeather() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WeatherScreen(),
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildWeatherCard(),
              const SizedBox(height: 28),

              _buildSectionTitle('Farm Overview'),
              const SizedBox(height: 15),
              _buildOverviewGrid(),

              const SizedBox(height: 30),

              Row(
                children: [
                  const Expanded(
                    child: _SectionHeading(
                      title: 'Farm Management',
                    ),
                  ),
                  TextButton(
                    onPressed: _openCalendar,
                    child: const Text(
                      'Calendar',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              _buildManagementGrid(),

              const SizedBox(height: 30),

              Row(
                children: [
                  const Expanded(
                    child: _SectionHeading(
                      title: "Today's Tasks",
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        _openManagementModule('Tasks'),
                    child: const Text(
                      'View Tasks',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              _buildTaskCard(
                icon: Icons.water_drop_outlined,
                title: 'Water Spinach',
                subtitle: 'Field A • 08:00',
                status: 'Today',
                onTap: () => _openManagementModule('Tasks'),
              ),

              const SizedBox(height: 12),

              _buildTaskCard(
                icon: Icons.agriculture_outlined,
                title: 'Inspect Tractor',
                subtitle: 'MF 265 • Maintenance check',
                status: 'Today',
                onTap: () => _openManagementModule('Tasks'),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  const Expanded(
                    child: _SectionHeading(
                      title: 'Community Market',
                    ),
                  ),
                  TextButton(
                    onPressed: _openMarketplace,
                    child: const Text(
                      'View Market',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              _buildMarketCard(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: const Color(0xFF14251A),
        indicatorColor: const Color(0xFF285532),
        labelBehavior:
        NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          if (index == 0) {
            setState(() => selectedIndex = 0);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FarmScreen(),
              ),
            );
          } else if (index == 2) {
            _openMarketplace();
          } else if (index == 3) {
            _openAnalytics();
          } else if (index == 4) {
            _openProfile();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.agriculture_outlined),
            selectedIcon: Icon(Icons.agriculture_rounded),
            label: 'Farm',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return _SectionHeading(title: title);
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.agriculture_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Majova AgriWorks',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _openNotifications,
          icon: const Badge(
            smallSize: 9,
            child: Icon(
              Icons.notifications_none_rounded,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openWeather,
        borderRadius: BorderRadius.circular(28),
        child: const FarmWeatherCard(),
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
      // A lower ratio gives each card more height.
      childAspectRatio: 1.4,
      children: [
        _overviewCard('3', 'Active Crops', Icons.eco_rounded),
        _overviewCard('42', 'Livestock', Icons.pets_rounded),
        _overviewCard('4', 'Fields', Icons.landscape_rounded),
        _overviewCard('5', 'Tasks Today', Icons.task_alt_rounded),
      ],
    );
  }

  Widget _overviewCard(
      String value,
      String label,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: primaryGreen,
              size: 23,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: mutedColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementGrid() {
    final items = <Map<String, dynamic>>[
      {'title': 'Crops', 'icon': Icons.eco_rounded},
      {'title': 'Livestock', 'icon': Icons.pets_rounded},
      {'title': 'Tractors', 'icon': Icons.agriculture_rounded},
      {'title': 'Tasks', 'icon': Icons.task_alt_rounded},
      {'title': 'Inventory', 'icon': Icons.inventory_2_outlined},
      {
        'title': 'Finance',
        'icon': Icons.account_balance_wallet_outlined,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final title = item['title'] as String;
        final icon = item['icon'] as IconData;

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openManagementModule(title),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      icon,
                      color: primaryGreen,
                      size: 27,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: primaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketCard() {
    return Material(
      color: const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _openMarketplace,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFFFFECB3),
                child: Icon(
                  Icons.storefront_rounded,
                  color: Color(0xFFF57F17),
                  size: 28,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sell Your Produce',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Connect farm produce and livestock with local buyers and communities.',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: mutedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Color(0xFF17201A),
      ),
    );
  }
}
