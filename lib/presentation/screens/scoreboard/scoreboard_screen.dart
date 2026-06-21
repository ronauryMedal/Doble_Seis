import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/player_colors.dart';
import '../../../domain/enums/game_mode.dart';
import '../../../data/models/game_session.dart';
import '../../../features/vision/vision_scan_placeholder.dart';
import '../../bloc/game/game_bloc.dart';
import '../../widgets/celebration_overlay.dart';
import '../../widgets/player_score_panel.dart';
import '../../widgets/shot_clock.dart';
import '../../widgets/smart_keyboard.dart';
import '../../widgets/special_event_chips.dart';

/// Marcador móvil: marcador arriba, teclado abajo, sin espacio desperdiciado.
class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  String? _selectedPlayerId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final session = state.session;
        final bloc = context.read<GameBloc>();
        final gameOver = session.isGameOver;
        final participants = session.participants;
        final highest = session.highestScore;
        final multi = participants.length > 2;

        _selectedPlayerId ??= participants.first.id;
        if (!participants.any((p) => p.id == _selectedPlayerId)) {
          _selectedPlayerId = participants.first.id;
        }

        return Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _CompactToolbar(
                      winScore: session.winScore,
                      mode: session.mode,
                      seconds: state.shotClockSeconds,
                      isShotClockActive: state.isShotClockActive,
                      onToggleClock: () => bloc.add(const ShotClockToggled()),
                      onReset: () {
                        bloc.add(const GameReset());
                        Navigator.of(context).pop();
                      },
                    ),
                    if (multi)
                      SizedBox(
                        height: 28,
                        child: _PlayerSelector(
                          participants: participants,
                          selectedId: _selectedPlayerId!,
                          onSelected: (id) =>
                              setState(() => _selectedPlayerId = id),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: SpecialEventChips(
                        selectedTeamId: _selectedPlayerId!,
                        enabled: !gameOver,
                        compact: true,
                        onEvent: (teamId, event) => bloc.add(
                          SpecialEventMarked(teamId: teamId, event: event),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _FlexScoreGrid(
                        participants: participants,
                        winScore: session.winScore,
                        highestScore: highest,
                        selectedId: _selectedPlayerId!,
                        gameOver: gameOver,
                        onSelect: (id) =>
                            setState(() => _selectedPlayerId = id),
                        onSwipeScore: (playerId) => bloc.add(ScoreAdded(
                          teamId: playerId,
                          points: AppConstants.quickScore,
                        )),
                      ),
                    ),
                    SmartKeyboard(
                      compact: true,
                      enabled: !gameOver,
                      onQuickScore: (points) => bloc.add(ScoreAdded(
                        teamId: _selectedPlayerId!,
                        points: points,
                      )),
                      onScoreSubmitted: (points) => bloc.add(ScoreAdded(
                        teamId: _selectedPlayerId!,
                        points: points,
                      )),
                    ),
                  ],
                ),
              ),
              if (state.activeCelebration != null)
                CelebrationOverlay(
                  type: state.activeCelebration!,
                  onDismiss: () => bloc.add(const CelebrationDismissed()),
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

class _CompactToolbar extends StatelessWidget {
  const _CompactToolbar({
    required this.winScore,
    required this.mode,
    required this.seconds,
    required this.isShotClockActive,
    required this.onToggleClock,
    required this.onReset,
  });

  final int winScore;
  final GameMode mode;
  final int seconds;
  final bool isShotClockActive;
  final VoidCallback onToggleClock;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 2, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 9,
                        letterSpacing: 2,
                        color: AppColors.textMuted,
                      ),
                ),
                Text(
                  '${mode.label} · a $winScore',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          ShotClock(
            compact: true,
            seconds: seconds,
            isActive: isShotClockActive,
            onToggle: onToggleClock,
          ),
          const SizedBox(width: 2),
          const VisionScanIconButton(),
          IconButton(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            color: AppColors.textSecondary,
            tooltip: 'Nueva partida',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

class _PlayerSelector extends StatelessWidget {
  const _PlayerSelector({
    required this.participants,
    required this.selectedId,
    required this.onSelected,
  });

  final List<PlayerScore> participants;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: participants.length,
      separatorBuilder: (_, _) => const SizedBox(width: 4),
      itemBuilder: (context, index) {
        final player = participants[index];
        final color = PlayerColors.forIndex(index);
        final isSelected = player.id == selectedId;

        return GestureDetector(
          onTap: () => onSelected(player.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : AppColors.nightCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Text(
              player.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : AppColors.textMuted,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FlexScoreGrid extends StatelessWidget {
  const _FlexScoreGrid({
    required this.participants,
    required this.winScore,
    required this.highestScore,
    required this.selectedId,
    required this.gameOver,
    required this.onSelect,
    required this.onSwipeScore,
  });

  final List<PlayerScore> participants;
  final int winScore;
  final int highestScore;
  final String selectedId;
  final bool gameOver;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onSwipeScore;

  int get _columns {
    final n = participants.length;
    if (n <= 2) return 2;
    if (n <= 4) return 2;
    return 3;
  }

  Widget _panel(int index, {bool emphasis = false}) {
    final player = participants[index];
    return PlayerScorePanel(
      player: player,
      color: PlayerColors.forIndex(index),
      isLeading: player.score >= highestScore && player.score > 0,
      isSelected: player.id == selectedId,
      winScore: winScore,
      emphasis: emphasis,
      onTap: () => onSelect(player.id),
      onSwipeScore: gameOver ? null : () => onSwipeScore(player.id),
    );
  }

  Widget _buildDuoLayout(BoxConstraints constraints) {
    const gap = 10.0;
    const padH = 16.0;
    const padV = 8.0;
    const cardAspect = 0.82; // ancho / alto — cartas proporcionadas

    final availW = constraints.maxWidth - padH * 2;
    final availH = constraints.maxHeight - padV * 2;

    var cardWidth = (availW - gap) / 2;
    var cardHeight = cardWidth / cardAspect;

    if (cardHeight > availH) {
      cardHeight = availH;
      cardWidth = cardHeight * cardAspect;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: cardWidth * 2 + gap,
          height: cardHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _panel(0, emphasis: true),
              ),
              const SizedBox(width: gap),
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _panel(1, emphasis: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (participants.length == 2) {
      return LayoutBuilder(builder: (_, c) => _buildDuoLayout(c));
    }

    final cols = _columns;
    final rows = (participants.length / cols).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: List.generate(rows, (row) {
          return Expanded(
            child: Row(
              children: List.generate(cols, (col) {
                final index = row * cols + col;
                if (index >= participants.length) {
                  return const Expanded(child: SizedBox());
                }
                return Expanded(child: _panel(index));
              }),
            ),
          );
        }),
      ),
    );
  }
}
