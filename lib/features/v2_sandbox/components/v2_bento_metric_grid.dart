import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';
import '../bento_tuner_hud.dart';

class V2BentoMetricGrid extends StatelessWidget {
  final BentoTunerConfig config;

  const V2BentoMetricGrid({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: config,
      builder: (_, _) {
        final c = config;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: c.horizontalPadding),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _BentoCard(
                      config: c,
                      title: 'Weekly trend',
                      value: '+12% ↑',
                      valueColor: V2Colors.semanticPositive,
                      subLabel: 'More than last week',
                    ),
                  ),
                  SizedBox(width: c.gridGap),
                  Expanded(
                    child: _BentoCard(
                      config: c,
                      title: 'Last purchase',
                      value: '- \$24.90',
                      valueColor: V2Colors.semanticWarning,
                      subLabel: 'Grocery',
                    ),
                  ),
                ],
              ),
              SizedBox(height: c.gridGap),
              Row(
                children: [
                  Expanded(
                    child: _BentoCard(
                      config: c,
                      title: 'Credit',
                      value: '23%',
                      valueColor: V2Colors.accentPrimary,
                    ),
                  ),
                  SizedBox(width: c.gridGap),
                  Expanded(
                    child: _BentoCard(
                      config: c,
                      title: 'Day budget',
                      value: '\$42',
                      valueColor: V2Colors.accentPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BentoCard extends StatelessWidget {
  final BentoTunerConfig config;
  final String title;
  final String value;
  final Color valueColor;
  final String? subLabel;

  const _BentoCard({
    required this.config,
    required this.title,
    required this.value,
    required this.valueColor,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(config.cardPadding),
      decoration: BoxDecoration(
        color: V2Colors.surfaceCard,
        borderRadius: BorderRadius.circular(config.cardRadius),
        border: Border.all(color: V2Colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: V2Typography.cardTitle(size: config.titleSize)
                .copyWith(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: config.titleValueGap),
          Text(
            value,
            style: V2Typography.displayBalance(size: config.valueSize)
                .copyWith(color: valueColor),
          ),
          if (subLabel != null) ...[
            SizedBox(height: config.valueSubGap),
            Text(
              subLabel!,
              style: V2Typography.labelMuted(size: config.subLabelSize),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
