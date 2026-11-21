import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';

class DevScreenBanner extends StatelessWidget {
  final String label;
  final Widget child;

  const DevScreenBanner({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;
    return Banner(
      message: label,
      location: BannerLocation.topEnd,
      color: V2Colors.accentPrimary,
      textStyle: const TextStyle(
        color: V2Colors.bgPrimary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
      child: child,
    );
  }
}
