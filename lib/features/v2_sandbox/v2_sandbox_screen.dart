import 'package:flutter/material.dart';
import '../../core/theme/v2_tokens.dart';
import 'components/v2_bento_metric_grid.dart';
import 'components/v2_bottom_action_bar.dart';
import 'components/v2_header_greeting.dart';
import 'components/v2_recent_transactions.dart';
import 'components/v2_spending_tracker_card.dart';
import 'v2_add_budget_screen.dart';
import 'v2_numpad_screen.dart';

class V2SandboxScreen extends StatelessWidget {
  const V2SandboxScreen({super.key});

  void _openAddBudget(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const V2AddBudgetScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 104),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const V2HeaderGreeting(),
                  const SizedBox(height: 20),
                  V2SpendingTrackerCard(
                    onTap: () => _openAddBudget(context),
                  ),
                  const SizedBox(height: 16),
                  const V2BentoMetricGrid(),
                  const SizedBox(height: 20),
                  const V2RecentTransactions(),
                ],
              ),
            ),
            V2BottomActionBar(
              onCtaTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const V2NumpadScreen()),
                );
              },
              onMenuSelect: (item) {
                if (item == 'Budget') {
                  _openAddBudget(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
