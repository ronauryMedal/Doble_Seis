import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Cronómetro de turno estilo ajedrez (Shot Clock).
class ShotClock extends StatelessWidget {
  const ShotClock({
    super.key,
    required this.seconds,
    required this.isActive,
    required this.onToggle,
  });

  final int seconds;
  final bool isActive;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isWarning = seconds <= AppConstants.shotClockWarningSeconds;
    final color = !isActive
        ? AppColors.textMuted
        : (isWarning ? AppColors.neonRose : AppColors.neonCyan);

    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.nightCard,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: color.withValues(alpha: isActive ? 0.5 : 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.timer : Icons.timer_off_outlined,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              '$minutes:$secs',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      )
          .animate(target: isWarning && isActive ? 1 : 0)
          .shake(duration: 600.ms, hz: 3),
    );
  }
}
