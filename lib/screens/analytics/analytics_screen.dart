import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const Color _primaryGreen = Color(0xFF1B5E20);
  static const Color _darkGreen = Color(0xFF0B3D1B);
  static const Color _mediumGreen = Color(0xFF43A047);
  static const Color _lightGreen = Color(0xFFE8F5E9);
  static const Color _background = Color(0xFFF4F7F4);
  static const Color _textPrimary = Color(0xFF17201A);
  static const Color _textSecondary = Color(0xFF66736A);

  static const int activeCrops = 3;
  static const int totalLivestock = 42;
  static const int totalTractors = 2;
  static const int pendingTasks = 3;
  static const int completedTasks = 2;
  static const int inventoryItems = 5;
  static const int lowStockItems = 2;
  static const int marketplaceListings = 5;

  static const double totalIncome = 9900;
  static const double totalExpenses = 4940;
  static const double marketplaceValue = 18260;

  double get netProfit => totalIncome - totalExpenses;

  int get totalTasks => pendingTasks + completedTasks;

  double get taskCompletionRate {
    if (totalTasks == 0) {
      return 0;
    }
    return completedTasks / totalTasks;
  }

  String get incomeText => 'R${totalIncome.toStringAsFixed(2)}';

  String get expensesText => 'R${totalExpenses.toStringAsFixed(2)}';

  String get netProfitText => 'R${netProfit.toStringAsFixed(2)}';

  String get marketplaceValueText =>
      'R${marketplaceValue.toStringAsFixed(2)}';

  String get taskCompletionText =>
      '${(taskCompletionRate * 100).toStringAsFixed(0)}%';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Farm Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Analytics',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Farm analytics refreshed.'),
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnalyticsHeader(),
              const SizedBox(height: 28),

              _buildSectionHeading(
                title: 'Financial Performance',
                subtitle: 'Track farm income, expenses and balance',
                icon: Icons.account_balance_wallet_outlined,
              ),

              const SizedBox(height: 14),

              _buildFinancialOverview(),

              const SizedBox(height: 18),

              _buildIncomeExpenseComparison(),

              const SizedBox(height: 30),

              _buildSectionHeading(
                title: 'Farm Overview',
                subtitle: 'A snapshot of your farming operations',
                icon: Icons.dashboard_outlined,
              ),

              const SizedBox(height: 14),

              _buildFarmOverviewGrid(),

              const SizedBox(height: 30),

              _buildSectionHeading(
                title: 'Task Performance',
                subtitle: 'Monitor completion of farm activities',
                icon: Icons.task_alt_rounded,
              ),

              const SizedBox(height: 14),

              _buildTaskPerformance(),

              const SizedBox(height: 30),

              _buildSectionHeading(
                title: 'Marketplace Performance',
                subtitle: 'Estimated value of available farm products',
                icon: Icons.storefront_outlined,
              ),

              const SizedBox(height: 14),

              _buildMarketplaceCard(),

              const SizedBox(height: 30),

              _buildSectionHeading(
                title: 'Farm Insights',
                subtitle: 'Important information from your farm data',
                icon: Icons.auto_graph_rounded,
              ),

              const SizedBox(height: 14),

              _buildInsights(),

              const SizedBox(height: 24),

              _buildDemoNotice(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsHeader() {
    final profitable = netProfit >= 0;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Majova Farm Intelligence',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Understand your farm performance and make better farming decisions.',
            style: TextStyle(
              color: Color(0xFFD7EED9),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  profitable
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  profitable
                      ? 'Positive farm balance'
                      : 'Expenses exceed income',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview() {
    final profitable = netProfit >= 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                title: 'Income',
                amount: incomeText,
                icon: Icons.south_west_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBackground: const Color(0xFFE8F5E9),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinancialCard(
                title: 'Expenses',
                amount: expensesText,
                icon: Icons.north_east_rounded,
                iconColor: const Color(0xFFC62828),
                iconBackground: const Color(0xFFFFEBEE),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: profitable
                ? const Color(0xFF123E22)
                : const Color(0xFF7F1D1D),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  profitable
                      ? Icons.account_balance_wallet_rounded
                      : Icons.warning_amber_rounded,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Net Farm Balance',
                      style: TextStyle(
                        color: Color(0xFFC8E6C9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      netProfitText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                profitable
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseComparison() {
    final maximum =
    totalIncome > totalExpenses ? totalIncome : totalExpenses;

    final incomeProgress =
    maximum == 0 ? 0.0 : totalIncome / maximum;

    final expenseProgress =
    maximum == 0 ? 0.0 : totalExpenses / maximum;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Income vs Expenses',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),

          const SizedBox(height: 20),

          _buildPerformanceBar(
            title: 'Income',
            amount: incomeText,
            progress: incomeProgress,
          ),

          const SizedBox(height: 20),

          _buildPerformanceBar(
            title: 'Expenses',
            amount: expensesText,
            progress: expenseProgress,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBar({
    required String title,
    required String amount,
    required double progress,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFFE8EDE9),
            color: _primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildFarmOverviewGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _buildStatCard(
          title: 'Active Crops',
          value: '$activeCrops',
          icon: Icons.eco_outlined,
        ),
        _buildStatCard(
          title: 'Livestock',
          value: '$totalLivestock',
          icon: Icons.pets_outlined,
        ),
        _buildStatCard(
          title: 'Tractors',
          value: '$totalTractors',
          icon: Icons.agriculture_outlined,
        ),
        _buildStatCard(
          title: 'Inventory',
          value: '$inventoryItems',
          icon: Icons.inventory_2_outlined,
        ),
        _buildStatCard(
          title: 'Market Listings',
          value: '$marketplaceListings',
          icon: Icons.storefront_outlined,
        ),
        _buildStatCard(
          title: 'Low Stock',
          value: '$lowStockItems',
          icon: Icons.warning_amber_rounded,
          warning: lowStockItems > 0,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    bool warning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: warning
              ? const Color(0xFFFFD180)
              : const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: warning
                      ? const Color(0xFFFFF3E0)
                      : _lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: warning
                      ? const Color(0xFFEF6C00)
                      : _primaryGreen,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: warning
                      ? const Color(0xFFEF6C00)
                      : _textPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskPerformance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: _primaryGreen,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Task Completion',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedTasks of $totalTasks tasks completed',
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                taskCompletionText,
                style: const TextStyle(
                  color: _primaryGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: taskCompletionRate,
              minHeight: 12,
              backgroundColor: const Color(0xFFE8EDE9),
              color: _mediumGreen,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildSmallTaskStat(
                  label: 'Completed',
                  value: '$completedTasks',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallTaskStat(
                  label: 'Pending',
                  value: '$pendingTasks',
                  icon: Icons.pending_actions_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTaskStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: _primaryGreen,
            size: 21,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF1F8E9),
            Color(0xFFE8F5E9),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFC8E6C9),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: _primaryGreen,
              size: 29,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '$marketplaceListings Product Listings',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Estimated marketplace value',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  marketplaceValueText,
                  style: const TextStyle(
                    color: _primaryGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Column(
      children: [
        _buildInsightTile(
          icon: Icons.trending_up_rounded,
          title: 'Positive Financial Position',
          description:
          'The farm currently has a positive balance of $netProfitText.',
          warning: false,
        ),

        const SizedBox(height: 10),

        _buildInsightTile(
          icon: Icons.inventory_2_outlined,
          title: 'Inventory Attention Needed',
          description:
          '$lowStockItems inventory items are currently below their recommended stock level.',
          warning: true,
        ),

        const SizedBox(height: 10),

        _buildInsightTile(
          icon: Icons.task_alt_rounded,
          title: 'Farm Task Progress',
          description:
          '$taskCompletionText of recorded farm tasks have been completed.',
          warning: false,
        ),

        const SizedBox(height: 10),

        _buildInsightTile(
          icon: Icons.storefront_outlined,
          title: 'Marketplace Activity',
          description:
          '$marketplaceListings products are recorded with an estimated value of $marketplaceValueText.',
          warning: false,
        ),
      ],
    );
  }

  Widget _buildInsightTile({
    required IconData icon,
    required String title,
    required String description,
    required bool warning,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: warning
              ? const Color(0xFFFFD180)
              : const Color(0xFFE3E9E4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: warning
                  ? const Color(0xFFFFF3E0)
                  : _lightGreen,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: warning
                  ? const Color(0xFFEF6C00)
                  : _primaryGreen,
              size: 22,
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
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12.5,
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

  Widget _buildDemoNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFECB3),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFF57F17),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Analytics currently uses demonstration farm data. '
                  'Later, these values will be calculated automatically from '
                  'crops, livestock, finance, inventory, tasks and marketplace records.',
              style: TextStyle(
                color: Color(0xFF6D5B00),
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: _lightGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: _primaryGreen,
            size: 22,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}