import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../bloc/game/game_bloc.dart';

/// Overlay de celebración con [flutter_animate].
class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({
    super.key,
    required this.type,
    required this.onDismiss,
  });

  final CelebrationType type;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (type) {
      CelebrationType.capicua => (
          '¡CAPICÚA!',
          AppColors.capicua,
          Icons.auto_awesome,
        ),
      CelebrationType.chucho => (
          '¡CHUCHO!',
          AppColors.chucho,
          Icons.block,
        ),
      CelebrationType.gameWon => (
          '¡GANADOR!',
          AppColors.neonAmber,
          Icons.emoji_events_outlined,
        ),
    };

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: color),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: color,
                  shadows: [
                    Shadow(color: color.withValues(alpha: 0.6), blurRadius: 30),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Toca para continuar',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
