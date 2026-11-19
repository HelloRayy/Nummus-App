import 'package:flutter/material.dart';
import '../../core/theme/v2_tokens.dart';
import 'components/v2_header_greeting.dart';

class V2SandboxScreen extends StatelessWidget {
  const V2SandboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            V2HeaderGreeting(),
          ],
        ),
      ),
    );
  }
}
