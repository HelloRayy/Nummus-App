import 'package:flutter/material.dart';

class V2Colors {
  static const Color bgPrimary = Color(0xFF0B0C0E);
  static const Color surfaceCard = Color(0xFF141619);
  static const Color surfaceElevated = Color(0xFF1B1E23);
  static const Color borderSubtle = Color(0xFF24272E);

  static const Color accentPrimary = Color(0xFF6E5CF6);
  static const Color semanticPositive = Color(0xFF28A774);
  static const Color semanticWarning = Color(0xFFD97736);
  static const Color semanticDanger = Color(0xFFE5484D);

  static const Color textPrimary = Color(0xFFF4F4F5);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);
}

class V2Typography {
  static const List<FontFeature> tabularNums = [FontFeature.tabularFigures()];

  static TextStyle displayBalance({double size = 28}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: V2Colors.textPrimary,
        fontFeatures: tabularNums,
      );

  static TextStyle headlineGreeting({double size = 22, Color? color}) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
        height: 1.25,
        color: color ?? V2Colors.textPrimary,
      );

  static TextStyle cardTitle({double size = 15}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: V2Colors.textPrimary,
      );

  static TextStyle labelMuted({double size = 12}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: V2Colors.textMuted,
      );
}
