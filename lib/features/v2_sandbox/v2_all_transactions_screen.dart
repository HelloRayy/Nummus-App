import 'package:flutter/material.dart';
import '../../core/theme/v2_tokens.dart';
import '../budget/models/expense_model.dart';
import '../budget/repository/budget_repository.dart';

class V2AllTransactionsScreen extends StatefulWidget {
  final BudgetRepository repository;

  const V2AllTransactionsScreen({super.key, required this.repository});

  @override
  State<V2AllTransactionsScreen> createState() =>
      _V2AllTransactionsScreenState();
}

class _V2AllTransactionsScreenState extends State<V2AllTransactionsScreen> {
  List<ExpenseModel> _all = [];
  int _visibleCount = 5;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await widget.repository.getAllExpensesHistory();
    if (!mounted) return;
    setState(() {
      _all = list;
      _loading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    final shown = _all.take(_visibleCount).toList();
    final hasMore = _visibleCount < _all.length;

    return Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'All Transactions',
                        style: V2Typography.cardTitle(size: 16),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
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
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: V2Colors.accentPrimary,
                      ),
                    )
                  : _all.isEmpty
                      ? Center(
                          child: Text(
                            'No transactions yet',
                            style: V2Typography.labelMuted(size: 14),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: shown.length + (hasMore ? 1 : 0),
                          separatorBuilder: (_, _) => const Divider(
                            color: V2Colors.borderSubtle,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            if (index == shown.length) {
                              final remaining = _all.length - _visibleCount;
                              final nextBatch = remaining >= 5 ? 5 : remaining;
                              return Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _visibleCount += 5);
                                  },
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: V2Colors.surfaceCard,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: V2Colors.borderSubtle,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Load $nextBatch more ($remaining left)',
                                      style: const TextStyle(
                                        color: V2Colors.accentPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            final item = shown[index];
                            final cat = item.categoryId ?? 'Expense';
                            final title =
                                item.note.isNotEmpty ? item.note : cat;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style:
                                              V2Typography.cardTitle(size: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          cat,
                                          style:
                                              V2Typography.labelMuted(size: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '-${_formatRp(item.amount)}',
                                    style: V2Typography.displayBalance(size: 15)
                                        .copyWith(
                                      color: V2Colors.semanticDanger,
                                    ),
                                  ),
                                  if (item.id != null) ...[
                                    const SizedBox(width: 6),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () async {
                                        await widget.repository
                                            .deleteExpense(item.id!);
                                        await _load();
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: V2Colors.textMuted,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
