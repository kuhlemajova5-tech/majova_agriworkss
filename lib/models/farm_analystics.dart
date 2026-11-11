class FarmAnalytics {
  final int activeCrops;
  final int totalLivestock;
  final int totalTractors;
  final int pendingTasks;
  final int completedTasks;
  final int inventoryItems;
  final int lowStockItems;
  final int marketplaceListings;

  final double totalIncome;
  final double totalExpenses;
  final double marketplaceValue;

  const FarmAnalytics({
    required this.activeCrops,
    required this.totalLivestock,
    required this.totalTractors,
    required this.pendingTasks,
    required this.completedTasks,
    required this.inventoryItems,
    required this.lowStockItems,
    required this.marketplaceListings,
    required this.totalIncome,
    required this.totalExpenses,
    required this.marketplaceValue,
  });

  double get netProfit => totalIncome - totalExpenses;

  int get totalTasks => pendingTasks + completedTasks;

  double get taskCompletionRate {
    if (totalTasks == 0) {
      return 0.0;
    }

    return completedTasks / totalTasks;
  }

  double get taskCompletionPercentage => taskCompletionRate * 100;

  String get incomeText => 'R${totalIncome.toStringAsFixed(2)}';

  String get expensesText => 'R${totalExpenses.toStringAsFixed(2)}';

  String get netProfitText => 'R${netProfit.toStringAsFixed(2)}';

  String get marketplaceValueText =>
      'R${marketplaceValue.toStringAsFixed(2)}';

  String get taskCompletionText =>
      '${taskCompletionPercentage.toStringAsFixed(0)}%';

  bool get isProfitable => netProfit >= 0;

  bool get hasLowStock => lowStockItems > 0;
}