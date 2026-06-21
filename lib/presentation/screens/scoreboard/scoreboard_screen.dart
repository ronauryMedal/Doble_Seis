import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/vision/vision_scan_placeholder.dart';
import '../../bloc/game/game_bloc.dart';
import '../../widgets/celebration_overlay.dart';
import '../../widgets/shot_clock.dart';
import '../../widgets/smart_keyboard.dart';
import '../../widgets/special_event_chips.dart';
import '../../widgets/team_score_panel.dart';

/// Pantalla principal del marcador.
///
/// Arquitectura: esta pantalla solo construye UI y delega lógica al [GameBloc].
class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  /// Equipo activo para el teclado y eventos especiales.
  String _selectedTeamId = 'A';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listenWhen: (prev, curr) =>
          prev.activeCelebration != curr.activeCelebration &&
          curr.activeCelebration != null,
      listener: (context, state) {
        // La celebración se muestra como overlay; el listener prepara side-effects.
      },
      builder: (context, state) {
        final session = state.session;
        final bloc = context.read<GameBloc>();
        final gameOver = session.isGameOver;

        return Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _Header(
                      winScore: session.winScore,
                      onReset: () => bloc.add(const GameReset()),
                    ),
                    ShotClock(
                      seconds: state.shotClockSeconds,
                      isActive: state.isShotClockActive,
                      onToggle: () => bloc.add(const ShotClockToggled()),
                    ),
                    const SizedBox(height: 8),
                    const VisionScanPlaceholder(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          _TeamSelector(
                            label: 'A',
                            color: AppColors.teamA,
                            isSelected: _selectedTeamId == 'A',
                            onTap: () =>
                                setState(() => _selectedTeamId = 'A'),
                          ),
                          const SizedBox(width: 8),
                          _TeamSelector(
                            label: 'B',
                            color: AppColors.teamB,
                            isSelected: _selectedTeamId == 'B',
                            onTap: () =>
                                setState(() => _selectedTeamId = 'B'),
                          ),
                        ],
                      ),
                    ),
                    SpecialEventChips(
                      selectedTeamId: _selectedTeamId,
                      enabled: !gameOver,
                      onEvent: (teamId, event) => bloc.add(
                        SpecialEventMarked(teamId: teamId, event: event),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Row(
                        children: [
                          TeamScorePanel(
                            team: session.teamA,
                            color: AppColors.teamA,
                            isLeading:
                                session.teamA.score >= session.teamB.score,
                            winScore: session.winScore,
                            onSwipeScore: gameOver
                                ? null
                                : () => bloc.add(ScoreAdded(
                                      teamId: 'A',
                                      points: 10,
                                    )),
                          ),
                          TeamScorePanel(
                            team: session.teamB,
                            color: AppColors.teamB,
                            isLeading:
                                session.teamB.score > session.teamA.score,
                            winScore: session.winScore,
                            onSwipeScore: gameOver
                                ? null
                                : () => bloc.add(ScoreAdded(
                                      teamId: 'B',
                                      points: 10,
                                    )),
                          ),
                        ],
                      ),
                    ),
                    _SwipeHint(),
                    SmartKeyboard(
                      enabled: !gameOver,
                      onQuickScore: (points) => bloc.add(ScoreAdded(
                        teamId: _selectedTeamId,
                        points: points,
                      )),
                      onScoreSubmitted: (points) => bloc.add(ScoreAdded(
                        teamId: _selectedTeamId,
                        points: points,
                      )),
                    ),
                  ],
                ),
              ),
              if (state.activeCelebration != null)
                CelebrationOverlay(
                  type: state.activeCelebration!,
                  onDismiss: () =>
                      bloc.add(const CelebrationDismissed()),
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .then()
                    .shake(duration: 500.ms, hz: 2),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.winScore,
    required this.onReset,
  });

  final int winScore;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 3,
                        color: AppColors.textMuted,
                      ),
                ),
                Text(
                  'Primero a $winScore',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
            tooltip: 'Nueva partida',
          ),
        ],
      ),
    );
  }
}

class _TeamSelector extends StatelessWidget {
  const _TeamSelector({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : AppColors.nightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Text(
            'Equipo $label',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? color : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '← Desliza panel A  |  Desliza panel B →',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
      ),
    );
  }
}
