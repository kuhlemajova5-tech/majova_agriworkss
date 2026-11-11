import 'package:flutter/material.dart';

import '../../models/finance_transaction.dart';

class EditTransactionScreen extends StatefulWidget {
  final FinanceTransaction transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _referenceController;
  late final TextEditingController _relatedToController;
  late final TextEditingController _descriptionController;

  late String _selectedType;
  late String _selectedCategory;
  late String _selectedPaymentMethod;
  late DateTime _selectedDate;

  final List<String> _incomeCategories = [
    'Crop Sales',
    'Livestock Sales',
    'Tractor Services',
    'Farm Services',
    'Produce Sales',
    'Other Income',
  ];

  final List<String> _expenseCategories = [
    'Seeds & Seedlings',
    'Fertiliser',
    'Animal Feed',
    'Fuel',
    'Tractor Maintenance',
    'Veterinary',
    'Irrigation',
    'Labour',
    'Transport',
    'Packaging',
    'Equipment',
    'Other Expense',
  ];

  final List<String> _paymentMethods = [
    'Cash',
    'EFT',
    'Card',
    'Bank Deposit',
    'Mobile Payment',
    'Other',
  ];

  List<String> get _currentCategories {
    if (_selectedType == 'Income') {
      return _incomeCategories;
    }

    return _expenseCategories;
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.transaction.title,
    );

    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(2),
    );

    _referenceController = TextEditingController(
      text: widget.transaction.referenceNumber,
    );

    _relatedToController = TextEditingController(
      text: widget.transaction.relatedTo,
    );

    _descriptionController = TextEditingController(
      text: widget.transaction.description,
    );

    _selectedType = widget.transaction.type;
    _selectedDate = widget.transaction.date;

    if (_selectedType != 'Income' &&
        _selectedType != 'Expense') {
      _selectedType = 'Income';
    }

    if (_selectedType == 'Income') {
      _selectedCategory =
      _incomeCategories.contains(widget.transaction.category)
          ? widget.transaction.category
          : _incomeCategories.first;
    } else {
      _selectedCategory =
      _expenseCategories.contains(widget.transaction.category)
          ? widget.transaction.category
          : _expenseCategories.first;
    }

    _selectedPaymentMethod =
    _paymentMethods.contains(widget.transaction.paymentMethod)
        ? widget.transaction.paymentMethod
        : _paymentMethods.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _relatedToController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void _changeTransactionType(String type) {
    if (_selectedType == type) {
      return;
    }

    setState(() {
      _selectedType = type;

      if (_selectedType == 'Income') {
        _selectedCategory = _incomeCategories.first;
      } else {
        _selectedCategory = _expenseCategories.first;
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  String _formatDate(DateTime date) {
    final String day =
    date.day.toString().padLeft(2, '0');

    final String month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      return;
    }

    final FinanceTransaction updatedTransaction =
    FinanceTransaction(
      title: _titleController.text.trim(),
      type: _selectedType,
      category: _selectedCategory,
      amount: amount,
      date: _selectedDate,
      paymentMethod: _selectedPaymentMethod,
      referenceNumber: _referenceController.text.trim(),
      relatedTo: _relatedToController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    Navigator.pop(
      context,
      updatedTransaction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool income = _selectedType == 'Income';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Transaction',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17201A),
              ),
            ),
            Text(
              'Update the financial record',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF66736A),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            15,
            20,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelector(),

              const SizedBox(height: 24),

              _buildSectionTitle(
                'Transaction Information',
                Icons.receipt_long_outlined,
              ),

              const SizedBox(height: 14),

              _buildCard(
                children: [
                  TextFormField(
                    controller: _titleController,
                    textCapitalization:
                    TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Transaction Title',
                      hintText: 'Example: Cabbage Sales',
                      prefixIcon: Icon(
                        Icons.edit_note_rounded,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter a transaction title.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(
                        Icons.category_outlined,
                      ),
                    ),
                    items: _currentCategories.map(
                          (category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      hintText: '0.00',
                      prefixText: 'R ',
                      prefixIcon: Icon(
                        income
                            ? Icons.south_west_rounded
                            : Icons.north_east_rounded,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter the transaction amount.';
                      }

                      final double? amount =
                      double.tryParse(
                        value.trim(),
                      );

                      if (amount == null) {
                        return 'Enter a valid amount.';
                      }

                      if (amount <= 0) {
                        return 'Amount must be greater than zero.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  InkWell(
                    borderRadius:
                    BorderRadius.circular(16),
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration:
                      const InputDecoration(
                        labelText: 'Transaction Date',
                        prefixIcon: Icon(
                          Icons.calendar_today_outlined,
                        ),
                        suffixIcon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                        ),
                      ),
                      child: Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(
                          color: Color(0xFF17201A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(
                'Payment Information',
                Icons.payments_outlined,
              ),

              const SizedBox(height: 14),

              _buildCard(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: Icon(
                        Icons.wallet_outlined,
                      ),
                    ),
                    items: _paymentMethods.map(
                          (method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _referenceController,
                    textCapitalization:
                    TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Reference Number',
                      hintText: 'Example: SALE-004',
                      prefixIcon: Icon(
                        Icons.tag_rounded,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionTitle(
                'Farm Record',
                Icons.agriculture_outlined,
              ),

              const SizedBox(height: 14),

              _buildCard(
                children: [
                  TextFormField(
                    controller: _relatedToController,
                    textCapitalization:
                    TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Related To',
                      hintText:
                      'Example: Cabbage, Sheep or MF 265',
                      prefixIcon: Icon(
                        Icons.link_rounded,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter what this transaction relates to.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    textCapitalization:
                    TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText:
                      'Add optional notes about this transaction',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                          bottom: 70,
                        ),
                        child: Icon(
                          Icons.notes_rounded,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: income
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius:
                  BorderRadius.circular(18),
                  border: Border.all(
                    color: income
                        ? const Color(0xFFA5D6A7)
                        : const Color(0xFFEF9A9A),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: income
                            ? const Color(0xFFC8E6C9)
                            : const Color(0xFFFFCDD2),
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                      child: Icon(
                        income
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: income
                            ? const Color(0xFF1B5E20)
                            : const Color(0xFFC62828),
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
                                ? 'Farm Income'
                                : 'Farm Expense',
                            style: TextStyle(
                              fontWeight:
                              FontWeight.w800,
                              color: income
                                  ? const Color(0xFF1B5E20)
                                  : const Color(0xFFC62828),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            income
                                ? 'Changes to this record will affect total farm income and balance.'
                                : 'Changes to this record will affect total farm expenses and balance.',
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

              const SizedBox(height: 26),

              ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(
                  Icons.save_outlined,
                ),
                label: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                    const Color(0xFF1B5E20),
                    side: const BorderSide(
                      color: Color(0xFF1B5E20),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final bool income =
        _selectedType == 'Income';

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              title: 'Income',
              icon: Icons.south_west_rounded,
              selected: income,
              onTap: () {
                _changeTransactionType(
                  'Income',
                );
              },
            ),
          ),

          const SizedBox(width: 6),

          Expanded(
            child: _buildTypeButton(
              title: 'Expense',
              icon: Icons.north_east_rounded,
              selected: !income,
              onTap: () {
                _changeTransactionType(
                  'Expense',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final bool income =
        title == 'Income';

    final Color selectedColor = income
        ? const Color(0xFF1B5E20)
        : const Color(0xFFC62828);

    final Color selectedBackground = income
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? selectedBackground
              : Colors.transparent,
          borderRadius:
          BorderRadius.circular(15),
          border: selected
              ? Border.all(
            color: selectedColor,
          )
              : null,
        ),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? selectedColor
                  : const Color(0xFF66736A),
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected
                    ? selectedColor
                    : const Color(0xFF66736A),
              ),
            ),
          ],
        ),
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
            color: Color(0xFF17201A),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE3E9E4),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}