import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';
import '../ui_tuner_hud.dart';

class V2HeaderGreeting extends StatelessWidget {
  final HeaderTunerConfig config;
  final String userName;
  final String subtitle;
  final VoidCallback? onBellTap;
  final VoidCallback? onInboxTap;

  const V2HeaderGreeting({
    super.key,
    required this.config,
    this.userName = 'Martin',
    this.subtitle = "Here's your account\ntransactions overview",
    this.onBellTap,
    this.onInboxTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: config,
      builder: (_, _) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            config.horizontalPadding,
            config.topSpacing,
            config.horizontalPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: config.avatarSize,
                    height: config.avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: V2Colors.surfaceElevated,
                      border: Border.all(color: V2Colors.borderSubtle),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: V2Colors.textSecondary,
                      size: 20,
                    ),
                  ),
                  Row(
                    children: [
                      _CircleIconButton(
                        size: config.iconButtonSize,
                        icon: Icons.notifications_none_rounded,
                        onTap: onBellTap,
                      ),
                      const SizedBox(width: 8),
                      _CircleIconButton(
                        size: config.iconButtonSize,
                        icon: Icons.mail_outline_rounded,
                        hasBadge: true,
                        onTap: onInboxTap,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: config.greetingGap),
              Text(
                'Hello, $userName',
                style: V2Typography.headlineGreeting(
                  size: config.greetingSize,
                  color: V2Colors.accentPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: V2Typography.headlineGreeting(
                  size: config.subtitleSize,
                  color: V2Colors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final double size;
  final IconData icon;
  final bool hasBadge;
  final VoidCallback? onTap;

  const _CircleIconButton({
    required this.size,
    required this.icon,
    this.hasBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: V2Colors.surfaceCard,
          border: Border.all(color: V2Colors.borderSubtle),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: V2Colors.textPrimary, size: 18),
            if (hasBadge)
              Positioned(
                top: size * 0.24,
                right: size * 0.24,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: V2Colors.semanticPositive,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
