import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';

class V2NumpadScreen extends StatefulWidget {
  const V2NumpadScreen({super.key});

  @override
  State<V2NumpadScreen> createState() => _V2NumpadScreenState();
}

class _V2NumpadScreenState extends State<V2NumpadScreen> {
  String _rawDigits = '';
  bool _isExpense = true;
  int _selectedCategory = 0;

  static const _categories = [
    (label: 'Food', icon: Icons.restaurant_rounded),
    (label: 'Coffee', icon: Icons.coffee_rounded),
    (label: 'Transport', icon: Icons.directions_car_rounded),
    (label: 'Grocery', icon: Icons.shopping_bag_rounded),
    (label: 'Bills', icon: Icons.receipt_long_rounded),
    (label: 'Other', icon: Icons.more_horiz_rounded),
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
    final formatted = _formatRupiah(_rawDigits);

    return Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: V2Colors.surfaceCard,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: V2Colors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        _TypeChip(
                          label: 'Expense',
                          active: _isExpense,
                          activeColor: V2Colors.semanticWarning,
                          onTap: () => setState(() => _isExpense = true),
                        ),
                        _TypeChip(
                          label: 'Income',
                          active: !_isExpense,
                          activeColor: V2Colors.semanticPositive,
                          onTap: () => setState(() => _isExpense = false),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
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

            const SizedBox(height: 20),

            // Category Strip
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final selected = index == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? V2Colors.accentPrimary.withValues(alpha: 0.16)
                            : V2Colors.surfaceCard,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected
                              ? V2Colors.accentPrimary
                              : V2Colors.borderSubtle,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cat.icon,
                            size: 16,
                            color: selected
                                ? V2Colors.accentPrimary
                                : V2Colors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.label,
                            style: TextStyle(
                              color: selected
                                  ? V2Colors.textPrimary
                                  : V2Colors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Display Area
            Expanded(
              child: Center(
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
                          style: V2Typography.displayBalance(size: 46).copyWith(
                            color: _rawDigits.isEmpty
                                ? V2Colors.textMuted
                                : V2Colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isExpense
                          ? 'Category: ${_categories[_selectedCategory].label}'
                          : 'Income • ${_categories[_selectedCategory].label}',
                      style: V2Typography.labelMuted(size: 13),
                    ),
                  ],
                ),
              ),
            ),

            // Custom Numpad (4 rows x 3 cols)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _NumpadRow(
                    keys: const ['1', '2', '3'],
                    onKeyTap: _onKeyTap,
                  ),
                  const SizedBox(height: 10),
                  _NumpadRow(
                    keys: const ['4', '5', '6'],
                    onKeyTap: _onKeyTap,
                  ),
                  const SizedBox(height: 10),
                  _NumpadRow(
                    keys: const ['7', '8', '9'],
                    onKeyTap: _onKeyTap,
                  ),
                  const SizedBox(height: 10),
                  _NumpadRow(
                    keys: const ['.000', '0', 'back'],
                    onKeyTap: _onKeyTap,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Primary CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: InkWell(
                onTap: _rawDigits.isEmpty
                    ? null
                    : () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Saved ${_categories[_selectedCategory].label}: Rp $formatted',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _rawDigits.isEmpty
                        ? V2Colors.surfaceElevated
                        : V2Colors.accentPrimary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _isExpense ? 'Save Expense' : 'Save Income',
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
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? activeColor.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? activeColor : V2Colors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _NumpadRow extends StatelessWidget {
  final List<String> keys;
  final ValueChanged<String> onKeyTap;

  const _NumpadRow({required this.keys, required this.onKeyTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(keys.length, (index) {
        final key = keys[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == keys.length - 1 ? 0 : 10),
            child: InkWell(
              onTap: () => onKeyTap(key),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: V2Colors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
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
                        style: V2Typography.displayBalance(size: key == '.000' ? 18 : 22)
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
