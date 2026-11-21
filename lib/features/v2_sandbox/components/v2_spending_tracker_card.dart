import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';

class V2SpendingTrackerCard extends StatelessWidget {
  final String availableText;
  final String limitText;
  final int? availableAmount;
  final int? limitAmount;
  final double progress;
  final int rollDurationMs;
  final int chartDurationMs;
  final Curve curve;
  final VoidCallback? onTap;

  const V2SpendingTrackerCard({
    super.key,
    this.availableText = 'Rp 0',
    this.limitText = 'Rp 0',
    this.availableAmount,
    this.limitAmount,
    this.progress = 0.58,
    this.rollDurationMs = 400,
    this.chartDurationMs = 400,
    this.curve = Curves.easeOutQuart,
    this.onTap,
  });

  String _formatRp(int amount) {
    final isNeg = amount < 0;
    final digits = amount.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - 1 - i;
      buffer.write(digits[i]);
      if (reverseIndex > 0 && reverseIndex % 3 == 0) {
        buffer.write('.');
      }
    }
    return '${isNeg ? '-' : ''}Rp ${buffer.toString()}';
  }

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly spending tracker',
                    style: V2Typography.cardTitle(size: titleSize),
                  ),
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 18,
                    color: V2Colors.textSecondary,
                  ),
                ],
              ),
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: progress, end: progress),
              duration: Duration(milliseconds: chartDurationMs),
              curve: curve,
              builder: (_, animatedProgress, _) {
                final thumbIndex = (totalBars * animatedProgress)
                    .round()
                    .clamp(0, totalBars - 1);
                return ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.07, 0.88, 1.0],
                  ).createShader(bounds),
                  child: SizedBox(
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
                              borderRadius:
                                  BorderRadius.circular(barRadius + 1),
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
                );
              },
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current budget',
                        style: V2Typography.labelMuted(),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: availableAmount != null
                            ? TweenAnimationBuilder<int>(
                                tween: IntTween(
                                  begin: availableAmount!,
                                  end: availableAmount!,
                                ),
                                duration: Duration(milliseconds: rollDurationMs),
                                curve: curve,
                                builder: (_, val, _) => Text(
                                  _formatRp(val),
                                  style: V2Typography.displayBalance(
                                    size: amountSize,
                                  ).copyWith(
                                    color: val < 0
                                        ? V2Colors.semanticDanger
                                        : V2Colors.semanticPositive,
                                  ),
                                ),
                              )
                            : Text(
                                availableText,
                                style: V2Typography.displayBalance(
                                  size: amountSize,
                                ).copyWith(
                                  color: availableText.startsWith('-')
                                      ? V2Colors.semanticDanger
                                      : V2Colors.semanticPositive,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Day budget',
                        style: V2Typography.labelMuted(),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: limitAmount != null
                            ? TweenAnimationBuilder<int>(
                                tween: IntTween(
                                  begin: limitAmount!,
                                  end: limitAmount!,
                                ),
                                duration: Duration(milliseconds: rollDurationMs),
                                curve: curve,
                                builder: (_, val, _) => Text(
                                  _formatRp(val),
                                  style: V2Typography.displayBalance(
                                    size: amountSize,
                                  ),
                                ),
                              )
                            : Text(
                                limitText,
                                style: V2Typography.displayBalance(
                                  size: amountSize,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Color _segmentColor(double t, {required bool isAfterThumb}) {
    if (!isAfterThumb) {
      return Color.lerp(
        V2Colors.semanticWarning,
        V2Colors.semanticDanger,
        t,
      )!;
    }
    final fade = (1.0 - ((t - 0.35) * 0.9)).clamp(0.22, 1.0);
    return V2Colors.semanticPositive.withValues(alpha: fade);
  }
}
