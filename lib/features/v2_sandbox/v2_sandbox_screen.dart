import 'package:flutter/material.dart';
import '../../core/theme/v2_tokens.dart';
import 'components/v2_header_greeting.dart';
import 'components/v2_spending_tracker_card.dart';
import 'spending_tuner_hud.dart';

class V2SandboxScreen extends StatefulWidget {
  const V2SandboxScreen({super.key});

  @override
  State<V2SandboxScreen> createState() => _V2SandboxScreenState();
}

class _V2SandboxScreenState extends State<V2SandboxScreen> {
  final SpendingTunerConfig _spendingConfig = SpendingTunerConfig();

  @override
  void dispose() {
    _spendingConfig.dispose();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const V2HeaderGreeting(),
                  const SizedBox(height: 20),
                  V2SpendingTrackerCard(config: _spendingConfig),
                ],
              ),
            ),
            SpendingTunerHud(config: _spendingConfig),
          ],
        ),
      ),
    );
  }
}
