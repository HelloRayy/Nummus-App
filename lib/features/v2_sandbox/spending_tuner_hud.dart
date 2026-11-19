import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';

class SpendingTunerConfig extends ChangeNotifier {
  double cardRadius = 18.0;
  double cardPadding = 18.0;
  double titleSize = 16.0;
  double descSize = 12.0;
  double barCount = 30.0;
  double barHeight = 24.0;
  double barGap = 4.0;
  double barRadius = 3.0;
  double thumbWidth = 6.0;
  double thumbExtraHeight = 8.0;
  double amountSize = 20.0;
  double progress = 0.42;

  void update({
    double? cardRadius,
    double? cardPadding,
    double? titleSize,
    double? descSize,
    double? barCount,
    double? barHeight,
    double? barGap,
    double? barRadius,
    double? thumbWidth,
    double? thumbExtraHeight,
    double? amountSize,
    double? progress,
  }) {
    if (cardRadius != null) this.cardRadius = cardRadius;
    if (cardPadding != null) this.cardPadding = cardPadding;
    if (titleSize != null) this.titleSize = titleSize;
    if (descSize != null) this.descSize = descSize;
    if (barCount != null) this.barCount = barCount;
    if (barHeight != null) this.barHeight = barHeight;
    if (barGap != null) this.barGap = barGap;
    if (barRadius != null) this.barRadius = barRadius;
    if (thumbWidth != null) this.thumbWidth = thumbWidth;
    if (thumbExtraHeight != null) this.thumbExtraHeight = thumbExtraHeight;
    if (amountSize != null) this.amountSize = amountSize;
    if (progress != null) this.progress = progress;
    notifyListeners();
  }

  void reset() {
    cardRadius = 18.0;
    cardPadding = 18.0;
    titleSize = 16.0;
    descSize = 12.0;
    barCount = 30.0;
    barHeight = 24.0;
    barGap = 4.0;
    barRadius = 3.0;
    thumbWidth = 6.0;
    thumbExtraHeight = 8.0;
    amountSize = 20.0;
    progress = 0.42;
    notifyListeners();
  }

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert({
      'component': 'V2SpendingTrackerCard',
      'cardRadius': double.parse(cardRadius.toStringAsFixed(1)),
      'cardPadding': double.parse(cardPadding.toStringAsFixed(1)),
      'titleSize': double.parse(titleSize.toStringAsFixed(1)),
      'descSize': double.parse(descSize.toStringAsFixed(1)),
      'barCount': barCount.round(),
      'barHeight': double.parse(barHeight.toStringAsFixed(1)),
      'barGap': double.parse(barGap.toStringAsFixed(1)),
      'barRadius': double.parse(barRadius.toStringAsFixed(1)),
      'thumbWidth': double.parse(thumbWidth.toStringAsFixed(1)),
      'thumbExtraHeight': double.parse(thumbExtraHeight.toStringAsFixed(1)),
      'amountSize': double.parse(amountSize.toStringAsFixed(1)),
      'progress': double.parse(progress.toStringAsFixed(2)),
    });
  }
}

class SpendingTunerHud extends StatefulWidget {
  final SpendingTunerConfig config;

  const SpendingTunerHud({super.key, required this.config});

  @override
  State<SpendingTunerHud> createState() => _SpendingTunerHudState();
}

class _SpendingTunerHudState extends State<SpendingTunerHud> {
  Offset _offset = const Offset(20, 420);

  void _openTunerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: V2Colors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: V2Colors.borderSubtle),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return ListenableBuilder(
              listenable: widget.config,
              builder: (_, _) {
                final c = widget.config;
                return SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Spending HUD', style: V2Typography.cardTitle()),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: c.reset,
                                  child: const Text(
                                    'Reset',
                                    style: TextStyle(color: V2Colors.textSecondary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: V2Colors.accentPrimary,
                                    foregroundColor: V2Colors.textPrimary,
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: c.toJsonString()),
                                    );
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Spending JSON copied'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy, size: 16),
                                  label: const Text('Copy JSON'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: V2Colors.borderSubtle, height: 1),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          children: [
                            _SliderRow(
                              label: 'Progress',
                              value: c.progress,
                              min: 0.05,
                              max: 0.95,
                              decimals: 2,
                              onChanged: (v) => c.update(progress: v),
                            ),
                            _SliderRow(
                              label: 'Card Radius',
                              value: c.cardRadius,
                              min: 8,
                              max: 32,
                              onChanged: (v) => c.update(cardRadius: v),
                            ),
                            _SliderRow(
                              label: 'Card Padding',
                              value: c.cardPadding,
                              min: 10,
                              max: 28,
                              onChanged: (v) => c.update(cardPadding: v),
                            ),
                            _SliderRow(
                              label: 'Title Font',
                              value: c.titleSize,
                              min: 12,
                              max: 22,
                              onChanged: (v) => c.update(titleSize: v),
                            ),
                            _SliderRow(
                              label: 'Desc Font',
                              value: c.descSize,
                              min: 10,
                              max: 16,
                              onChanged: (v) => c.update(descSize: v),
                            ),
                            _SliderRow(
                              label: 'Bar Count',
                              value: c.barCount,
                              min: 16,
                              max: 44,
                              onChanged: (v) => c.update(barCount: v),
                            ),
                            _SliderRow(
                              label: 'Bar Height',
                              value: c.barHeight,
                              min: 14,
                              max: 40,
                              onChanged: (v) => c.update(barHeight: v),
                            ),
                            _SliderRow(
                              label: 'Bar Gap',
                              value: c.barGap,
                              min: 2,
                              max: 8,
                              onChanged: (v) => c.update(barGap: v),
                            ),
                            _SliderRow(
                              label: 'Bar Radius',
                              value: c.barRadius,
                              min: 0,
                              max: 6,
                              onChanged: (v) => c.update(barRadius: v),
                            ),
                            _SliderRow(
                              label: 'Thumb Width',
                              value: c.thumbWidth,
                              min: 3,
                              max: 12,
                              onChanged: (v) => c.update(thumbWidth: v),
                            ),
                            _SliderRow(
                              label: 'Thumb Extra H',
                              value: c.thumbExtraHeight,
                              min: 0,
                              max: 16,
                              onChanged: (v) => c.update(thumbExtraHeight: v),
                            ),
                            _SliderRow(
                              label: 'Amount Font',
                              value: c.amountSize,
                              min: 16,
                              max: 28,
                              onChanged: (v) => c.update(amountSize: v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => _offset += details.delta),
        onTap: _openTunerSheet,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: V2Colors.accentPrimary,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: V2Colors.textPrimary.withValues(alpha: 0.2),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune, size: 16, color: V2Colors.textPrimary),
              SizedBox(width: 6),
              Text(
                'HUD',
                style: TextStyle(
                  color: V2Colors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int decimals;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.decimals = 0,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 135,
          child: Text(
            '$label (${value.toStringAsFixed(decimals)})',
            style: const TextStyle(color: V2Colors.textSecondary, fontSize: 12),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: V2Colors.accentPrimary,
            inactiveColor: V2Colors.borderSubtle,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
