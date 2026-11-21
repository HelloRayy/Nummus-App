import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';

class V2BentoMetricGrid extends StatelessWidget {
  final String spentText;
  final String lastPurchaseText;
  final String lastPurchaseCategory;
  final String usedPercentText;
  final String dayBudgetText;

  const V2BentoMetricGrid({
    super.key,
    required this.spentText,
    required this.lastPurchaseText,
    required this.lastPurchaseCategory,
    required this.usedPercentText,
    required this.dayBudgetText,
  });

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 15.9;
    const double gridGap = 8.2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _BentoCard(
                  title: 'Spent this week',
                  value: spentText,
                  valueColor: V2Colors.semanticPositive,
                  subLabel: 'Total expenses',
                ),
              ),
              const SizedBox(width: gridGap),
              Expanded(
                child: _BentoCard(
                  title: 'Last purchase',
                  value: lastPurchaseText,
                  valueColor: V2Colors.semanticDanger,
                  subLabel: lastPurchaseCategory,
                ),
              ),
            ],
          ),
          const SizedBox(height: gridGap),
          Row(
            children: [
              Expanded(
                child: _BentoCard(
                  title: 'Used',
                  value: usedPercentText,
                  valueColor: V2Colors.accentPrimary,
                ),
              ),
              const SizedBox(width: gridGap),
              Expanded(
                child: _BentoCard(
                  title: 'Day budget',
                  value: dayBudgetText,
                  valueColor: dayBudgetText.startsWith('-')
                      ? V2Colors.semanticDanger
                      : V2Colors.accentPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final String? subLabel;

  const _BentoCard({
    required this.title,
    required this.value,
    required this.valueColor,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    const double cardRadius = 20.1;
    const double cardPadding = 12.2;
    const double titleSize = 13.7;
    const double valueSize = 24.1;
    const double subLabelSize = 11.7;
    const double titleValueGap = 7.9;
    const double valueSubGap = 4.2;

    return Container(
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
            title,
            style: V2Typography.cardTitle(size: titleSize)
                .copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: titleValueGap),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: V2Typography.displayBalance(size: valueSize)
                  .copyWith(color: valueColor),
            ),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: valueSubGap),
            Text(
              subLabel!,
              style: V2Typography.labelMuted(size: subLabelSize),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
