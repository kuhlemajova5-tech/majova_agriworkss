class FinanceTransaction {
  final String title;
  final String type;
  final String category;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  final String referenceNumber;
  final String relatedTo;
  final String description;

  const FinanceTransaction({
    required this.title,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.relatedTo,
    this.description = '',
  });

  bool get isIncome => type == 'Income';

  bool get isExpense => type == 'Expense';

  String get amountText {
    return 'R${amount.toStringAsFixed(2)}';
  }

  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String get signedAmountText {
    if (isIncome) {
      return '+R${amount.toStringAsFixed(2)}';
    }

    return '-R${amount.toStringAsFixed(2)}';
  }
}