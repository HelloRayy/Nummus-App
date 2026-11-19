import 'package:flutter/material.dart';
import '../../core/theme/v2_tokens.dart';
import 'components/v2_bento_metric_grid.dart';
import 'components/v2_header_greeting.dart';
import 'components/v2_spending_tracker_card.dart';

class V2SandboxScreen extends StatelessWidget {
  const V2SandboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              V2HeaderGreeting(),
              SizedBox(height: 20),
              V2SpendingTrackerCard(),
              SizedBox(height: 16),
              V2BentoMetricGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
