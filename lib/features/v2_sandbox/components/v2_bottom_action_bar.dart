import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';

class V2BottomActionBar extends StatefulWidget {
  final VoidCallback? onCtaTap;
  final ValueChanged<String>? onMenuSelect;

  const V2BottomActionBar({
    super.key,
    this.onCtaTap,
    this.onMenuSelect,
  });

  @override
  State<V2BottomActionBar> createState() => _V2BottomActionBarState();
}

class _V2BottomActionBarState extends State<V2BottomActionBar>
    with SingleTickerProviderStateMixin {
  bool _menuOpen = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnim;

  static const _menuItems = [
    (label: 'Settings', icon: Icons.settings_outlined),
    (label: 'Budget', icon: Icons.account_balance_wallet_outlined),
    (label: 'Planner', icon: Icons.checklist_rounded),
    (label: 'Dashboard', icon: Icons.grid_view_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _expandAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _menuOpen = !_menuOpen;
      if (_menuOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 19.7;
    const double bottomPadding = 13.7;
    const double barHeight = 68.0;
    const double gapBetween = 14.7;
    const double ctaRadius = 999.0;
    const double ctaFontSize = 15.6;
    const double menuItemGap = 7.7;

    return Positioned(
      left: horizontalPadding,
      right: horizontalPadding,
      bottom: bottomPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: 1.0,
            child: Align(
              alignment: Alignment.bottomRight,
              child: FadeTransition(
                opacity: _expandAnim,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1.0).animate(_expandAnim),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                  children: _menuItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: menuItemGap),
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
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: widget.onCtaTap ?? () {},
                  borderRadius: BorderRadius.circular(ctaRadius),
                  child: Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: V2Colors.accentPrimary,
                      borderRadius: BorderRadius.circular(ctaRadius),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: V2Colors.bgPrimary,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Add Expense',
                          style: TextStyle(
                            color: V2Colors.bgPrimary,
                            fontSize: ctaFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: gapBetween),
              InkWell(
                onTap: _toggleMenu,
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: barHeight,
                  height: barHeight,
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
                  child: AnimatedRotation(
                    turns: _menuOpen ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _menuOpen ? Icons.close_rounded : Icons.menu_rounded,
                      color: V2Colors.textPrimary,
                      size: 22,
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
}
