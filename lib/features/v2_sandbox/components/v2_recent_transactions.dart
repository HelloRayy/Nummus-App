import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';
import '../recent_tx_tuner_hud.dart';

class V2RecentTransactions extends StatelessWidget {
  final RecentTxTunerConfig config;

  const V2RecentTransactions({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _TxItem(
        icon: Icons.coffee_rounded,
        iconBg: Color(0xFF1E3A2F),
        iconColor: V2Colors.semanticPositive,
        title: 'Starbucks Coffee',
        category: 'Food & Drinks',
        amount: '-\$6.40',
      ),
      _TxItem(
        icon: Icons.directions_car_rounded,
        iconBg: Color(0xFF1F222A),
        iconColor: V2Colors.textPrimary,
        title: 'Uber Ride',
        category: 'Transport',
        amount: '-\$9.30',
      ),
      _TxItem(
        icon: Icons.shopping_bag_rounded,
        iconBg: Color(0xFF2D2218),
        iconColor: V2Colors.semanticWarning,
        title: 'Grocery Market',
        category: 'Groceries',
        amount: '-\$42.80',
      ),
    ];

    return ListenableBuilder(
      listenable: config,
      builder: (_, _) {
        final c = config;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: c.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent transactions', style: V2Typography.cardTitle()),
                  const Text(
                    'See all',
                    style: TextStyle(
                      color: V2Colors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(c.cardPadding),
                decoration: BoxDecoration(
                  color: V2Colors.surfaceCard,
                  borderRadius: BorderRadius.circular(c.cardRadius),
                  border: Border.all(color: V2Colors.borderSubtle),
                ),
                child: Column(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == items.length - 1 ? 0 : c.itemGap,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: c.iconSize,
                            height: c.iconSize,
                            decoration: BoxDecoration(
                              color: item.iconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: item.iconColor,
                              size: c.iconSize * 0.48,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: V2Typography.cardTitle(size: c.titleSize)
                                      .copyWith(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.category,
                                  style: V2Typography.labelMuted(size: c.subSize),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item.amount,
                            style: V2Typography.displayBalance(size: c.amountSize)
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TxItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String category;
  final String amount;

  const _TxItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.category,
    required this.amount,
  });
}
