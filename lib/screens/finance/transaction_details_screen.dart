import 'package:flutter/material.dart';

import '../../models/finance_transaction.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final FinanceTransaction transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final bool income = transaction.isIncome;

    final Color transactionColor = income
        ? const Color(0xFF1B5E20)
        : const Color(0xFFC62828);

    final Color transactionBackground = income
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: const Text(
          'Transaction Details',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Color(0xFF17201A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          15,
          20,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionHeader(
              income,
              transactionColor,
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Transaction Information',
              Icons.receipt_long_outlined,
            ),

            const SizedBox(height: 12),

            _buildDetailsCard(
              children: [
                _buildDetailRow(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  value: transaction.category,
                ),
                _buildDivider(),
                _buildDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Transaction Date',
                  value: transaction.formattedDate,
                ),
                _buildDivider(),
                _buildDetailRow(
                  icon: income
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  label: 'Transaction Type',
                  value: transaction.type,
                  valueColor: transactionColor,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Payment Information',
              Icons.payments_outlined,
            ),

            const SizedBox(height: 12),

            _buildDetailsCard(
              children: [
                _buildDetailRow(
                  icon: Icons.wallet_outlined,
                  label: 'Payment Method',
                  value: transaction.paymentMethod,
                ),
                _buildDivider(),
                _buildDetailRow(
                  icon: Icons.tag_rounded,
                  label: 'Reference Number',
                  value:
                  transaction.referenceNumber.trim().isEmpty
                      ? 'Not recorded'
                      : transaction.referenceNumber,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Farm Information',
              Icons.agriculture_outlined,
            ),

            const SizedBox(height: 12),

            _buildDetailsCard(
              children: [
                _buildDetailRow(
                  icon: Icons.link_rounded,
                  label: 'Related To',
                  value: transaction.relatedTo.trim().isEmpty
                      ? 'Not recorded'
                      : transaction.relatedTo,
                ),
              ],
            ),

            if (transaction.description.trim().isNotEmpty) ...[
              const SizedBox(height: 24),

              _buildSectionTitle(
                'Description',
                Icons.notes_rounded,
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE3E9E4),
                  ),
                ),
                child: Text(
                  transaction.description,
                  style: const TextStyle(
                    color: Color(0xFF4F5D53),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: transactionBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: income
                      ? const Color(0xFFA5D6A7)
                      : const Color(0xFFEF9A9A),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: income
                          ? const Color(0xFFC8E6C9)
                          : const Color(0xFFFFCDD2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      income
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: transactionColor,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          income
                              ? 'Income Transaction'
                              : 'Expense Transaction',
                          style: TextStyle(
                            color: transactionColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          income
                              ? 'This transaction contributes to farm income.'
                              : 'This transaction contributes to farm operating expenses.',
                          style: const TextStyle(
                            color: Color(0xFF66736A),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                ),
                label: const Text(
                  'Back to Finance',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeader(
      bool income,
      Color transactionColor,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B3D1B),
            Color(0xFF1B5E20),
            Color(0xFF43A047),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  income
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  color: transactionColor,
                  size: 29,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      transaction.category,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Transaction Amount',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            transaction.signedAmountText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              transaction.type,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF1B5E20),
          size: 21,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF17201A),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1B5E20),
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF66736A),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ??
                        const Color(0xFF17201A),
                    fontSize: 13,
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

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: Color(0xFFE8ECE9),
    );
  }
}