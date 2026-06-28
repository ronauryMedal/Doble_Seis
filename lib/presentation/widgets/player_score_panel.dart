import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/game_session.dart';

/// Panel de puntuación — nunca hace overflow, se adapta al espacio.
class PlayerScorePanel extends StatelessWidget {
  const PlayerScorePanel({
    super.key,
    required this.player,
    required this.color,
    required this.isLeading,
    required this.winScore,
    this.isSelected = false,
    this.emphasis = false,
    this.onTap,
  });

  final PlayerScore player;
  final Color color;
  final bool isLeading;
  final int winScore;
  final bool isSelected;
  final bool emphasis;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = (player.score / winScore).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(emphasis ? 16 : 12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: isLeading || isSelected ? 0.2 : 0.06),
              AppColors.nightCard,
            ],
          ),
          border: Border.all(
            color: color.withValues(
              alpha: isSelected ? 0.7 : (isLeading ? 0.45 : 0.12),
            ),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, emphasis ? 8 : 4, 8, emphasis ? 8 : 6),
          child: Column(
            children: [
              Text(
                player.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: emphasis ? 12 : 10,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.9),
                ),
              ),
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${player.score}',
                      style: TextStyle(
                        fontSize: emphasis ? 48 : 40,
                        fontWeight: FontWeight.w200,
                        height: 1,
                        color: AppColors.textPrimary,
                      ),
                    )
                        .animate(
                          key: ValueKey('${player.id}_${player.score}'),
                        )
                        .scale(
                          begin: const Offset(1.06, 1.06),
                          end: const Offset(1, 1),
                          duration: 180.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 2,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef TeamScorePanel = PlayerScorePanel;
