import 'package:flutter/material.dart';
import '../../core/theme/v2_tokens.dart';
import 'components/v2_header_greeting.dart';
import 'ui_tuner_hud.dart';

class V2SandboxScreen extends StatefulWidget {
  const V2SandboxScreen({super.key});

  @override
  State<V2SandboxScreen> createState() => _V2SandboxScreenState();
}

class _V2SandboxScreenState extends State<V2SandboxScreen> {
  final HeaderTunerConfig _headerConfig = HeaderTunerConfig();

  @override
  void dispose() {
    _headerConfig.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                V2HeaderGreeting(config: _headerConfig),
              ],
            ),
            UiTunerHud(config: _headerConfig),
          ],
        ),
      ),
    );
  }
}
