import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';

class V2RecentTransactions extends StatelessWidget {
  const V2RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 16.0;
    const double cardRadius = 20.1;
    const double cardPadding = 12.1;
    const double itemGap = 13.8;
    const double iconSize = 40.0;
    const double titleSize = 14.2;
    const double subSize = 11.6;
    const double amountSize = 18.9;

    const items = [
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
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
            padding: const EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: V2Colors.surfaceCard,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: V2Colors.borderSubtle),
            ),
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == items.length - 1 ? 0 : itemGap,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: item.iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          color: item.iconColor,
                          size: iconSize * 0.48,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: V2Typography.cardTitle(size: titleSize)
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.category,
                              style: V2Typography.labelMuted(size: subSize),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item.amount,
                        style: V2Typography.displayBalance(size: amountSize)
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
