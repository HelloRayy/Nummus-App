import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';
import '../../budget/models/expense_model.dart';

class V2RecentTransactions extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final String Function(int amount) formatRp;
  final VoidCallback? onSeeAllTap;

  const V2RecentTransactions({
    super.key,
    required this.expenses,
    required this.formatRp,
    this.onSeeAllTap,
  });

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

    final recent = expenses.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent transactions', style: V2Typography.cardTitle()),
              InkWell(
                onTap: onSeeAllTap,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: V2Colors.accentPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: V2Colors.surfaceCard,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: V2Colors.borderSubtle),
            ),
            child: recent.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No transactions this week yet',
                        style: V2Typography.labelMuted(size: 13),
                      ),
                    ),
                  )
                : Column(
                    children: List.generate(recent.length, (index) {
                      final item = recent[index];
                      final cat = item.categoryId ?? 'Expense';
                      final title = item.note.isNotEmpty ? item.note : cat;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == recent.length - 1 ? 0 : itemGap,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: iconSize,
                              height: iconSize,
                              decoration: BoxDecoration(
                                color: _iconBg(cat),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _iconData(cat),
                                color: _iconColor(cat),
                                size: iconSize * 0.48,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: V2Typography.cardTitle(size: titleSize)
                                        .copyWith(fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cat,
                                    style: V2Typography.labelMuted(size: subSize),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '-${formatRp(item.amount)}',
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

  IconData _iconData(String cat) {
    switch (cat.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'grocery':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _iconBg(String cat) {
    switch (cat.toLowerCase()) {
      case 'coffee':
        return const Color(0xFF1E3A2F);
      case 'grocery':
        return const Color(0xFF2D2218);
      default:
        return const Color(0xFF1F222A);
    }
  }

  Color _iconColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'coffee':
        return V2Colors.semanticPositive;
      case 'grocery':
        return V2Colors.semanticWarning;
      default:
        return V2Colors.textPrimary;
    }
  }
}
