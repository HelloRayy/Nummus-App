import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';
import '../spending_tuner_hud.dart';

class V2SpendingTrackerCard extends StatelessWidget {
  final SpendingTunerConfig config;
  final String availableText;
  final String limitText;

  const V2SpendingTrackerCard({
    super.key,
    required this.config,
    this.availableText = '\$2135.00',
    this.limitText = '\$3,280.45',
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: config,
      builder: (_, _) {
        final c = config;
        final totalBars = c.barCount.round();
        final thumbIndex = (totalBars * c.progress).round().clamp(0, totalBars - 1);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: EdgeInsets.all(c.cardPadding),
            decoration: BoxDecoration(
              color: V2Colors.surfaceCard,
              borderRadius: BorderRadius.circular(c.cardRadius),
              border: Border.all(color: V2Colors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly spending tracker',
                  style: V2Typography.cardTitle(size: c.titleSize),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitor your spending and stay on track and make sure you stay within your planned spending limit.',
                  style: TextStyle(
                    fontSize: c.descSize,
                    color: V2Colors.textMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: c.barHeight + c.thumbExtraHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(totalBars, (index) {
                      final isThumb = index == thumbIndex;
                      final t = index / (totalBars - 1).clamp(1, 999);
                      final barColor = _segmentColor(t, isAfterThumb: index > thumbIndex);

                      if (isThumb) {
                        return Container(
                          width: c.thumbWidth,
                          height: c.barHeight + c.thumbExtraHeight,
                          margin: EdgeInsets.only(
                            right: index == totalBars - 1 ? 0 : c.barGap,
                          ),
                          decoration: BoxDecoration(
                            color: V2Colors.textPrimary,
                            borderRadius: BorderRadius.circular(c.barRadius + 1),
                          ),
                        );
                      }

                      return Expanded(
                        child: Container(
                          height: c.barHeight,
                          margin: EdgeInsets.only(
                            right: index == totalBars - 1 ? 0 : c.barGap,
                          ),
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(c.barRadius),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available this month',
                          style: V2Typography.labelMuted(),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          availableText,
                          style: V2Typography.displayBalance(size: c.amountSize)
                              .copyWith(color: V2Colors.semanticPositive),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Spending limit',
                          style: V2Typography.labelMuted(),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          limitText,
                          style: V2Typography.displayBalance(size: c.amountSize),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _segmentColor(double t, {required bool isAfterThumb}) {
    if (!isAfterThumb) {
      return Color.lerp(
        V2Colors.semanticPositive,
        const Color(0xFF1E7E58),
        t,
      )!;
    }
    final fade = (1.0 - ((t - 0.4) * 1.1)).clamp(0.18, 1.0);
    return Color.lerp(
      const Color(0xFF7D6B22),
      V2Colors.semanticWarning,
      ((t - 0.35) * 1.5).clamp(0.0, 1.0),
    )!
        .withValues(alpha: fade);
  }
}
