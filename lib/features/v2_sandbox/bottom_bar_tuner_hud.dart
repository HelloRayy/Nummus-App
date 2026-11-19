import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';

class BottomBarTunerConfig extends ChangeNotifier {
  double horizontalPadding = 16.0;
  double bottomPadding = 14.0;
  double barHeight = 54.0;
  double gapBetween = 10.0;
  double ctaRadius = 999.0;
  double ctaFontSize = 15.0;
  double menuItemGap = 10.0;

  void update({
    double? horizontalPadding,
    double? bottomPadding,
    double? barHeight,
    double? gapBetween,
    double? ctaRadius,
    double? ctaFontSize,
    double? menuItemGap,
  }) {
    if (horizontalPadding != null) this.horizontalPadding = horizontalPadding;
    if (bottomPadding != null) this.bottomPadding = bottomPadding;
    if (barHeight != null) this.barHeight = barHeight;
    if (gapBetween != null) this.gapBetween = gapBetween;
    if (ctaRadius != null) this.ctaRadius = ctaRadius;
    if (ctaFontSize != null) this.ctaFontSize = ctaFontSize;
    if (menuItemGap != null) this.menuItemGap = menuItemGap;
    notifyListeners();
  }

  void reset() {
    horizontalPadding = 16.0;
    bottomPadding = 14.0;
    barHeight = 54.0;
    gapBetween = 10.0;
    ctaRadius = 999.0;
    ctaFontSize = 15.0;
    menuItemGap = 10.0;
    notifyListeners();
  }

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert({
      'component': 'V2BottomActionBar',
      'horizontalPadding': double.parse(horizontalPadding.toStringAsFixed(1)),
      'bottomPadding': double.parse(bottomPadding.toStringAsFixed(1)),
      'barHeight': double.parse(barHeight.toStringAsFixed(1)),
      'gapBetween': double.parse(gapBetween.toStringAsFixed(1)),
      'ctaRadius': double.parse(ctaRadius.toStringAsFixed(1)),
      'ctaFontSize': double.parse(ctaFontSize.toStringAsFixed(1)),
      'menuItemGap': double.parse(menuItemGap.toStringAsFixed(1)),
    });
  }
}

class BottomBarTunerHud extends StatefulWidget {
  final BottomBarTunerConfig config;

  const BottomBarTunerHud({super.key, required this.config});

  @override
  State<BottomBarTunerHud> createState() => _BottomBarTunerHudState();
}

class _BottomBarTunerHudState extends State<BottomBarTunerHud> {
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
                      label: 'Layout',
                      active: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                    const SizedBox(width: 6),
                    _TabChip(
                      label: 'Style',
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
                            content: Text('BottomBar JSON copied'),
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
                    label: 'Bottom Pad',
                    value: c.bottomPadding,
                    min: 4,
                    max: 28,
                    onChanged: (v) => c.update(bottomPadding: v),
                  ),
                  _CompactSlider(
                    label: 'Bar Height',
                    value: c.barHeight,
                    min: 44,
                    max: 68,
                    onChanged: (v) => c.update(barHeight: v),
                  ),
                  _CompactSlider(
                    label: 'Gap CTA-Menu',
                    value: c.gapBetween,
                    min: 6,
                    max: 20,
                    onChanged: (v) => c.update(gapBetween: v),
                  ),
                ] else ...[
                  _CompactSlider(
                    label: 'CTA Radius',
                    value: c.ctaRadius,
                    min: 12,
                    max: 999,
                    onChanged: (v) => c.update(ctaRadius: v),
                  ),
                  _CompactSlider(
                    label: 'CTA Font',
                    value: c.ctaFontSize,
                    min: 12,
                    max: 20,
                    onChanged: (v) => c.update(ctaFontSize: v),
                  ),
                  _CompactSlider(
                    label: 'Menu Gap',
                    value: c.menuItemGap,
                    min: 6,
                    max: 18,
                    onChanged: (v) => c.update(menuItemGap: v),
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
