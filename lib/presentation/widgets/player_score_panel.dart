import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/game_session.dart';

/// Panel de puntuación moderno con feedback suave.
class PlayerScorePanel extends StatefulWidget {
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
  State<PlayerScorePanel> createState() => _PlayerScorePanelState();
}

class _PlayerScorePanelState extends State<PlayerScorePanel> {
  late int _previousScore = widget.player.score;
  int? _floatingDelta;
  int _animationToken = 0;
  bool _justScored = false;
  Timer? _scoreTimer;

  @override
  void didUpdateWidget(covariant PlayerScorePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newScore = widget.player.score;
    if (newScore != _previousScore) {
      final delta = newScore - _previousScore;
      _previousScore = newScore;
      if (delta > 0) {
        setState(() {
          _floatingDelta = delta;
          _animationToken++;
          _justScored = true;
        });
        _scoreTimer?.cancel();
        _scoreTimer = Timer(const Duration(milliseconds: 550), () {
          if (mounted) setState(() => _justScored = false);
        });
      }
    }
  }

  @override
  void dispose() {
    _scoreTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final color = widget.color;
    final emphasis = widget.emphasis;
    final isSelected = widget.isSelected;
    final isLeading = widget.isLeading;
    final progress = (player.score / widget.winScore).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.soft,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(
                alpha: _justScored
                    ? 0.28
                    : (isSelected || isLeading ? 0.16 : 0.06),
              ),
              AppColors.nightCard,
            ],
          ),
          borderRadius: BorderRadius.circular(emphasis ? AppRadii.lg : AppRadii.md),
          border: Border.all(
            color: color.withValues(
              alpha: _justScored
                  ? 0.75
                  : (isSelected ? 0.55 : (isLeading ? 0.35 : 0.12)),
            ),
            width: isSelected || _justScored ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
            if (_justScored || isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, emphasis ? 8 : 5, 8, emphasis ? 8 : 6),
          child: Column(
            children: [
              Text(
                player.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: emphasis ? 12 : 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Expanded(
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${player.score}',
                          style: TextStyle(
                            fontSize: emphasis ? 52 : 42,
                            fontWeight: FontWeight.w700,
                            height: 1,
                            letterSpacing: -1.5,
                            color: AppColors.textPrimary,
                          ),
                        )
                            .animate(
                              key: ValueKey('${player.id}_${player.score}'),
                            )
                            .scale(
                              begin: const Offset(1.1, 1.1),
                              end: const Offset(1, 1),
                              duration: AppMotion.normal,
                              curve: AppMotion.soft,
                            ),
                      ),
                      if (_floatingDelta != null)
                        Positioned(
                          top: -4,
                          child: IgnorePointer(
                            child: Text(
                              '+$_floatingDelta',
                              style: TextStyle(
                                fontSize: emphasis ? 18 : 15,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            )
                                .animate(
                                  key: ValueKey(_animationToken),
                                  onComplete: (_) {
                                    if (mounted) {
                                      setState(() => _floatingDelta = null);
                                    }
                                  },
                                )
                                .fadeIn(duration: AppMotion.fast)
                                .moveY(
                                  begin: 2,
                                  end: -24,
                                  duration: 720.ms,
                                  curve: AppMotion.soft,
                                )
                                .fadeOut(delay: 360.ms, duration: AppMotion.normal),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
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
