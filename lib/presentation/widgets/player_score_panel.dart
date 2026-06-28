import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/game_session.dart';

/// Panel de puntuación — nunca hace overflow, se adapta al espacio.
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
  Timer? _glowTimer;

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
        _glowTimer?.cancel();
        _glowTimer = Timer(const Duration(milliseconds: 700), () {
          if (mounted) setState(() => _justScored = false);
        });
      }
    }
  }

  @override
  void dispose() {
    _glowTimer?.cancel();
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
        duration: 350.ms,
        curve: Curves.easeOut,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(emphasis ? 16 : 12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(
                alpha: _justScored
                    ? 0.32
                    : (isLeading || isSelected ? 0.2 : 0.06),
              ),
              AppColors.nightCard,
            ],
          ),
          border: Border.all(
            color: color.withValues(
              alpha: _justScored
                  ? 0.85
                  : (isSelected ? 0.7 : (isLeading ? 0.45 : 0.12)),
            ),
            width: isSelected || _justScored ? 2 : 1,
          ),
          boxShadow: _justScored
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      FittedBox(
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
                              begin: const Offset(1.18, 1.18),
                              end: const Offset(1, 1),
                              duration: 260.ms,
                              curve: Curves.easeOutBack,
                            ),
                      ),
                      if (_floatingDelta != null)
                        Positioned(
                          top: -6,
                          child: IgnorePointer(
                            child: Text(
                              '+$_floatingDelta',
                              style: TextStyle(
                                fontSize: emphasis ? 22 : 18,
                                fontWeight: FontWeight.w700,
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
                                .fadeIn(duration: 120.ms)
                                .moveY(
                                  begin: 6,
                                  end: -34,
                                  duration: 900.ms,
                                  curve: Curves.easeOut,
                                )
                                .fadeOut(delay: 480.ms, duration: 420.ms),
                          ),
                        ),
                    ],
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
