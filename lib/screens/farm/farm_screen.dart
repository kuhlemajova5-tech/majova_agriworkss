
import 'package:flutter/material.dart';

import '../crops/crop_screen.dart';
import '../finance/finance_screen.dart';
import '../fields/farm_fields_screen.dart';
import '../inventory/inventory_screen.dart';
import '../livestock/livestock_screen.dart';
import '../location/farm_location_screen.dart';
import '../pest_disease/pest_disease_screen.dart';
import '../tasks/task_screen.dart';
import '../tractors/tractor_screen.dart';

class FarmScreen extends StatelessWidget {
  const FarmScreen({super.key});

  static const Color _primaryGreen = Color(0xFF1B5E20);
  static const Color _darkGreen = Color(0xFF0B3D1B);
  static const Color _mediumGreen = Color(0xFF43A047);
  static const Color _lightGreen = Color(0xFFE8F5E9);
  static const Color _background = Color(0xFFF4F7F4);
  static const Color _textPrimary = Color(0xFF17201A);
  static const Color _textSecondary = Color(0xFF66736A);

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
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
          'Farm Management',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 28),

              const Text(
                'Farm Overview',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Monitor the most important areas of your farm.',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 16),

              _buildOverview(),

              const SizedBox(height: 30),

              const Text(
                'Manage Your Farm',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Select a farming area to view and manage its records.',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 16),

              _buildManagementGrid(context),

              const SizedBox(height: 30),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              _buildQuickActions(context),

              const SizedBox(height: 30),

              _buildFarmTip(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Color(0x33FFFFFF),
            child: Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),

          SizedBox(height: 20),

          Text(
            'Majova Farm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),

          SizedBox(height: 7),

          Text(
            'Manage crops, livestock, machinery, tasks, stock and finances from one place.',
            style: TextStyle(
              color: Color(0xFFD7EED9),
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _buildOverviewCard(
          value: '3',
          label: 'Active Crops',
          icon: Icons.eco_rounded,
        ),
        _buildOverviewCard(
          value: '42',
          label: 'Livestock',
          icon: Icons.pets_rounded,
        ),
        _buildOverviewCard(
          value: '2',
          label: 'Tractors',
          icon: Icons.agriculture_rounded,
        ),
        _buildOverviewCard(
          value: '3',
          label: 'Pending Tasks',
          icon: Icons.pending_actions_rounded,
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: _primaryGreen,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    final modules = [
      _FarmModule(
        title: 'Crops',
        subtitle: 'Planting & harvest',
        icon: Icons.eco_rounded,
        onTap: () {
          _openScreen(
            context,
            const CropScreen(),
          );
        },
      ),
      _FarmModule(
        title: 'Livestock',
        subtitle: 'Animals & health',
        icon: Icons.pets_rounded,
        onTap: () {
          _openScreen(
            context,
            const LivestockScreen(),
          );
        },
      ),
      _FarmModule(
        title: 'Tractors',
        subtitle: 'Machinery & service',
        icon: Icons.agriculture_rounded,
        onTap: () {
          _openScreen(
            context,
            const TractorScreen(),
          );
        },
      ),
      _FarmModule(
        title: 'Tasks',
        subtitle: 'Farm activities',
        icon: Icons.task_alt_rounded,
        onTap: () {
          _openScreen(
            context,
            const TaskScreen(),
          );
        },
      ),
      _FarmModule(
        title: 'Inventory',
        subtitle: 'Stock & supplies',
        icon: Icons.inventory_2_rounded,
        onTap: () {
          _openScreen(
            context,
            const InventoryScreen(),
          );
        },
      ),
      _FarmModule(
        title: 'Finance',
        subtitle: 'Income & expenses',
        icon: Icons.account_balance_wallet_rounded,
        onTap: () {
          _openScreen(
            context,
            const FinanceScreen(),
          );
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        final module = modules[index];

        return InkWell(
          onTap: module.onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE3E9E4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    module.icon,
                    color: _primaryGreen,
                    size: 26,
                  ),
                ),

                const Spacer(),

                Text(
                  module.title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  module.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _buildQuickActionTile(
          icon: Icons.add_circle_outline_rounded,
          title: 'Record Farm Activity',
          subtitle: 'Open Tasks to record or schedule farm work',
          onTap: () {
            _openScreen(
              context,
              const TaskScreen(),
            );
          },
        ),

        const SizedBox(height: 10),

        _buildQuickActionTile(
          icon: Icons.inventory_2_outlined,
          title: 'Check Farm Stock',
          subtitle: 'Review supplies and low-stock inventory',
          onTap: () {
            _openScreen(
              context,
              const InventoryScreen(),
            );
          },
        ),

        const SizedBox(height: 10),

        _buildQuickActionTile(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Record Farm Transaction',
          subtitle: 'Manage farm income and expenses',
          onTap: () {
            _openScreen(
              context,
              const FinanceScreen(),
            );
          },
        ),

        const SizedBox(height: 10),

        _buildQuickActionTile(
          icon: Icons.landscape_outlined,
          title: 'Fields & Planting Planner',
          subtitle: 'Plan fields, crops, planting and harvest dates',
          onTap: () {
            _openScreen(
              context,
              const FarmFieldsScreen(),
            );
          },
        ),

        const SizedBox(height: 10),

        _buildQuickActionTile(
          icon: Icons.location_on_outlined,
          title: 'Farm GPS & Location',
          subtitle: 'View and save the farm GPS location',
          onTap: () {
            _openScreen(
              context,
              const FarmLocationScreen(),
            );
          },
        ),

        const SizedBox(height: 10),

        _buildQuickActionTile(
          icon: Icons.bug_report_outlined,
          title: 'Pest & Disease Records',
          subtitle: 'Track crop problems, treatment and photo evidence',
          onTap: () {
            _openScreen(
              context,
              const PestDiseaseScreen(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE3E9E4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: _primaryGreen,
                size: 23,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: _textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFECB3),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFFF57F17),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm Management Tip',
                  style: TextStyle(
                    color: Color(0xFF5D4A00),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Keep your crop, livestock, machinery, inventory and financial records updated to get more useful farm analytics.',
                  style: TextStyle(
                    color: Color(0xFF6D5B00),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmModule {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _FarmModule({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

