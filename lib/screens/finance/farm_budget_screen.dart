
import 'package:flutter/material.dart';
import '../../models/finance_transaction.dart';

class FarmBudgetScreen extends StatefulWidget {
  final List<FinanceTransaction> transactions;

  const FarmBudgetScreen({
    super.key,
    required this.transactions,
  });

  @override
  State<FarmBudgetScreen> createState() => _FarmBudgetScreenState();
}

class _FarmBudgetScreenState extends State<FarmBudgetScreen> {
  static const Color farmGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);

  final TextEditingController budgetController = TextEditingController();

  double? plannedBudget;

  bool _isIncome(FinanceTransaction transaction) {
    return transaction.type.toLowerCase().trim() == 'income';
  }

  double get totalExpenses {
    return widget.transactions
        .where((transaction) => !_isIncome(transaction))
        .fold<double>(
      0.0,
          (total, transaction) => total + transaction.amount,
    );
  }

  double? get remainingBudget {
    if (plannedBudget == null) return null;
    return plannedBudget! - totalExpenses;
  }

  void _calculateBudget() {
    final enteredBudget = double.tryParse(
      budgetController.text.trim().replaceAll(',', ''),
    );

    if (enteredBudget == null || enteredBudget < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid budget amount.'),
        ),
      );
      return;
    }

    setState(() {
      plannedBudget = enteredBudget;
    });

    FocusScope.of(context).unfocus();
  }

  String _money(double amount) {
    return 'R ${amount.toStringAsFixed(2)}';
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = remainingBudget;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text(
          'Farm Budget',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: farmGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: farmGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 38,
                ),
                SizedBox(height: 12),
                Text(
                  'Plan Your Farm Finances',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Set a budget and compare it with your recorded farm expenses.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Enter Your Farm Budget',
            style: TextStyle(
              color: Colors.black,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: budgetController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Planned budget (R)',
              labelStyle: const TextStyle(color: Colors.black54),
              hintText: 'e.g. 10000',
              hintStyle: const TextStyle(color: Colors.black38),
              prefixIcon: const Icon(
                Icons.payments_outlined,
                color: farmGreen,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: farmGreen,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _calculateBudget,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Budget'),
              style: ElevatedButton.styleFrom(
                backgroundColor: farmGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Recorded Expenses',
            style: TextStyle(
              color: Colors.black,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          _amountCard(
            title: 'Total Recorded Expenses',
            amount: _money(totalExpenses),
            icon: Icons.receipt_long,
            color: Colors.red,
          ),

          if (plannedBudget != null) ...[
            _amountCard(
              title: 'Planned Budget',
              amount: _money(plannedBudget!),
              icon: Icons.savings_outlined,
              color: farmGreen,
            ),
            _amountCard(
              title: balance! >= 0
                  ? 'Budget Remaining'
                  : 'Amount Over Budget',
              amount: _money(balance.abs()),
              icon: balance >= 0
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_rounded,
              color: balance >= 0 ? farmGreen : Colors.red,
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: balance >= 0
                    ? lightGreen
                    : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    balance >= 0
                        ? Icons.thumb_up_alt_outlined
                        : Icons.warning_amber_rounded,
                    color: balance >= 0 ? farmGreen : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      balance >= 0
                          ? 'Your recorded expenses are within the planned budget.'
                          : 'Your recorded expenses exceed the planned budget. Review your spending.',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          const Text(
            'Budgeting tip: Include seeds, fertiliser, animal feed, fuel, '
                'repairs, transport and other operating costs when planning '
                'your farming budget.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Note: The budget is temporary and resets when you leave this screen. '
                'It compares your planned budget with expenses currently recorded in the app.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
