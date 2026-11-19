import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';
import '../bottom_bar_tuner_hud.dart';

class V2BottomActionBar extends StatefulWidget {
  final BottomBarTunerConfig config;
  final VoidCallback? onCtaTap;
  final ValueChanged<String>? onMenuSelect;

  const V2BottomActionBar({
    super.key,
    required this.config,
    this.onCtaTap,
    this.onMenuSelect,
  });

  @override
  State<V2BottomActionBar> createState() => _V2BottomActionBarState();
}

class _V2BottomActionBarState extends State<V2BottomActionBar> {
  bool _menuOpen = false;

  static const _menuItems = [
    (label: 'Settings', icon: Icons.settings_outlined),
    (label: 'Budget', icon: Icons.account_balance_wallet_outlined),
    (label: 'Statistics', icon: Icons.bar_chart_rounded),
    (label: 'Dashboard', icon: Icons.grid_view_rounded),
  ];

  void _toggleMenu() => setState(() => _menuOpen = !_menuOpen);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.config,
      builder: (_, _) {
        final c = widget.config;
        return Stack(
          children: [
            if (_menuOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleMenu,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
              ),
            Positioned(
              left: c.horizontalPadding,
              right: c.horizontalPadding,
              bottom: c.bottomPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, anim) {
                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.18),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      );
                    },
                    child: _menuOpen
                        ? Column(
                            key: const ValueKey('menu_open'),
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _menuItems.map((item) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: c.menuItemGap),
                                child: GestureDetector(
                                  onTap: () {
                                    _toggleMenu();
                                    widget.onMenuSelect?.call(item.label);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: V2Colors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: V2Colors.borderSubtle),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.label,
                                          style: const TextStyle(
                                            color: V2Colors.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          item.icon,
                                          size: 18,
                                          color: V2Colors.accentPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : const SizedBox.shrink(key: ValueKey('menu_closed')),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: widget.onCtaTap ?? () {},
                          borderRadius: BorderRadius.circular(c.ctaRadius),
                          child: Container(
                            height: c.barHeight,
                            decoration: BoxDecoration(
                              color: V2Colors.accentPrimary,
                              borderRadius: BorderRadius.circular(c.ctaRadius),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  color: V2Colors.bgPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Add Expense',
                                  style: TextStyle(
                                    color: V2Colors.bgPrimary,
                                    fontSize: c.ctaFontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: c.gapBetween),
                      InkWell(
                        onTap: _toggleMenu,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: c.barHeight,
                          height: c.barHeight,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _menuOpen
                                ? V2Colors.surfaceElevated
                                : V2Colors.surfaceCard,
                            border: Border.all(
                              color: _menuOpen
                                  ? V2Colors.accentPrimary
                                  : V2Colors.borderSubtle,
                            ),
                          ),
                          child: Icon(
                            _menuOpen ? Icons.close_rounded : Icons.menu_rounded,
                            color: V2Colors.textPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
