import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';

class PlannerTunerConfig extends ChangeNotifier {
  double horizontalPadding = 16.0;
  double summaryRadius = 20.0;
  double summaryPadding = 14.0;
  double summaryAmountSize = 22.0;
  double listItemRadius = 14.0;
  double sheetRadius = 32.0;
  double displayAmountSize = 26.0;
  double keyHeight = 48.0;
  double keyGap = 6.0;
  double keyRadius = 24.0;

  void update({
    double? horizontalPadding,
    double? summaryRadius,
    double? summaryPadding,
    double? summaryAmountSize,
    double? listItemRadius,
    double? sheetRadius,
    double? displayAmountSize,
    double? keyHeight,
    double? keyGap,
    double? keyRadius,
  }) {
    if (horizontalPadding != null) this.horizontalPadding = horizontalPadding;
    if (summaryRadius != null) this.summaryRadius = summaryRadius;
    if (summaryPadding != null) this.summaryPadding = summaryPadding;
    if (summaryAmountSize != null) this.summaryAmountSize = summaryAmountSize;
    if (listItemRadius != null) this.listItemRadius = listItemRadius;
    if (sheetRadius != null) this.sheetRadius = sheetRadius;
    if (displayAmountSize != null) this.displayAmountSize = displayAmountSize;
    if (keyHeight != null) this.keyHeight = keyHeight;
    if (keyGap != null) this.keyGap = keyGap;
    if (keyRadius != null) this.keyRadius = keyRadius;
    notifyListeners();
  }

  void reset() {
    horizontalPadding = 16.0;
    summaryRadius = 20.0;
    summaryPadding = 14.0;
    summaryAmountSize = 22.0;
    listItemRadius = 14.0;
    sheetRadius = 32.0;
    displayAmountSize = 26.0;
    keyHeight = 48.0;
    keyGap = 6.0;
    keyRadius = 24.0;
    notifyListeners();
  }

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert({
      'component': 'V2BudgetPlannerScreen',
      'horizontalPadding': double.parse(horizontalPadding.toStringAsFixed(1)),
      'summaryRadius': double.parse(summaryRadius.toStringAsFixed(1)),
      'summaryPadding': double.parse(summaryPadding.toStringAsFixed(1)),
      'summaryAmountSize': double.parse(summaryAmountSize.toStringAsFixed(1)),
      'listItemRadius': double.parse(listItemRadius.toStringAsFixed(1)),
      'sheetRadius': double.parse(sheetRadius.toStringAsFixed(1)),
      'displayAmountSize': double.parse(displayAmountSize.toStringAsFixed(1)),
      'keyHeight': double.parse(keyHeight.toStringAsFixed(1)),
      'keyGap': double.parse(keyGap.toStringAsFixed(1)),
      'keyRadius': double.parse(keyRadius.toStringAsFixed(1)),
    });
  }
}

class PlannerTunerHud extends StatefulWidget {
  final PlannerTunerConfig config;

  const PlannerTunerHud({super.key, required this.config});

  @override
  State<PlannerTunerHud> createState() => _PlannerTunerHudState();
}

class _PlannerTunerHudState extends State<PlannerTunerHud> {
  bool _isExpanded = true;
  bool _dockBottom = false;
  int _tabIndex = 0;

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
                Icon(Icons.tune, size: 16, color: V2Colors.bgPrimary),
                SizedBox(width: 6),
                Text(
                  'HUD',
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
                    _TabChip(
                      label: 'Summary',
                      active: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                    const SizedBox(width: 6),
                    _TabChip(
                      label: 'Numpad',
                      active: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => _dockBottom = !_dockBottom),
                      icon: Icon(
                        _dockBottom ? Icons.vertical_align_top : Icons.vertical_align_bottom,
                        size: 18,
                        color: V2Colors.textSecondary,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: c.reset,
                      icon: const Icon(Icons.refresh, size: 18, color: V2Colors.textSecondary),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: c.toJsonString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Planner JSON copied'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18, color: V2Colors.accentPrimary),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => _isExpanded = false),
                      icon: const Icon(Icons.close, size: 18, color: V2Colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (_tabIndex == 0) ...[
                  _CompactSlider(
                    label: 'Padding H',
                    value: c.horizontalPadding,
                    min: 8,
                    max: 28,
                    onChanged: (v) => c.update(horizontalPadding: v),
                  ),
                  _CompactSlider(
                    label: 'Sum Radius',
                    value: c.summaryRadius,
                    min: 8,
                    max: 32,
                    onChanged: (v) => c.update(summaryRadius: v),
                  ),
                  _CompactSlider(
                    label: 'Sum Pad',
                    value: c.summaryPadding,
                    min: 8,
                    max: 24,
                    onChanged: (v) => c.update(summaryPadding: v),
                  ),
                  _CompactSlider(
                    label: 'Sum Font',
                    value: c.summaryAmountSize,
                    min: 16,
                    max: 34,
                    onChanged: (v) => c.update(summaryAmountSize: v),
                  ),
                  _CompactSlider(
                    label: 'Item Radius',
                    value: c.listItemRadius,
                    min: 8,
                    max: 24,
                    onChanged: (v) => c.update(listItemRadius: v),
                  ),
                ] else ...[
                  _CompactSlider(
                    label: 'Sheet Radius',
                    value: c.sheetRadius,
                    min: 12,
                    max: 40,
                    onChanged: (v) => c.update(sheetRadius: v),
                  ),
                  _CompactSlider(
                    label: 'Input Font',
                    value: c.displayAmountSize,
                    min: 18,
                    max: 38,
                    onChanged: (v) => c.update(displayAmountSize: v),
                  ),
                  _CompactSlider(
                    label: 'Key Height',
                    value: c.keyHeight,
                    min: 38,
                    max: 64,
                    onChanged: (v) => c.update(keyHeight: v),
                  ),
                  _CompactSlider(
                    label: 'Key Gap',
                    value: c.keyGap,
                    min: 4,
                    max: 14,
                    onChanged: (v) => c.update(keyGap: v),
                  ),
                  _CompactSlider(
                    label: 'Key Radius',
                    value: c.keyRadius,
                    min: 8,
                    max: 32,
                    onChanged: (v) => c.update(keyRadius: v),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? V2Colors.accentPrimary : V2Colors.surfaceElevated,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? V2Colors.bgPrimary : V2Colors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CompactSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _CompactSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              '$label (${value.toStringAsFixed(0)})',
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
