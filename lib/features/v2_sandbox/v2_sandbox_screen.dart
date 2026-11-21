import 'package:flutter/material.dart';
import '../../core/theme/v2_tokens.dart';
import '../budget/repository/budget_repository.dart';
import 'components/dev_screen_banner.dart';
import 'components/v2_bento_metric_grid.dart';
import 'components/v2_bottom_action_bar.dart';
import 'components/v2_header_greeting.dart';
import 'components/v2_recent_transactions.dart';
import 'components/v2_spending_tracker_card.dart';
import 'v2_add_budget_screen.dart';
import 'v2_budget_planner_screen.dart';
import 'v2_numpad_screen.dart';

class V2SandboxScreen extends StatelessWidget {
  final BudgetRepository repository;

  const V2SandboxScreen({super.key, required this.repository});

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

  void _openAddBudget(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => V2AddBudgetScreen(repository: repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DevScreenBanner(
      label: 'HOME',
      child: Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: repository,
          builder: (context, _) {
            final limit = repository.spendableBudget;
            final spent = repository.totalSpent;
            final available = repository.remainingWeeklySpendable;
            final progress =
                limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
            final usedPct =
                limit > 0 ? ((spent / limit) * 100).round().clamp(0, 999) : 0;

            final dayBudget = repository.remainingToday;

            final lastTx = repository.expenses.isNotEmpty
                ? repository.expenses.first
                : null;
            final lastPurchaseText =
                lastTx != null ? '-${_formatRp(lastTx.amount)}' : 'Rp 0';
            final lastPurchaseCategory =
                lastTx?.categoryId ?? lastTx?.note ?? 'No expenses yet';

            final availableFormatted = _formatRp(available);

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 104),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const V2HeaderGreeting(),
                      const SizedBox(height: 20),
                      V2SpendingTrackerCard(
                        availableText: availableFormatted,
                        limitText: _formatRp(dayBudget),
                        progress: progress,
                        onTap: () => _openAddBudget(context),
                      ),
                      const SizedBox(height: 16),
                      V2BentoMetricGrid(
                        spentText: _formatRp(spent),
                        lastPurchaseText: lastPurchaseText,
                        lastPurchaseCategory: lastPurchaseCategory,
                        usedPercentText: '$usedPct%',
                        dayBudgetText: _formatRp(dayBudget),
                      ),
                      const SizedBox(height: 20),
                      V2RecentTransactions(
                        expenses: repository.expenses,
                        formatRp: _formatRp,
                      ),
                    ],
                  ),
                ),
                V2BottomActionBar(
                  onCtaTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => V2NumpadScreen(
                          repository: repository,
                          availableText: availableFormatted,
                        ),
                      ),
                    );
                  },
                  onMenuSelect: (item) {
                    if (item == 'Budget') {
                      _openAddBudget(context);
                    } else if (item == 'Planner') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              V2BudgetPlannerScreen(repository: repository),
                        ),
                      );
                    } else if (item == 'Settings') {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: V2Colors.surfaceCard,
                          title: const Text(
                            'Reset All Data?',
                            style: TextStyle(color: V2Colors.textPrimary),
                          ),
                          content: const Text(
                            'Semua pengeluaran dan budget minggu ini akan di-reset ke Rp 0.',
                            style: TextStyle(color: V2Colors.textSecondary),
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
                                backgroundColor: V2Colors.semanticDanger,
                              ),
                              onPressed: () async {
                                await repository.resetAllExpenses();
                                await repository.updateBudget(
                                  weeklyIncome: 0,
                                  weeklySavingsTarget: 0,
                                );
                                if (!ctx.mounted) return;
                                Navigator.pop(ctx);
                              },
                              child: const Text('Reset to 0'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    ),
    );
  }
}
