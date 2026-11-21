import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/v2_tokens.dart';

class HeaderTunerConfig extends ChangeNotifier {
  double horizontalPadding = 16.0;
  double topSpacing = 12.0;
  double avatarSize = 40.0;
  double iconButtonSize = 40.0;
  double greetingGap = 20.0;
  double greetingSize = 22.0;
  double subtitleSize = 22.0;

  void update({
    double? horizontalPadding,
    double? topSpacing,
    double? avatarSize,
    double? iconButtonSize,
    double? greetingGap,
    double? greetingSize,
    double? subtitleSize,
  }) {
    if (horizontalPadding != null) this.horizontalPadding = horizontalPadding;
    if (topSpacing != null) this.topSpacing = topSpacing;
    if (avatarSize != null) this.avatarSize = avatarSize;
    if (iconButtonSize != null) this.iconButtonSize = iconButtonSize;
    if (greetingGap != null) this.greetingGap = greetingGap;
    if (greetingSize != null) this.greetingSize = greetingSize;
    if (subtitleSize != null) this.subtitleSize = subtitleSize;
    notifyListeners();
  }

  void reset() {
    horizontalPadding = 16.0;
    topSpacing = 12.0;
    avatarSize = 40.0;
    iconButtonSize = 40.0;
    greetingGap = 20.0;
    greetingSize = 22.0;
    subtitleSize = 22.0;
    notifyListeners();
  }

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert({
      'component': 'V2HeaderGreeting',
      'horizontalPadding': double.parse(horizontalPadding.toStringAsFixed(1)),
      'topSpacing': double.parse(topSpacing.toStringAsFixed(1)),
      'avatarSize': double.parse(avatarSize.toStringAsFixed(1)),
      'iconButtonSize': double.parse(iconButtonSize.toStringAsFixed(1)),
      'greetingGap': double.parse(greetingGap.toStringAsFixed(1)),
      'greetingSize': double.parse(greetingSize.toStringAsFixed(1)),
      'subtitleSize': double.parse(subtitleSize.toStringAsFixed(1)),
    });
  }
}

class UiTunerHud extends StatefulWidget {
  final HeaderTunerConfig config;

  const UiTunerHud({super.key, required this.config});

  @override
  State<UiTunerHud> createState() => _UiTunerHudState();
}

class _UiTunerHudState extends State<UiTunerHud> {
  Offset _offset = const Offset(20, 120);

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
        return ListenableBuilder(
          listenable: widget.config,
          builder: (_, _) {
            final c = widget.config;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('UI Tuner HUD', style: V2Typography.cardTitle()),
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
                                    content: Text('JSON config copied'),
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
                    const SizedBox(height: 8),
                    _SliderRow(
                      label: 'Horizontal Padding',
                      value: c.horizontalPadding,
                      min: 8,
                      max: 32,
                      onChanged: (v) => c.update(horizontalPadding: v),
                    ),
                    _SliderRow(
                      label: 'Top Spacing',
                      value: c.topSpacing,
                      min: 0,
                      max: 32,
                      onChanged: (v) => c.update(topSpacing: v),
                    ),
                    _SliderRow(
                      label: 'Avatar Size',
                      value: c.avatarSize,
                      min: 32,
                      max: 56,
                      onChanged: (v) => c.update(avatarSize: v),
                    ),
                    _SliderRow(
                      label: 'Icon Button Size',
                      value: c.iconButtonSize,
                      min: 32,
                      max: 52,
                      onChanged: (v) => c.update(iconButtonSize: v),
                    ),
                    _SliderRow(
                      label: 'Greeting Gap',
                      value: c.greetingGap,
                      min: 8,
                      max: 40,
                      onChanged: (v) => c.update(greetingGap: v),
                    ),
                    _SliderRow(
                      label: 'Greeting Font',
                      value: c.greetingSize,
                      min: 16,
                      max: 32,
                      onChanged: (v) => c.update(greetingSize: v),
                    ),
                    _SliderRow(
                      label: 'Subtitle Font',
                      value: c.subtitleSize,
                      min: 16,
                      max: 32,
                      onChanged: (v) => c.update(subtitleSize: v),
                    ),
                  ],
                ),
              ),
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
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
          });
        },
        onTap: _openTunerSheet,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: V2Colors.accentPrimary,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: V2Colors.textPrimary.withValues(alpha: 0.2)),
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
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            '$label (${value.toStringAsFixed(0)})',
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
