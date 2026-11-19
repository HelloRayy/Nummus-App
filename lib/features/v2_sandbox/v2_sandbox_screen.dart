import 'package:flutter/material.dart';
import '../../core/theme/v2_tokens.dart';
import 'components/v2_bento_metric_grid.dart';
import 'components/v2_header_greeting.dart';
import 'components/v2_recent_transactions.dart';
import 'components/v2_spending_tracker_card.dart';
import 'recent_tx_tuner_hud.dart';

class V2SandboxScreen extends StatefulWidget {
  const V2SandboxScreen({super.key});

  @override
  State<V2SandboxScreen> createState() => _V2SandboxScreenState();
}

class _V2SandboxScreenState extends State<V2SandboxScreen> {
  final RecentTxTunerConfig _txConfig = RecentTxTunerConfig();

  @override
  void dispose() {
    _txConfig.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 220),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const V2HeaderGreeting(),
                  const SizedBox(height: 20),
                  const V2SpendingTrackerCard(),
                  const SizedBox(height: 16),
                  const V2BentoMetricGrid(),
                  const SizedBox(height: 20),
                  V2RecentTransactions(config: _txConfig),
                ],
              ),
            ),
            RecentTxTunerHud(config: _txConfig),
          ],
        ),
      ),
    );
  }
}
