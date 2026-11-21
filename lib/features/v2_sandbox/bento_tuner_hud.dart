import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';

class BentoTunerConfig extends ChangeNotifier {
  double horizontalPadding = 16.0;
  double gridGap = 12.0;
  double cardRadius = 20.0;
  double cardPadding = 16.0;
  double titleSize = 14.0;
  double valueSize = 22.0;
  double subLabelSize = 12.0;
  double titleValueGap = 8.0;
  double valueSubGap = 6.0;

  void update({
    double? horizontalPadding,
    double? gridGap,
    double? cardRadius,
    double? cardPadding,
    double? titleSize,
    double? valueSize,
    double? subLabelSize,
    double? titleValueGap,
    double? valueSubGap,
  }) {
    if (horizontalPadding != null) this.horizontalPadding = horizontalPadding;
    if (gridGap != null) this.gridGap = gridGap;
    if (cardRadius != null) this.cardRadius = cardRadius;
    if (cardPadding != null) this.cardPadding = cardPadding;
    if (titleSize != null) this.titleSize = titleSize;
    if (valueSize != null) this.valueSize = valueSize;
    if (subLabelSize != null) this.subLabelSize = subLabelSize;
    if (titleValueGap != null) this.titleValueGap = titleValueGap;
    if (valueSubGap != null) this.valueSubGap = valueSubGap;
    notifyListeners();
  }

  void reset() {
    horizontalPadding = 16.0;
    gridGap = 12.0;
    cardRadius = 20.0;
    cardPadding = 16.0;
    titleSize = 14.0;
    valueSize = 22.0;
    subLabelSize = 12.0;
    titleValueGap = 8.0;
    valueSubGap = 6.0;
    notifyListeners();
  }

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert({
      'component': 'V2BentoMetricGrid',
      'horizontalPadding': double.parse(horizontalPadding.toStringAsFixed(1)),
      'gridGap': double.parse(gridGap.toStringAsFixed(1)),
      'cardRadius': double.parse(cardRadius.toStringAsFixed(1)),
      'cardPadding': double.parse(cardPadding.toStringAsFixed(1)),
      'titleSize': double.parse(titleSize.toStringAsFixed(1)),
      'valueSize': double.parse(valueSize.toStringAsFixed(1)),
      'subLabelSize': double.parse(subLabelSize.toStringAsFixed(1)),
      'titleValueGap': double.parse(titleValueGap.toStringAsFixed(1)),
      'valueSubGap': double.parse(valueSubGap.toStringAsFixed(1)),
    });
  }
}

class BentoTunerHud extends StatefulWidget {
  final BentoTunerConfig config;

  const BentoTunerHud({super.key, required this.config});

  @override
  State<BentoTunerHud> createState() => _BentoTunerHudState();
}

class _BentoTunerHudState extends State<BentoTunerHud> {
  bool _isExpanded = true;
  bool _dockBottom = true;
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
                      label: 'Text',
                      active: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1),
                    ),
                    const SizedBox(width: 6),
                    _TabChip(
                      label: 'Gap',
                      active: _tabIndex == 2,
                      onTap: () => setState(() => _tabIndex = 2),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Flip Top/Bottom',
                      onPressed: () => setState(() => _dockBottom = !_dockBottom),
                      icon: Icon(
                        _dockBottom ? Icons.vertical_align_top : Icons.vertical_align_bottom,
                        size: 18,
                        color: V2Colors.textSecondary,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Reset',
                      onPressed: c.reset,
                      icon: const Icon(Icons.refresh, size: 18, color: V2Colors.textSecondary),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Copy JSON',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: c.toJsonString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bento JSON copied'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18, color: V2Colors.accentPrimary),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Minimize',
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
                    label: 'Grid Gap',
                    value: c.gridGap,
                    min: 6,
                    max: 24,
                    onChanged: (v) => c.update(gridGap: v),
                  ),
                  _CompactSlider(
                    label: 'Card Radius',
                    value: c.cardRadius,
                    min: 8,
                    max: 32,
                    onChanged: (v) => c.update(cardRadius: v),
                  ),
                  _CompactSlider(
                    label: 'Card Pad',
                    value: c.cardPadding,
                    min: 8,
                    max: 24,
                    onChanged: (v) => c.update(cardPadding: v),
                  ),
                ] else if (_tabIndex == 1) ...[
                  _CompactSlider(
                    label: 'Title Font',
                    value: c.titleSize,
                    min: 11,
                    max: 18,
                    onChanged: (v) => c.update(titleSize: v),
                  ),
                  _CompactSlider(
                    label: 'Value Font',
                    value: c.valueSize,
                    min: 16,
                    max: 30,
                    onChanged: (v) => c.update(valueSize: v),
                  ),
                  _CompactSlider(
                    label: 'Sub Font',
                    value: c.subLabelSize,
                    min: 10,
                    max: 16,
                    onChanged: (v) => c.update(subLabelSize: v),
                  ),
                ] else ...[
                  _CompactSlider(
                    label: 'Title-Val Gap',
                    value: c.titleValueGap,
                    min: 2,
                    max: 18,
                    onChanged: (v) => c.update(titleValueGap: v),
                  ),
                  _CompactSlider(
                    label: 'Val-Sub Gap',
                    value: c.valueSubGap,
                    min: 2,
                    max: 16,
                    onChanged: (v) => c.update(valueSubGap: v),
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
            color: active ? V2Colors.textPrimary : V2Colors.textSecondary,
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
