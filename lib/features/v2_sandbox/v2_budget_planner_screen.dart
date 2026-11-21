import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';
import '../budget/repository/budget_repository.dart';
import 'components/v2_spending_tracker_card.dart';

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
  String _rawDigits = '';

  void _onKeyTap(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == 'back') {
        if (_rawDigits.isNotEmpty) {
          _rawDigits = _rawDigits.substring(0, _rawDigits.length - 1);
        }
        return;
      }
      if (key == '.000') {
        if (_rawDigits.isEmpty || _rawDigits == '0') return;
        if (_rawDigits.length + 3 <= 12) {
          _rawDigits += '000';
        }
        return;
      }
      if (_rawDigits.length >= 12) return;
      if (_rawDigits == '0') {
        _rawDigits = key;
      } else {
        _rawDigits += key;
      }
    });
  }

  String _formatDigits(String digits) {
    if (digits.isEmpty) return '0';
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - 1 - i;
      buffer.write(digits[i]);
      if (reverseIndex > 0 && reverseIndex % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  String _formatRp(int amount) {
    final isNeg = amount < 0;
    return '${isNeg ? '-' : ''}Rp ${_formatDigits(amount.abs().toString())}';
  }

  void _addItem() {
    final amount = int.tryParse(_rawDigits) ?? 0;
    if (amount <= 0) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _items.insert(
        0,
        _PlanItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: 'Plan #${_items.length + 1}',
          amount: amount,
        ),
      );
      _rawDigits = '';
    });
  }

  Future<void> _renameItem(int index) async {
    final current = _items[index];
    final controller = TextEditingController(text: current.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: V2Colors.surfaceCard,
        title: const Text(
          'Rename Plan',
          style: TextStyle(color: V2Colors.textPrimary, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: V2Colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Makan, Nonton',
            hintStyle: const TextStyle(color: V2Colors.textMuted),
            filled: true,
            fillColor: V2Colors.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: V2Colors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: V2Colors.accentPrimary,
              foregroundColor: V2Colors.bgPrimary,
            ),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newTitle != null && newTitle.isNotEmpty) {
      setState(() {
        _items[index] = _PlanItem(
          id: current.id,
          title: newTitle,
          amount: current.amount,
        );
      });
    }
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

    const double horizontalPadding = 24.1;
    const double listItemRadius = 8.2;
    const double sheetRadius = 32.0;
    const double displayAmountSize = 23.9;
    const double keyHeight = 48.0;
    const double keyGap = 8.1;
    const double keyRadius = 24.0;

    return Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Save All on top-right
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
                  InkWell(
                    onTap: _items.isEmpty ? null : _saveAllToExpenses,
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _items.isEmpty
                            ? V2Colors.surfaceCard
                            : V2Colors.semanticPositive,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _items.isEmpty
                              ? V2Colors.borderSubtle
                              : V2Colors.semanticPositive,
                        ),
                      ),
                      child: Text(
                        _items.isEmpty ? 'Save All' : 'Save (${_items.length})',
                        style: TextStyle(
                          color: _items.isEmpty
                              ? V2Colors.textMuted
                              : V2Colors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Summary Card (Weekly Spending Tracker)
            V2SpendingTrackerCard(
              availableText: _formatRp(finalRemaining),
              limitText: _formatRp(totalPlanned),
              progress: budgetCurrent > 0
                  ? (totalPlanned / budgetCurrent).clamp(0.0, 1.0)
                  : 0.0,
            ),

            const SizedBox(height: 10),

            // Planned Items List
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        'Tap numpad below & press + to add plan',
                        style: V2Typography.labelMuted(size: 13),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const Divider(
                        color: V2Colors.borderSubtle,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => _convertToExpense(item),
                                borderRadius: BorderRadius.circular(999),
                                child: const Icon(
                                  Icons.radio_button_unchecked_rounded,
                                  color: V2Colors.semanticPositive,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _renameItem(index),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.title,
                                          style: V2Typography.cardTitle(size: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.edit_outlined,
                                        size: 14,
                                        color: V2Colors.textMuted,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '-${_formatRp(item.amount)}',
                                style: V2Typography.displayBalance(size: 14)
                                    .copyWith(color: V2Colors.semanticWarning),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Remove',
                                onPressed: () {
                                  setState(() => _items.removeAt(index));
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: V2Colors.textMuted,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Custom Numpad Sheet (no system keyboard)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                14,
                horizontalPadding,
                12,
              ),
              decoration: const BoxDecoration(
                color: V2Colors.surfaceCard,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(sheetRadius),
                ),
                border: Border(
                  top: BorderSide(color: V2Colors.borderSubtle),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rp ${_formatDigits(_rawDigits)}',
                          style: V2Typography.displayBalance(
                            size: displayAmountSize,
                          ).copyWith(
                            color: _rawDigits.isEmpty
                                ? V2Colors.textMuted
                                : V2Colors.textPrimary,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _rawDigits.isEmpty ? null : _addItem,
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _rawDigits.isEmpty
                                ? V2Colors.surfaceElevated
                                : V2Colors.accentPrimary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: _rawDigits.isEmpty
                                ? V2Colors.textMuted
                                : V2Colors.bgPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _NumpadRow(
                    keys: const ['1', '2', '3'],
                    keyHeight: keyHeight,
                    keyGap: keyGap,
                    keyRadius: keyRadius,
                    onKeyTap: _onKeyTap,
                  ),
                  const SizedBox(height: keyGap),
                  _NumpadRow(
                    keys: const ['4', '5', '6'],
                    keyHeight: keyHeight,
                    keyGap: keyGap,
                    keyRadius: keyRadius,
                    onKeyTap: _onKeyTap,
                  ),
                  const SizedBox(height: keyGap),
                  _NumpadRow(
                    keys: const ['7', '8', '9'],
                    keyHeight: keyHeight,
                    keyGap: keyGap,
                    keyRadius: keyRadius,
                    onKeyTap: _onKeyTap,
                  ),
                  const SizedBox(height: keyGap),
                  _NumpadRow(
                    keys: const ['.000', '0', 'back'],
                    keyHeight: keyHeight,
                    keyGap: keyGap,
                    keyRadius: keyRadius,
                    onKeyTap: _onKeyTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumpadRow extends StatelessWidget {
  final List<String> keys;
  final double keyHeight;
  final double keyGap;
  final double keyRadius;
  final ValueChanged<String> onKeyTap;

  const _NumpadRow({
    required this.keys,
    required this.keyHeight,
    required this.keyGap,
    required this.keyRadius,
    required this.onKeyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(keys.length, (index) {
        final key = keys[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == keys.length - 1 ? 0 : keyGap,
            ),
            child: InkWell(
              onTap: () => onKeyTap(key),
              borderRadius: BorderRadius.circular(keyRadius),
              child: Container(
                height: keyHeight,
                decoration: BoxDecoration(
                  color: V2Colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(keyRadius),
                  border: Border.all(color: V2Colors.borderSubtle),
                ),
                alignment: Alignment.center,
                child: key == 'back'
                    ? const Icon(
                        Icons.backspace_outlined,
                        color: V2Colors.textPrimary,
                        size: 18,
                      )
                    : Text(
                        key,
                        style: V2Typography.displayBalance(
                          size: key == '.000' ? 15 : 18,
                        ).copyWith(fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
