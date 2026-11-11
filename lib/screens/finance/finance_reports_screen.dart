
import 'package:flutter/material.dart';
import '../../models/finance_transaction.dart';

class FinanceReportsScreen extends StatelessWidget {
  final double income;
  final double expenses;
  final double balance;
  final List<FinanceTransaction> incomeRecords;
  final List<FinanceTransaction> expenseRecords;

  const FinanceReportsScreen({
    super.key,
    required this.income,
    required this.expenses,
    required this.balance,
    required this.incomeRecords,
    required this.expenseRecords,
  });

  static const Color farmGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color background = Color(0xFFF4F7F4);

  String money(double amount) => 'R${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Financial Reports',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: farmGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Farm Financial Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Review your recorded farm income and expenses.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          _reportCard(
            title: 'Total Income',
            amount: money(income),
            icon: Icons.trending_up,
            color: Colors.green,
          ),
          _reportCard(
            title: 'Total Expenses',
            amount: money(expenses),
            icon: Icons.trending_down,
            color: Colors.red,
          ),
          _reportCard(
            title: 'Net Balance',
            amount: money(balance),
            icon: Icons.account_balance_wallet,
            color: balance >= 0 ? farmGreen : Colors.red,
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Record Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _summaryRow(
                    'Sales / Income records',
                    incomeRecords.length.toString(),
                  ),
                  const Divider(),
                  _summaryRow(
                    'Expense records',
                    expenseRecords.length.toString(),
                  ),
                  const Divider(),
                  _summaryRow(
                    'Total transactions',
                    (incomeRecords.length + expenseRecords.length).toString(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'This report is based on the transactions currently recorded '
                  'in the app. Keep your records updated for a more accurate '
                  'picture of your farm finances.',
              style: TextStyle(color: Colors.black87, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            amount,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
