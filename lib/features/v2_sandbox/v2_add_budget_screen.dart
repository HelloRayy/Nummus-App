import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';

class V2AddBudgetScreen extends StatefulWidget {
  const V2AddBudgetScreen({super.key});

  @override
  State<V2AddBudgetScreen> createState() => _V2AddBudgetScreenState();
}

class _V2AddBudgetScreenState extends State<V2AddBudgetScreen> {
  String _rawDigits = '';
  bool _isTopUp = true;

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
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: V2Colors.surfaceCard,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: V2Colors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        _ModeChip(
                          label: 'Top-up',
                          active: _isTopUp,
                          onTap: () => setState(() => _isTopUp = true),
                        ),
                        _ModeChip(
                          label: 'Set Limit',
                          active: !_isTopUp,
                          onTap: () => setState(() => _isTopUp = false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom Sheet Container
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
                    'Current limit: Rp 3.280.450',
                    style: V2Typography.labelMuted(size: 12),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final preset in const [
                        (label: '+50k', amount: 50000),
                        (label: '+100k', amount: 100000),
                        (label: '+500k', amount: 500000),
                        (label: '+1M', amount: 1000000),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                final current = int.tryParse(_rawDigits) ?? 0;
                                _rawDigits = (current + preset.amount).toString();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: V2Colors.surfaceElevated,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: V2Colors.borderSubtle),
                              ),
                              child: Text(
                                preset.label,
                                style: const TextStyle(
                                  color: V2Colors.semanticPositive,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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

                  // Primary CTA (Emerald)
                  InkWell(
                    onTap: _rawDigits.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _isTopUp
                                      ? 'Added budget: +Rp $formatted'
                                      : 'Updated limit: Rp $formatted',
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
                            : V2Colors.semanticPositive,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _isTopUp ? 'Add Budget' : 'Update Limit',
                        style: TextStyle(
                          color: _rawDigits.isEmpty
                              ? V2Colors.textMuted
                              : V2Colors.textPrimary,
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

class _ModeChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.active,
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
          color: active
              ? V2Colors.semanticPositive.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? V2Colors.semanticPositive : V2Colors.textMuted,
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
