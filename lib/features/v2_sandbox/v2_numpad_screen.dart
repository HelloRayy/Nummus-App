import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';
import '../budget/repository/budget_repository.dart';

class V2NumpadScreen extends StatefulWidget {
  final BudgetRepository repository;
  final String availableText;

  const V2NumpadScreen({
    super.key,
    required this.repository,
    required this.availableText,
  });

  @override
  State<V2NumpadScreen> createState() => _V2NumpadScreenState();
}

class _V2NumpadScreenState extends State<V2NumpadScreen> {
  String _rawDigits = '';
  int? _selectedCategory;

  static const _categories = [
    (label: 'Food', icon: Icons.restaurant_rounded),
    (label: 'Coffee', icon: Icons.coffee_rounded),
    (label: 'Transport', icon: Icons.directions_car_rounded),
    (label: 'Grocery', icon: Icons.shopping_bag_rounded),
  ];

  void _onKeyTap(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == 'back') {
        if (_rawDigits.isNotEmpty) {
          _rawDigits = _rawDigits.substring(0, _rawDigits.length - 1);
        }
        return;
      }
      if (key == '.000') {
        if (_rawDigits.isEmpty || _rawDigits == '0') return;
        if (_rawDigits.length + 3 <= 12) {
          _rawDigits += '000';
        }
        return;
      }
      if (_rawDigits.length >= 12) return;
      if (_rawDigits == '0') {
        _rawDigits = key;
      } else {
        _rawDigits += key;
      }
    });
  }

  String _formatRupiah(String digits) {
    if (digits.isEmpty) return '0';
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - 1 - i;
      buffer.write(digits[i]);
      if (reverseIndex > 0 && reverseIndex % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 12.2;
    const double sheetRadius = 40.0;
    const double amountSize = 58.0;
    const double keyHeight = 60.5;
    const double keyGap = 6.0;
    const double keyRadius = 28.0;
    const double keyFontSize = 19.7;
    const double ctaHeight = 58.4;

    final formatted = _formatRupiah(_rawDigits);

    return Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: V2Colors.surfaceCard,
                        border: Border.all(color: V2Colors.borderSubtle),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: V2Colors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: V2Colors.surfaceCard,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: V2Colors.borderSubtle),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        color: V2Colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  Text(
                    'Log an expense',
                    style: V2Typography.headlineGreeting(size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Every rupiah counts toward your weekly limit.',
                    textAlign: TextAlign.center,
                    style: V2Typography.labelMuted(size: 13),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom Sheet Container (Nominal + Categories + Numpad + CTA)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                16,
              ),
              decoration: const BoxDecoration(
                color: V2Colors.surfaceCard,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(sheetRadius),
                ),
                border: Border(
                  top: BorderSide(color: V2Colors.borderSubtle),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Rp ',
                        style: V2Typography.displayBalance(size: 24)
                            .copyWith(color: V2Colors.textMuted),
                      ),
                      Text(
                        formatted,
                        style: V2Typography.displayBalance(size: amountSize)
                            .copyWith(
                          color: _rawDigits.isEmpty
                              ? V2Colors.textMuted
                              : V2Colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Available: ${widget.availableText}',
                    style: V2Typography.labelMuted(size: 12),
                  ),
                  const SizedBox(height: 16),

                  // Circle Icon-Only Categories (max 4, centered)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_categories.length, (index) {
                      final cat = _categories[index];
                      final selected = index == _selectedCategory;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == _categories.length - 1 ? 0 : 14,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = selected ? null : index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? V2Colors.accentPrimary
                                  : V2Colors.surfaceElevated,
                              border: Border.all(
                                color: selected
                                    ? V2Colors.accentPrimary
                                    : V2Colors.borderSubtle,
                              ),
                            ),
                            child: Icon(
                              cat.icon,
                              size: 20,
                              color: selected
                                  ? V2Colors.bgPrimary
                                  : V2Colors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Custom Numpad (4 rows x 3 cols)
                  _NumpadRow(
                    keys: const ['1', '2', '3'],
                    keyHeight: keyHeight,
                    keyGap: keyGap,
                    keyRadius: keyRadius,
                    keyFontSize: keyFontSize,
                    onKeyTap: _onKeyTap,
                  ),
                  const SizedBox(height: keyGap),
                  _NumpadRow(
                    keys: const ['4', '5', '6'],
                    keyHeight: keyHeight,
                    keyGap: keyGap,
                    keyRadius: keyRadius,
                    keyFontSize: keyFontSize,
                    onKeyTap: _onKeyTap,
                  ),
                  const SizedBox(height: keyGap),
                  _NumpadRow(
                    keys: const ['7', '8', '9'],
                    keyHeight: keyHeight,
                    keyGap: keyGap,
                    keyRadius: keyRadius,
                    keyFontSize: keyFontSize,
                    onKeyTap: _onKeyTap,
                  ),
                  const SizedBox(height: keyGap),
                  _NumpadRow(
                    keys: const ['.000', '0', 'back'],
                    keyHeight: keyHeight,
                    keyGap: keyGap,
                    keyRadius: keyRadius,
                    keyFontSize: keyFontSize,
                    onKeyTap: _onKeyTap,
                  ),
                  const SizedBox(height: 16),

                  // Primary CTA
                  InkWell(
                    onTap: _rawDigits.isEmpty
                        ? null
                        : () async {
                            final amount = int.tryParse(_rawDigits) ?? 0;
                            if (amount <= 0) return;
                            final catName = _selectedCategory == null
                                ? null
                                : _categories[_selectedCategory!].label;
                            await widget.repository.addExpense(
                              amount,
                              categoryId: catName,
                              note: catName ?? 'Expense',
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Saved ${catName ?? 'Expense'}: Rp $formatted',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: ctaHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _rawDigits.isEmpty
                            ? V2Colors.surfaceElevated
                            : V2Colors.accentPrimary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Save Expense',
                        style: TextStyle(
                          color: _rawDigits.isEmpty
                              ? V2Colors.textMuted
                              : V2Colors.bgPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumpadRow extends StatelessWidget {
  final List<String> keys;
  final double keyHeight;
  final double keyGap;
  final double keyRadius;
  final double keyFontSize;
  final ValueChanged<String> onKeyTap;

  const _NumpadRow({
    required this.keys,
    required this.keyHeight,
    required this.keyGap,
    required this.keyRadius,
    required this.keyFontSize,
    required this.onKeyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(keys.length, (index) {
        final key = keys[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == keys.length - 1 ? 0 : keyGap,
            ),
            child: InkWell(
              onTap: () => onKeyTap(key),
              borderRadius: BorderRadius.circular(keyRadius),
              child: Container(
                height: keyHeight,
                decoration: BoxDecoration(
                  color: V2Colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(keyRadius),
                  border: Border.all(color: V2Colors.borderSubtle),
                ),
                alignment: Alignment.center,
                child: key == 'back'
                    ? const Icon(
                        Icons.backspace_outlined,
                        color: V2Colors.textPrimary,
                        size: 20,
                      )
                    : Text(
                        key,
                        style: V2Typography.displayBalance(
                          size: key == '.000' ? keyFontSize * 0.82 : keyFontSize,
                        ).copyWith(fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
