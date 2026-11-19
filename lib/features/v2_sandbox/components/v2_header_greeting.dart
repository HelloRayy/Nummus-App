import 'package:flutter/material.dart';
import '../../../core/theme/v2_tokens.dart';

class V2HeaderGreeting extends StatelessWidget {
  final String userName;
  final String subtitle;
  final VoidCallback? onBellTap;
  final VoidCallback? onInboxTap;

  const V2HeaderGreeting({
    super.key,
    this.userName = 'Rayhan.',
    this.subtitle = "Here's your account\ntransactions overview",
    this.onBellTap,
    this.onInboxTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: V2Colors.surfaceElevated,
                  border: Border.all(color: V2Colors.borderSubtle),
                ),
                child: const Icon(
                  Icons.person,
                  color: V2Colors.textSecondary,
                  size: 22,
                ),
              ),
              Row(
                children: [
                  _CircleIconButton(
                    size: 48,
                    icon: Icons.notifications_none_rounded,
                    onTap: onBellTap,
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    size: 48,
                    icon: Icons.mail_outline_rounded,
                    hasBadge: true,
                    onTap: onInboxTap,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              colors: [V2Colors.accentPrimary, V2Colors.textPrimary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: Text(
              'Hello, $userName',
              style: V2Typography.headlineGreeting(
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: V2Typography.headlineGreeting(
              size: 28,
              color: V2Colors.textPrimary,
            ),
          ),
        ],
      ),
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
            Icon(icon, color: V2Colors.textPrimary, size: 20),
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
