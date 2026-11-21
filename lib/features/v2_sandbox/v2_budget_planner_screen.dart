import 'package:flutter/material.dart';
import '../../core/theme/v2_tokens.dart';
import '../budget/repository/budget_repository.dart';

class _PlanItem {
  final String id;
  final String title;
  final int amount;

  const _PlanItem({
    required this.id,
    required this.title,
    required this.amount,
  });
}

class V2BudgetPlannerScreen extends StatefulWidget {
  final BudgetRepository repository;

  const V2BudgetPlannerScreen({super.key, required this.repository});

  @override
  State<V2BudgetPlannerScreen> createState() => _V2BudgetPlannerScreenState();
}

class _V2BudgetPlannerScreenState extends State<V2BudgetPlannerScreen> {
  final List<_PlanItem> _items = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _formatRp(int amount) {
    final isNeg = amount < 0;
    final digits = amount.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - 1 - i;
      buffer.write(digits[i]);
      if (reverseIndex > 0 && reverseIndex % 3 == 0) {
        buffer.write('.');
      }
    }
    return '${isNeg ? '-' : ''}Rp ${buffer.toString()}';
  }

  void _addItem() {
    final title = _titleController.text.trim();
    final rawAmount =
        _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(rawAmount) ?? 0;
    if (title.isEmpty || amount <= 0) return;

    setState(() {
      _items.add(
        _PlanItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title,
          amount: amount,
        ),
      );
      _titleController.clear();
      _amountController.clear();
    });
  }

  Future<void> _convertToExpense(_PlanItem item) async {
    await widget.repository.addExpense(
      item.amount,
      note: item.title,
      categoryId: 'Planned',
    );
    if (!mounted) return;
    setState(() {
      _items.removeWhere((e) => e.id == item.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recorded: ${item.title} (${_formatRp(item.amount)})'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveAllToExpenses() async {
    if (_items.isEmpty) return;
    final copy = List<_PlanItem>.from(_items);
    for (final item in copy) {
      await widget.repository.addExpense(
        item.amount,
        note: item.title,
        categoryId: 'Planned',
      );
    }
    if (!mounted) return;
    setState(() => _items.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved ${copy.length} planned items to expenses'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetCurrent = widget.repository.remainingWeeklySpendable;
    final totalPlanned = _items.fold<int>(0, (sum, e) => sum + e.amount);
    final finalRemaining = budgetCurrent - totalPlanned;
    final isOver = finalRemaining < 0;

    return Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: V2Colors.surfaceCard,
                        border: Border.all(color: V2Colors.borderSubtle),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: V2Colors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  Text('Trip Planner', style: V2Typography.cardTitle(size: 16)),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Summary Card (Budget Current -> Final Remaining)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: V2Colors.surfaceCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: V2Colors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining after plan',
                      style: V2Typography.labelMuted(size: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRp(finalRemaining),
                      style: V2Typography.displayBalance(size: 30).copyWith(
                        color: isOver
                            ? V2Colors.semanticDanger
                            : V2Colors.semanticPositive,
                      ),
                    ),
                    const Divider(color: V2Colors.borderSubtle, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget current',
                              style: V2Typography.labelMuted(size: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatRp(budgetCurrent),
                              style: V2Typography.displayBalance(size: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total planned',
                              style: V2Typography.labelMuted(size: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '-${_formatRp(totalPlanned)}',
                              style: V2Typography.displayBalance(size: 16)
                                  .copyWith(color: V2Colors.semanticWarning),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Quick Add Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        color: V2Colors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Item (e.g. Makan)',
                        hintStyle: const TextStyle(color: V2Colors.textMuted),
                        filled: true,
                        fillColor: V2Colors.surfaceCard,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: V2Colors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: V2Colors.accentPrimary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: V2Colors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rp',
                        hintStyle: const TextStyle(color: V2Colors.textMuted),
                        filled: true,
                        fillColor: V2Colors.surfaceCard,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: V2Colors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: V2Colors.accentPrimary),
                        ),
                      ),
                      onSubmitted: (_) => _addItem(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _addItem,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: V2Colors.accentPrimary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: V2Colors.bgPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Planned Items List
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        'Add items to simulate your trip budget',
                        style: V2Typography.labelMuted(size: 13),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: V2Colors.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: V2Colors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: V2Typography.cardTitle(size: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '-${_formatRp(item.amount)}',
                                      style: V2Typography.displayBalance(
                                        size: 14,
                                      ).copyWith(
                                        color: V2Colors.semanticWarning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Convert to Expense',
                                onPressed: () => _convertToExpense(item),
                                icon: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: V2Colors.semanticPositive,
                                  size: 22,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                onPressed: () {
                                  setState(() => _items.removeAt(index));
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: V2Colors.textMuted,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            if (_items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: InkWell(
                  onTap: _saveAllToExpenses,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: V2Colors.semanticPositive,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Save All (${_items.length}) to Expenses',
                      style: const TextStyle(
                        color: V2Colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
