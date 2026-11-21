import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';

class NumpadTunerConfig extends ChangeNotifier {
  double horizontalPadding = 16.0;
  double sheetRadius = 28.0;
  double amountSize = 44.0;
  double keyHeight = 56.0;
  double keyGap = 10.0;
  double keyRadius = 16.0;
  double keyFontSize = 22.0;
  double ctaHeight = 58.0;

  void update({
    double? horizontalPadding,
    double? sheetRadius,
    double? amountSize,
    double? keyHeight,
    double? keyGap,
    double? keyRadius,
    double? keyFontSize,
    double? ctaHeight,
  }) {
    if (horizontalPadding != null) this.horizontalPadding = horizontalPadding;
    if (sheetRadius != null) this.sheetRadius = sheetRadius;
    if (amountSize != null) this.amountSize = amountSize;
    if (keyHeight != null) this.keyHeight = keyHeight;
    if (keyGap != null) this.keyGap = keyGap;
    if (keyRadius != null) this.keyRadius = keyRadius;
    if (keyFontSize != null) this.keyFontSize = keyFontSize;
    if (ctaHeight != null) this.ctaHeight = ctaHeight;
    notifyListeners();
  }

  void reset() {
    horizontalPadding = 16.0;
    sheetRadius = 28.0;
    amountSize = 44.0;
    keyHeight = 56.0;
    keyGap = 10.0;
    keyRadius = 16.0;
    keyFontSize = 22.0;
    ctaHeight = 58.0;
    notifyListeners();
  }

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert({
      'component': 'V2NumpadScreen',
      'horizontalPadding': double.parse(horizontalPadding.toStringAsFixed(1)),
      'sheetRadius': double.parse(sheetRadius.toStringAsFixed(1)),
      'amountSize': double.parse(amountSize.toStringAsFixed(1)),
      'keyHeight': double.parse(keyHeight.toStringAsFixed(1)),
      'keyGap': double.parse(keyGap.toStringAsFixed(1)),
      'keyRadius': double.parse(keyRadius.toStringAsFixed(1)),
      'keyFontSize': double.parse(keyFontSize.toStringAsFixed(1)),
      'ctaHeight': double.parse(ctaHeight.toStringAsFixed(1)),
    });
  }
}

class NumpadTunerHud extends StatefulWidget {
  final NumpadTunerConfig config;

  const NumpadTunerHud({super.key, required this.config});

  @override
  State<NumpadTunerHud> createState() => _NumpadTunerHudState();
}

class _NumpadTunerHudState extends State<NumpadTunerHud> {
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
                      label: 'Numpad',
                      active: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                    const SizedBox(width: 6),
                    _TabChip(
                      label: 'Layout',
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
                            content: Text('Numpad JSON copied'),
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
                    label: 'Key Height',
                    value: c.keyHeight,
                    min: 44,
                    max: 72,
                    onChanged: (v) => c.update(keyHeight: v),
                  ),
                  _CompactSlider(
                    label: 'Key Gap',
                    value: c.keyGap,
                    min: 6,
                    max: 18,
                    onChanged: (v) => c.update(keyGap: v),
                  ),
                  _CompactSlider(
                    label: 'Key Radius',
                    value: c.keyRadius,
                    min: 8,
                    max: 28,
                    onChanged: (v) => c.update(keyRadius: v),
                  ),
                  _CompactSlider(
                    label: 'Key Font',
                    value: c.keyFontSize,
                    min: 16,
                    max: 28,
                    onChanged: (v) => c.update(keyFontSize: v),
                  ),
                ] else ...[
                  _CompactSlider(
                    label: 'Padding H',
                    value: c.horizontalPadding,
                    min: 8,
                    max: 28,
                    onChanged: (v) => c.update(horizontalPadding: v),
                  ),
                  _CompactSlider(
                    label: 'Sheet Radius',
                    value: c.sheetRadius,
                    min: 12,
                    max: 40,
                    onChanged: (v) => c.update(sheetRadius: v),
                  ),
                  _CompactSlider(
                    label: 'Amount Font',
                    value: c.amountSize,
                    min: 30,
                    max: 58,
                    onChanged: (v) => c.update(amountSize: v),
                  ),
                  _CompactSlider(
                    label: 'CTA Height',
                    value: c.ctaHeight,
                    min: 48,
                    max: 70,
                    onChanged: (v) => c.update(ctaHeight: v),
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
