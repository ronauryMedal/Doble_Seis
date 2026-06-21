import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Cronómetro de duración de la partida (cuenta hacia arriba).
class ShotClock extends StatelessWidget {
  const ShotClock({
    super.key,
    required this.seconds,
    required this.isActive,
    required this.onToggle,
    this.compact = false,
  });

  final int seconds;
  final bool isActive;
  final VoidCallback onToggle;
  final bool compact;

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final secs = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.neonCyan : AppColors.textMuted;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 20,
          vertical: compact ? 6 : 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.nightCard,
          borderRadius: BorderRadius.circular(compact ? 12 : 30),
          border: Border.all(
            color: color.withValues(alpha: isActive ? 0.5 : 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.timer : Icons.timer_off_outlined,
              size: compact ? 14 : 18,
              color: color,
            ),
            if (!compact) const SizedBox(width: 8),
            Text(
              _formatDuration(seconds),
              style: TextStyle(
                fontSize: compact ? 14 : 22,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
