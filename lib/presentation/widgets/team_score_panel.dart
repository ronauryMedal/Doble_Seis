import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/game_session.dart';

/// Panel de puntuación de un equipo con soporte para swipe.
class TeamScorePanel extends StatelessWidget {
  const TeamScorePanel({
    super.key,
    required this.team,
    required this.color,
    required this.isLeading,
    required this.winScore,
    this.onSwipeScore,
  });

  final TeamScore team;
  final Color color;
  final bool isLeading;
  final int winScore;
  final VoidCallback? onSwipeScore;

  @override
  Widget build(BuildContext context) {
    final progress = (team.score / winScore).clamp(0.0, 1.0);

    return Expanded(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity.abs() > 200) {
            onSwipeScore?.call();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: isLeading ? 0.18 : 0.08),
                AppColors.nightCard,
              ],
            ),
            border: Border.all(
              color: color.withValues(alpha: isLeading ? 0.5 : 0.15),
              width: isLeading ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                team.name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color.withValues(alpha: 0.8),
                      letterSpacing: 2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${team.score}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.textPrimary,
                      shadows: isLeading
                          ? [
                              Shadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 20,
                              ),
                            ]
                          : null,
                    ),
              )
                  .animate(key: ValueKey(team.score))
                  .scale(
                    begin: const Offset(1.15, 1.15),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'a $winScore',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 12,
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
