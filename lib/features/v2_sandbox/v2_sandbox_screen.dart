import 'package:flutter/material.dart';
import '../../core/theme/v2_tokens.dart';
import 'bottom_bar_tuner_hud.dart';
import 'components/v2_bento_metric_grid.dart';
import 'components/v2_bottom_action_bar.dart';
import 'components/v2_header_greeting.dart';
import 'components/v2_recent_transactions.dart';
import 'components/v2_spending_tracker_card.dart';

class V2SandboxScreen extends StatefulWidget {
  const V2SandboxScreen({super.key});

  @override
  State<V2SandboxScreen> createState() => _V2SandboxScreenState();
}

class _V2SandboxScreenState extends State<V2SandboxScreen> {
  final BottomBarTunerConfig _bottomConfig = BottomBarTunerConfig();

  @override
  void dispose() {
    _bottomConfig.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            const SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  V2HeaderGreeting(),
                  SizedBox(height: 20),
                  V2SpendingTrackerCard(),
                  SizedBox(height: 16),
                  V2BentoMetricGrid(),
                  SizedBox(height: 20),
                  V2RecentTransactions(),
                ],
              ),
            ),
            V2BottomActionBar(config: _bottomConfig),
            BottomBarTunerHud(config: _bottomConfig),
          ],
        ),
      ),
    );
  }
}
