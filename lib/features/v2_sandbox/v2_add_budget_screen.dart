import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';
import '../budget/repository/budget_repository.dart';

class V2AddBudgetScreen extends StatefulWidget {
  final BudgetRepository repository;

  const V2AddBudgetScreen({super.key, required this.repository});

  @override
  State<V2AddBudgetScreen> createState() => _V2AddBudgetScreenState();
}

class _V2AddBudgetScreenState extends State<V2AddBudgetScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Add Budget
  String _addBudgetDigits = '';

  // Step 2: Set Limit
  late double _monthlyLimit;

  @override
  void initState() {
    super.initState();
    final current = widget.repository.spendableBudget;
    _monthlyLimit = (current >= 500000 && current <= 15000000)
        ? current.toDouble()
        : 3280000;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onKeyTap(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == 'back') {
        if (_addBudgetDigits.isNotEmpty) {
          _addBudgetDigits =
              _addBudgetDigits.substring(0, _addBudgetDigits.length - 1);
        }
        return;
      }
      if (key == '.000') {
        if (_addBudgetDigits.isEmpty || _addBudgetDigits == '0') return;
        if (_addBudgetDigits.length + 3 <= 12) {
          _addBudgetDigits += '000';
        }
        return;
      }
      if (_addBudgetDigits.length >= 12) return;
      if (_addBudgetDigits == '0') {
        _addBudgetDigits = key;
      } else {
        _addBudgetDigits += key;
      }
    });
  }

  String _formatRupiah(int amount) {
    final digits = amount.toString();
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
    return Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Step Indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(12.2, 12, 12.2, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      if (_currentStep == 1) {
                        _goToStep(0);
                      } else {
                        Navigator.pop(context);
                      }
                    },
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
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: V2Colors.surfaceCard,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: V2Colors.borderSubtle),
                    ),
                    child: Text(
                      'Step ${_currentStep + 1} of 2',
                      style: const TextStyle(
                        color: V2Colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1AddBudget(),
                  _buildStep2SetLimit(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1AddBudget() {
    const double horizontalPadding = 12.2;
    const double keyHeight = 60.5;
    const double keyGap = 6.0;
    const double keyRadius = 28.0;
    const double keyFontSize = 19.7;
    const double ctaHeight = 58.4;

    final addedAmount = int.tryParse(_addBudgetDigits) ?? 0;
    final formatted = _formatRupiah(addedAmount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        horizontalPadding,
        20,
        horizontalPadding,
        16,
      ),
      child: Column(
        children: [
          Text(
            'How much do you want to add?',
            textAlign: TextAlign.center,
            style: V2Typography.headlineGreeting(size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter the amount to top up your monthly budget.',
            textAlign: TextAlign.center,
            style: V2Typography.labelMuted(size: 13),
          ),
          const SizedBox(height: 24),
          Text(
            'Enter Amount',
            style: V2Typography.labelMuted(size: 12),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 96,
            decoration: BoxDecoration(
              color: V2Colors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: V2Colors.borderSubtle),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Rp ',
                  style: V2Typography.displayBalance(size: 22)
                      .copyWith(color: V2Colors.textMuted),
                ),
                Text(
                  formatted,
                  style: V2Typography.displayBalance(size: 40).copyWith(
                    color: addedAmount == 0
                        ? V2Colors.textMuted
                        : V2Colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

              // Custom Numpad
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

              // 2 CTAs: Lewati & Tambah
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() => _addBudgetDigits = '');
                        _goToStep(1);
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: ctaHeight,
                        decoration: BoxDecoration(
                          color: V2Colors.surfaceElevated,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: V2Colors.borderSubtle),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Lewati',
                          style: TextStyle(
                            color: V2Colors.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: addedAmount == 0 ? null : () => _goToStep(1),
                      borderRadius: BorderRadius.circular(999),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: ctaHeight,
                        decoration: BoxDecoration(
                          color: addedAmount == 0
                              ? V2Colors.surfaceElevated
                              : V2Colors.semanticPositive,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Tambah',
                          style: TextStyle(
                            color: addedAmount == 0
                                ? V2Colors.textMuted
                                : V2Colors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
  }

  Widget _buildStep2SetLimit() {
    final addedAmount = int.tryParse(_addBudgetDigits) ?? 0;
    final now = DateTime.now();
    final remainingDays = (8 - now.weekday).clamp(1, 7);
    final dailyLimit = (_monthlyLimit / remainingDays).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Weekly Limit',
            style: V2Typography.headlineGreeting(size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            addedAmount > 0
                ? 'Added +Rp ${_formatRupiah(addedAmount)} to this week.'
                : 'Adjust your weekly spending limit (Mon - Sun).',
            style: V2Typography.labelMuted(size: 13),
          ),
          const SizedBox(height: 24),

          // Limit Card + Daily Breakdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: V2Colors.surfaceCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: V2Colors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Spending Limit',
                  style: V2Typography.labelMuted(size: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${_formatRupiah(_monthlyLimit.round())}',
                  style: V2Typography.displayBalance(size: 34),
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _monthlyLimit,
                    min: 500000,
                    max: 15000000,
                    divisions: 145,
                    activeColor: V2Colors.accentPrimary,
                    inactiveColor: V2Colors.borderSubtle,
                    onChanged: (v) => setState(() => _monthlyLimit = v),
                  ),
                ),
                const Divider(color: V2Colors.borderSubtle, height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily budget ($remainingDays days left)',
                          style: V2Typography.labelMuted(size: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${_formatRupiah(dailyLimit)} / hari',
                          style: V2Typography.displayBalance(size: 20)
                              .copyWith(color: V2Colors.accentPrimary),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Weekly avg',
                          style: V2Typography.labelMuted(size: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${_formatRupiah(dailyLimit * 7)}',
                          style: V2Typography.displayBalance(size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Save & Finish CTA
          InkWell(
            onTap: () async {
              if (addedAmount > 0) {
                await widget.repository.addTopUp(addedAmount);
              }
              await widget.repository.updateBudget(
                weeklyIncome: _monthlyLimit.round(),
                weeklySavingsTarget: widget.repository.weeklySavingsTarget,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Limit set: Rp ${_formatRupiah(_monthlyLimit.round())} (Rp ${_formatRupiah(dailyLimit)}/hari)',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 58.4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: V2Colors.accentPrimary,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Save & Finish',
                style: TextStyle(
                  color: V2Colors.bgPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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
