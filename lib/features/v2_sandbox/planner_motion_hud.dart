import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';

class PlannerMotionConfig extends ChangeNotifier {
  double rollDurationMs = 400.0;
  double chartDurationMs = 400.0;
  double cardPopScale = 1.025;
  double cardPopMs = 180.0;
  int curveIndex = 0; // 0: easeOutQuart, 1: easeOutCubic, 2: easeOutBack

  static const curveNames = ['easeOutQuart', 'easeOutCubic', 'easeOutBack'];

  Curve get curve {
    switch (curveIndex) {
      case 1:
        return Curves.easeOutCubic;
      case 2:
        return Curves.easeOutBack;
      default:
        return Curves.easeOutQuart;
    }
  }

  void update({
    double? rollDurationMs,
    double? chartDurationMs,
    double? cardPopScale,
    double? cardPopMs,
    int? curveIndex,
  }) {
    if (rollDurationMs != null) this.rollDurationMs = rollDurationMs;
    if (chartDurationMs != null) this.chartDurationMs = chartDurationMs;
    if (cardPopScale != null) this.cardPopScale = cardPopScale;
    if (cardPopMs != null) this.cardPopMs = cardPopMs;
    if (curveIndex != null) this.curveIndex = curveIndex;
    notifyListeners();
  }

  void reset() {
    rollDurationMs = 400.0;
    chartDurationMs = 400.0;
    cardPopScale = 1.025;
    cardPopMs = 180.0;
    curveIndex = 0;
    notifyListeners();
  }

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert({
      'component': 'V2PlannerMotion',
      'rollDurationMs': rollDurationMs.round(),
      'chartDurationMs': chartDurationMs.round(),
      'cardPopScale': double.parse(cardPopScale.toStringAsFixed(3)),
      'cardPopMs': cardPopMs.round(),
      'curve': curveNames[curveIndex],
    });
  }
}

class PlannerMotionHud extends StatefulWidget {
  final PlannerMotionConfig config;

  const PlannerMotionHud({super.key, required this.config});

  @override
  State<PlannerMotionHud> createState() => _PlannerMotionHudState();
}

class _PlannerMotionHudState extends State<PlannerMotionHud> {
  bool _isExpanded = true;
  bool _dockBottom = false;

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) {
      return Positioned(
        right: 16,
        bottom: _dockBottom ? 16 : null,
        top: _dockBottom ? null : 16,
        child: GestureDetector(
          onTap: () => setState(() => _isExpanded = true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: V2Colors.accentPrimary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.animation, size: 16, color: V2Colors.bgPrimary),
                SizedBox(width: 6),
                Text(
                  'Motion HUD',
                  style: TextStyle(
                    color: V2Colors.bgPrimary,
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

    return Positioned(
      left: 12,
      right: 12,
      bottom: _dockBottom ? 12 : null,
      top: _dockBottom ? null : 12,
      child: ListenableBuilder(
        listenable: widget.config,
        builder: (_, _) {
          final c = widget.config;
          return Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: V2Colors.surfaceCard.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: V2Colors.borderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Planner Motion HUD',
                      style: TextStyle(
                        color: V2Colors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => _dockBottom = !_dockBottom),
                      icon: Icon(
                        _dockBottom
                            ? Icons.vertical_align_top
                            : Icons.vertical_align_bottom,
                        size: 18,
                        color: V2Colors.textSecondary,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: c.reset,
                      icon: const Icon(
                        Icons.refresh,
                        size: 18,
                        color: V2Colors.textSecondary,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: c.toJsonString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Planner Motion JSON copied'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.copy,
                        size: 18,
                        color: V2Colors.accentPrimary,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => _isExpanded = false),
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: V2Colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                _CompactSlider(
                  label: 'Roll ms',
                  value: c.rollDurationMs,
                  min: 150,
                  max: 1000,
                  onChanged: (v) => c.update(rollDurationMs: v),
                ),
                _CompactSlider(
                  label: 'Chart ms',
                  value: c.chartDurationMs,
                  min: 150,
                  max: 1000,
                  onChanged: (v) => c.update(chartDurationMs: v),
                ),
                _CompactSlider(
                  label: 'Card Pop',
                  value: c.cardPopScale,
                  min: 1.0,
                  max: 1.06,
                  decimals: 3,
                  onChanged: (v) => c.update(cardPopScale: v),
                ),
                _CompactSlider(
                  label: 'Pop ms',
                  value: c.cardPopMs,
                  min: 80,
                  max: 400,
                  onChanged: (v) => c.update(cardPopMs: v),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(PlannerMotionConfig.curveNames.length, (i) {
                    final active = c.curveIndex == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => c.update(curveIndex: i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? V2Colors.accentPrimary
                                : V2Colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            PlannerMotionConfig.curveNames[i],
                            style: TextStyle(
                              color: active
                                  ? V2Colors.bgPrimary
                                  : V2Colors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CompactSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int decimals;
  final ValueChanged<double> onChanged;

  const _CompactSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.decimals = 0,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          SizedBox(
            width: 115,
            child: Text(
              '$label (${value.toStringAsFixed(decimals)})',
              style: const TextStyle(color: V2Colors.textSecondary, fontSize: 11),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                activeColor: V2Colors.accentPrimary,
                inactiveColor: V2Colors.borderSubtle,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
