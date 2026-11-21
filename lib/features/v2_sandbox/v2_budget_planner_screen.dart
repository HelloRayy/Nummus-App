import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';
import '../budget/repository/budget_repository.dart';
import 'components/v2_spending_tracker_card.dart';
import 'planner_tuner_hud.dart';

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
  final PlannerTunerConfig _config = PlannerTunerConfig();
  String _rawDigits = '';

  @override
  void dispose() {
    _titleController.dispose();
    _config.dispose();
    super.dispose();
  }

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
    final customTitle = _titleController.text.trim();
    final title =
        customTitle.isNotEmpty ? customTitle : 'Plan #${_items.length + 1}';

    setState(() {
      _items.insert(
        0,
        _PlanItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title,
          amount: amount,
        ),
      );
      _rawDigits = '';
      _titleController.clear();
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
        child: ListenableBuilder(
          listenable: _config,
          builder: (_, _) {
            final c = _config;
            return Stack(
              children: [
                Column(
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: V2Colors.surfaceCard,
                            borderRadius: BorderRadius.circular(14),
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
                                      style: V2Typography.cardTitle(size: 13),
                                    ),
                                    Text(
                                      '-${_formatRp(item.amount)}',
                                      style: V2Typography.displayBalance(
                                        size: 13,
                                      ).copyWith(
                                        color: V2Colors.semanticWarning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Convert to Expense',
                                onPressed: () => _convertToExpense(item),
                                icon: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: V2Colors.semanticPositive,
                                  size: 20,
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Remove',
                                onPressed: () {
                                  setState(() => _items.removeAt(index));
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
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

            // Custom Numpad Sheet
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12.2, 14, 12.2, 12),
              decoration: const BoxDecoration(
                color: V2Colors.surfaceCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(top: BorderSide(color: V2Colors.borderSubtle)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rp ${_formatDigits(_rawDigits)}',
                          style: V2Typography.displayBalance(size: 26).copyWith(
                            color: _rawDigits.isEmpty
                                ? V2Colors.textMuted
                                : V2Colors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: TextField(
                          controller: _titleController,
                          style: const TextStyle(
                            color: V2Colors.textPrimary,
                            fontSize: 12,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Note (opt)',
                            hintStyle: const TextStyle(
                              color: V2Colors.textMuted,
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: V2Colors.surfaceElevated,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                  _NumpadRow(keys: const ['1', '2', '3'], onKeyTap: _onKeyTap),
                  const SizedBox(height: 6),
                  _NumpadRow(keys: const ['4', '5', '6'], onKeyTap: _onKeyTap),
                  const SizedBox(height: 6),
                  _NumpadRow(keys: const ['7', '8', '9'], onKeyTap: _onKeyTap),
                  const SizedBox(height: 6),
                  _NumpadRow(
                    keys: const ['.000', '0', 'back'],
                    onKeyTap: _onKeyTap,
                  ),
                ],
              ),
            ),
          ],
                ),
                PlannerTunerHud(config: _config),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NumpadRow extends StatelessWidget {
  final List<String> keys;
  final ValueChanged<String> onKeyTap;

  const _NumpadRow({required this.keys, required this.onKeyTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(keys.length, (index) {
        final key = keys[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == keys.length - 1 ? 0 : 6),
            child: InkWell(
              onTap: () => onKeyTap(key),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: V2Colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(24),
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
