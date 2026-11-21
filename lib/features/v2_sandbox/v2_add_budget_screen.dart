import 'dart:async';
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
  int _activeTab = 0; // 0 = Top-up, 1 = Set Limit

  String _addBudgetDigits = '';
  int _debouncedAdded = 0;
  String _adjustDigits = '';
  int _debouncedAdjust = 0;
  Timer? _debounceTimer;
  late double _weeklyLimit;

  @override
  void initState() {
    super.initState();
    final current = widget.repository.spendableBudget;
    _weeklyLimit = current > 0 ? current.toDouble() : 0.0;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _scheduleBalanceUpdate() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _debouncedAdded = int.tryParse(_addBudgetDigits) ?? 0;
        _debouncedAdjust = int.tryParse(_adjustDigits) ?? 0;
      });
    });
  }

  void _switchTab(int tab) {
    setState(() => _activeTab = tab);
    _pageController.animateToPage(
      tab,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  void _onKeyTap(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      var digits = _activeTab == 2 ? _adjustDigits : _addBudgetDigits;
      if (key == 'back') {
        if (digits.isNotEmpty) {
          digits = digits.substring(0, digits.length - 1);
        }
      } else if (key == '.000') {
        if (digits.isNotEmpty && digits != '0' && digits.length + 3 <= 12) {
          digits += '000';
        }
      } else if (digits.length < 12) {
        if (digits == '0') {
          digits = key;
        } else {
          digits += key;
        }
      }
      if (_activeTab == 2) {
        _adjustDigits = digits;
      } else {
        _addBudgetDigits = digits;
      }
    });
    _scheduleBalanceUpdate();
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
    final addedAmount = int.tryParse(_addBudgetDigits) ?? 0;
    final adjustAmount = int.tryParse(_adjustDigits);
    final canSaveTopUp = _activeTab == 0 && addedAmount > 0;
    final canSaveAdjust = _activeTab == 2 && adjustAmount != null;
    final canSave = _activeTab == 1 || canSaveTopUp || canSaveAdjust;

    return Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Back + Centered Title + Top-right Save CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(12.2, 12, 12.2, 0),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Budget',
                        style: V2Typography.cardTitle(size: 16),
                      ),
                    ),
                    Row(
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
                        InkWell(
                          onTap: !canSave
                              ? null
                              : () async {
                                  if (_activeTab == 0) {
                                    await widget.repository
                                        .addTopUp(addedAmount);
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Added budget: +Rp ${_formatRupiah(addedAmount)}',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  } else if (_activeTab == 2 &&
                                      adjustAmount != null) {
                                    await widget.repository.adjustRealBalance(
                                      actualBalance: adjustAmount,
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Adjusted budget to Rp ${_formatRupiah(adjustAmount)}',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    final currentAvailable = widget.repository
                                        .remainingWeeklySpendable;
                                    final totalPool = currentAvailable > 0
                                        ? currentAvailable
                                        : 0;
                                    final maxSlider =
                                        (totalPool > 0 ? totalPool : 1000000)
                                            .toDouble();
                                    final activeLimit =
                                        _weeklyLimit.clamp(0.0, maxSlider);
                                    final savings =
                                        (totalPool - activeLimit.round())
                                            .clamp(0, totalPool);
                                    await widget.repository.updateBudget(
                                      weeklyIncome: totalPool,
                                      weeklySavingsTarget: savings,
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Limit updated: Rp ${_formatRupiah(activeLimit.round())}',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: !canSave
                                    ? V2Colors.textMuted
                                    : V2Colors.accentPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Full-width Underline Tab Bar
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: V2Colors.borderSubtle),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _UnderlineTab(
                      label: 'Top-up',
                      active: _activeTab == 0,
                      activeColor: V2Colors.accentPrimary,
                      onTap: () => _switchTab(0),
                    ),
                  ),
                  Expanded(
                    child: _UnderlineTab(
                      label: 'Set Limit',
                      active: _activeTab == 1,
                      activeColor: V2Colors.accentPrimary,
                      onTap: () => _switchTab(1),
                    ),
                  ),
                  Expanded(
                    child: _UnderlineTab(
                      label: 'Adjust',
                      active: _activeTab == 2,
                      activeColor: V2Colors.accentPrimary,
                      onTap: () => _switchTab(2),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _activeTab = index),
                children: [
                  _buildTopUpTab(),
                  _buildSetLimitTab(),
                  _buildAdjustTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpTab() {
    const double horizontalPadding = 12.2;
    const double sheetRadius = 40.0;
    const double amountSize = 58.0;
    const double keyHeight = 60.5;
    const double keyGap = 6.0;
    const double keyRadius = 28.0;
    const double keyFontSize = 19.7;
    const double ctaHeight = 58.4;

    final addedAmount = int.tryParse(_addBudgetDigits) ?? 0;
    final formatted = _formatRupiah(addedAmount);

    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              Text(
                'How much do you want to add?',
                textAlign: TextAlign.center,
                style: V2Typography.headlineGreeting(size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter the amount to top up your weekly budget.',
                textAlign: TextAlign.center,
                style: V2Typography.labelMuted(size: 13),
              ),
            ],
          ),
        ),
        const Spacer(),
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
                    style: V2Typography.displayBalance(size: amountSize).copyWith(
                      color: addedAmount == 0
                          ? V2Colors.textMuted
                          : V2Colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TweenAnimationBuilder<int>(
                tween: IntTween(
                  begin: widget.repository.remainingWeeklySpendable +
                      _debouncedAdded,
                  end: widget.repository.remainingWeeklySpendable +
                      _debouncedAdded,
                ),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuart,
                builder: (_, animatedVal, _) {
                  final isAdding = _debouncedAdded > 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isAdding) ...[
                        const Icon(
                          Icons.arrow_upward_rounded,
                          size: 14,
                          color: V2Colors.semanticPositive,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        'Current balance: Rp ${_formatRupiah(animatedVal)}',
                        style: V2Typography.labelMuted(size: 12).copyWith(
                          color: isAdding
                              ? V2Colors.semanticPositive
                              : V2Colors.textMuted,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSetLimitTab() {
    final currentAvailable = widget.repository.remainingWeeklySpendable;
    final totalPool = currentAvailable > 0 ? currentAvailable : 0;
    final maxSlider = (totalPool > 0 ? totalPool : 1000000).toDouble();
    final activeLimit = _weeklyLimit.clamp(0.0, maxSlider);

    final now = DateTime.now();
    final remainingDays = (8 - now.weekday).clamp(1, 7);
    final dailyLimit = ((activeLimit / remainingDays).floor() ~/ 500) * 500;
    final savings = (totalPool - activeLimit.round()).clamp(0, totalPool);

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
            'Total budget: Rp ${_formatRupiah(totalPool)}',
            style: V2Typography.labelMuted(size: 13),
          ),
          const SizedBox(height: 24),
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
                  'Rp ${_formatRupiah(activeLimit.round())}',
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
                    value: activeLimit,
                    min: 0,
                    max: maxSlider,
                    activeColor: V2Colors.accentPrimary,
                    inactiveColor: V2Colors.borderSubtle,
                    onChanged: (v) {
                      final snapped = ((v / 1000).round() * 1000).toDouble();
                      setState(() => _weeklyLimit = snapped);
                    },
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
                          'Max per hari ($remainingDays hari sisa)',
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
                          'Saved',
                          style: V2Typography.labelMuted(size: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${_formatRupiah(savings)}',
                          style: V2Typography.displayBalance(size: 16)
                              .copyWith(color: V2Colors.semanticPositive),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
  Widget _buildAdjustTab() {
    const double horizontalPadding = 12.2;
    const double sheetRadius = 40.0;
    const double amountSize = 58.0;
    const double keyHeight = 60.5;
    const double keyGap = 6.0;
    const double keyRadius = 28.0;
    const double keyFontSize = 19.7;

    final adjustAmount = int.tryParse(_adjustDigits) ?? 0;
    final formatted = _formatRupiah(adjustAmount);
    final currentBalance = widget.repository.remainingWeeklySpendable;
    final diff = _debouncedAdjust - currentBalance;

    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              Text(
                'Adjust to real balance',
                textAlign: TextAlign.center,
                style: V2Typography.headlineGreeting(size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                'Match your current budget with your actual e-wallet.',
                textAlign: TextAlign.center,
                style: V2Typography.labelMuted(size: 13),
              ),
            ],
          ),
        ),
        const Spacer(),
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
                    style: V2Typography.displayBalance(size: amountSize).copyWith(
                      color: _adjustDigits.isEmpty
                          ? V2Colors.textMuted
                          : V2Colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _adjustDigits.isEmpty
                    ? 'Current: Rp ${_formatRupiah(currentBalance)}'
                    : 'Diff: ${diff >= 0 ? '+' : '-'}Rp ${_formatRupiah(diff.abs())}',
                style: V2Typography.labelMuted(size: 12).copyWith(
                  color: _adjustDigits.isEmpty
                      ? V2Colors.textMuted
                      : (diff >= 0
                          ? V2Colors.semanticPositive
                          : V2Colors.semanticDanger),
                ),
              ),
              const SizedBox(height: 20),
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
            ],
          ),
        ),
      ],
    );
  }
}

class _UnderlineTab extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _UnderlineTab({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                color: active ? activeColor : V2Colors.textMuted,
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2.5,
            width: active ? 72 : 0,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(999),
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
