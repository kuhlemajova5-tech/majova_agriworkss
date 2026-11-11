
import 'package:flutter/material.dart';

import '../../models/finance_transaction.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';
import 'transaction_details_screen.dart';
import 'finance_reports_screen.dart';
import 'farm_budget_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  static const Color farmGreen = Color(0xFF1B5E20);
  static const Color darkGreen = Color(0xFF0B3D1B);
  static const Color mediumGreen = Color(0xFF43A047);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color background = Color(0xFFF4F7F4);

  // All finance features use this shared transaction list.
  final List<FinanceTransaction> transactions = [];

  String selectedFilter = 'All';
  String searchQuery = '';

  bool _isIncome(FinanceTransaction transaction) {
    return transaction.type.toLowerCase().trim() == 'income';
  }

  bool _isExpense(FinanceTransaction transaction) {
    return transaction.type.toLowerCase().trim() == 'expense';
  }

  double get totalIncome {
    return transactions
        .where(_isIncome)
        .fold<double>(0.0, (total, item) => total + item.amount);
  }

  double get totalExpenses {
    return transactions
        .where(_isExpense)
        .fold<double>(0.0, (total, item) => total + item.amount);
  }

  double get balance => totalIncome - totalExpenses;

  List<FinanceTransaction> get incomeTransactions =>
      transactions.where(_isIncome).toList();

  List<FinanceTransaction> get expenseTransactions =>
      transactions.where(_isExpense).toList();

  List<FinanceTransaction> get filteredTransactions {
    Iterable<FinanceTransaction> result = transactions;

    if (selectedFilter == 'Income') {
      result = result.where(_isIncome);
    } else if (selectedFilter == 'Expenses') {
      result = result.where(_isExpense);
    }

    final query = searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((transaction) {
        return transaction.title.toLowerCase().contains(query) ||
            transaction.category.toLowerCase().contains(query) ||
            transaction.type.toLowerCase().contains(query);
      });
    }

    return result.toList();
  }

  String _money(double amount) => 'R ${amount.toStringAsFixed(2)}';

  Future<void> _addTransaction() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );

    if (!mounted) return;

    if (result is FinanceTransaction) {
      setState(() {
        transactions.add(result);
      });
    }
  }

  Future<void> _editTransaction(
      FinanceTransaction transaction,
      ) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(
          transaction: transaction,
        ),
      ),
    );

    if (!mounted) return;

    if (result is FinanceTransaction) {
      setState(() {
        final index = transactions.indexOf(transaction);

        if (index != -1) {
          transactions[index] = result;
        }
      });
    }
  }

  Future<void> _showTransactionDetails(
      FinanceTransaction transaction,
      ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailsScreen(
          transaction: transaction,
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(
      FinanceTransaction transaction,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Delete Transaction',
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          'Are you sure you want to delete this transaction?',
          style: TextStyle(color: Colors.black87),
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

    if (!mounted || confirmed != true) return;

    setState(() {
      transactions.remove(transaction);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction deleted.'),
      ),
    );
  }

  Future<void> _openFinancialReports() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => FinanceReportsScreen(
          income: totalIncome,
          expenses: totalExpenses,
          balance: balance,
          incomeRecords: incomeTransactions,
          expenseRecords: expenseTransactions,
        ),
      ),
    );
  }

  Future<void> _openFarmBudget() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => FarmBudgetScreen(
          transactions: transactions,
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _money(amount),
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
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

  Widget _managementButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: CircleAvatar(
          backgroundColor: lightGreen,
          child: Icon(icon, color: farmGreen),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: farmGreen,
        ),
        onTap: onPressed,
      ),
    );
  }

  Widget _transactionCard(FinanceTransaction transaction) {
    final isIncome = _isIncome(transaction);
    final color = isIncome ? farmGreen : Colors.red;

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? lightGreen
              : const Color(0xFFFFEBEE),
          child: Icon(
            isIncome ? Icons.trending_up : Icons.trending_down,
            color: color,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${transaction.category}\n${transaction.formattedDate}',
            style: const TextStyle(
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black54),
          onSelected: (value) {
            if (value == 'details') {
              _showTransactionDetails(transaction);
            } else if (value == 'edit') {
              _editTransaction(transaction);
            } else if (value == 'delete') {
              _deleteTransaction(transaction);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'details',
              child: Text('View Details'),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleTransactions = filteredTransactions;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'Finance Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTransaction,
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [darkGreen, farmGreen, mediumGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 36,
                ),
                SizedBox(height: 12),
                Text(
                  'Farm Financial Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Track your farm income, expenses and budget.',
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _summaryCard(
                title: 'Income',
                amount: totalIncome,
                icon: Icons.trending_up,
                color: farmGreen,
              ),
              _summaryCard(
                title: 'Expenses',
                amount: totalExpenses,
                icon: Icons.trending_down,
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: lightGreen,
                child: Icon(
                  Icons.account_balance,
                  color: balance >= 0 ? farmGreen : Colors.red,
                ),
              ),
              title: const Text(
                'Net Balance',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                _money(balance),
                style: TextStyle(
                  color: balance >= 0 ? farmGreen : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Finance Management',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _managementButton(
            title: 'Sales Records',
            subtitle: 'View recorded farm income',
            icon: Icons.point_of_sale,
            onPressed: () {
              setState(() => selectedFilter = 'Income');
            },
          ),
          _managementButton(
            title: 'Expense Records',
            subtitle: 'View farm operating expenses',
            icon: Icons.receipt_long,
            onPressed: () {
              setState(() => selectedFilter = 'Expenses');
            },
          ),
          _managementButton(
            title: 'Financial Reports',
            subtitle: 'Review income, expenses and balance',
            icon: Icons.bar_chart,
            onPressed: _openFinancialReports,
          ),
          _managementButton(
            title: 'Farm Budget',
            subtitle: 'Plan spending and track your budget',
            icon: Icons.savings_outlined,
            onPressed: _openFarmBudget,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Transactions',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${visibleTransactions.length} records',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            style: const TextStyle(color: Colors.black),
            onChanged: (value) {
              setState(() => searchQuery = value);
            },
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              hintStyle: const TextStyle(color: Colors.black45),
              prefixIcon: const Icon(
                Icons.search,
                color: farmGreen,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['All', 'Income', 'Expenses'].map((filter) {
              final selected = selectedFilter == filter;

              return ChoiceChip(
                label: Text(filter),
                selected: selected,
                selectedColor: lightGreen,
                labelStyle: TextStyle(
                  color: selected ? farmGreen : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (value) {
                  setState(() => selectedFilter = filter);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          if (visibleTransactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: farmGreen,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No transactions found',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Add a farm sale or expense to start tracking your finances.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          else
            ...visibleTransactions.map(_transactionCard),
        ],
      ),
    );
  }
}
