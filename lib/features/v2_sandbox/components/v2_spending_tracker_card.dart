import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';

class V2SpendingTrackerCard extends StatelessWidget {
  final String availableText;
  final String limitText;
  final double progress;

  const V2SpendingTrackerCard({
    super.key,
    this.availableText = '\$2135.00',
    this.limitText = '\$3,280.45',
    this.progress = 0.58,
  });

  @override
  Widget build(BuildContext context) {
    const int totalBars = 32;
    const double cardRadius = 32.0;
    const double cardPadding = 16.2;
    const double titleSize = 16.1;
    const double barHeight = 36.5;
    const double barGap = 3.9;
    const double barRadius = 6.0;
    const double thumbWidth = 8.2;
    const double thumbExtraHeight = 8.0;
    const double amountSize = 24.4;

    final thumbIndex = (totalBars * progress).round().clamp(0, totalBars - 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: V2Colors.surfaceCard,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: V2Colors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly spending tracker',
              style: V2Typography.cardTitle(size: titleSize),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: barHeight + thumbExtraHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(totalBars, (index) {
                  final isThumb = index == thumbIndex;
                  final t = index / (totalBars - 1);
                  final barColor =
                      _segmentColor(t, isAfterThumb: index > thumbIndex);

                  if (isThumb) {
                    return Container(
                      width: thumbWidth,
                      height: barHeight + thumbExtraHeight,
                      margin: EdgeInsets.only(
                        right: index == totalBars - 1 ? 0 : barGap,
                      ),
                      decoration: BoxDecoration(
                        color: V2Colors.textPrimary,
                        borderRadius: BorderRadius.circular(barRadius + 1),
                      ),
                    );
                  }

                  return Expanded(
                    child: Container(
                      height: barHeight,
                      margin: EdgeInsets.only(
                        right: index == totalBars - 1 ? 0 : barGap,
                      ),
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(barRadius),
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
                      style: V2Typography.displayBalance(size: amountSize)
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
                      style: V2Typography.displayBalance(size: amountSize),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
