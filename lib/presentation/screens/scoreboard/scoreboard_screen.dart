import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/player_colors.dart';
import '../../../domain/enums/game_mode.dart';
import '../../../data/models/live_room_connection_info.dart';
import '../../../data/models/game_session.dart';
import '../../../features/vision/domino_vision_scan_screen.dart';
import '../../../features/vision/vision_scan_icon_button.dart';
import '../../bloc/game/game_bloc.dart';
import '../../widgets/celebration_overlay.dart';
import '../../widgets/domino_counter_sheet.dart';
import '../../widgets/game_log_sheet.dart';
import '../../widgets/live_room_qr_sheet.dart';
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
    return BlocListener<GameBloc, GameState>(
      listenWhen: (prev, curr) =>
          curr.liveRoomError != null && prev.liveRoomError != curr.liveRoomError,
      listener: (context, state) {
        final error = state.liveRoomError;
        if (error == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sala WiFi: $error'),
            backgroundColor: AppColors.neonRose,
          ),
        );
      },
      child: BlocListener<GameBloc, GameState>(
        listenWhen: (prev, curr) =>
            curr.isLiveHost &&
            curr.liveRoomInfo != null &&
            prev.liveRoomInfo == null,
        listener: (context, state) {
          showLiveRoomQrSheet(context, state.liveRoomInfo!);
        },
        child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          final session = state.session;
          final bloc = context.read<GameBloc>();
          final gameOver = session.isGameOver;
          final participants = session.participants;
          final highest = session.highestScore;
          final multi = participants.length > 2;
          final isSpectator = state.isSpectator;
          final canEdit = !gameOver && !isSpectator;

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
                        isSpectator: isSpectator,
                        onToggleClock: isSpectator
                            ? null
                            : () => bloc.add(const ShotClockToggled()),
                        onOpenCounter: canEdit
                            ? () {
                                final target = participants.firstWhere(
                                  (p) => p.id == _selectedPlayerId,
                                );
                                showDominoCounterSheet(
                                  context,
                                  targetName: target.name,
                                  onApply: (points) => bloc.add(ScoreAdded(
                                    teamId: _selectedPlayerId!,
                                    points: points,
                                  )),
                                );
                              }
                            : null,
                        onOpenVisionScan: canEdit
                            ? () {
                                final target = participants.firstWhere(
                                  (p) => p.id == _selectedPlayerId,
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => DominoVisionScanScreen(
                                      targetName: target.name,
                                      onApply: (points) => bloc.add(ScoreAdded(
                                        teamId: _selectedPlayerId!,
                                        points: points,
                                      )),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        onOpenLog: () => showGameLogSheet(context, session),
                        onReset: () {
                          bloc.add(const GameReset());
                          Navigator.of(context).pop();
                        },
                      ),
                      if (state.isLiveHost && state.liveRoomInfo != null)
                        _LiveRoomHostBanner(info: state.liveRoomInfo!),
                      if (isSpectator)
                        const _LiveRoomSpectatorBanner(),
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
                      if (!isSpectator)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: SpecialEventChips(
                            selectedTeamId: _selectedPlayerId!,
                            enabled: canEdit,
                            compact: true,
                            pendingEvent: state.pendingSpecialEvent,
                            pendingTeamId: state.pendingSpecialEventTeamId,
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
                          readOnly: isSpectator,
                          onSelect: (id) =>
                              setState(() => _selectedPlayerId = id),
                          onSwipeScore: canEdit
                              ? (playerId) => bloc.add(ScoreAdded(
                                    teamId: playerId,
                                    points: AppConstants.quickScore,
                                  ))
                              : null,
                        ),
                      ),
                      if (!isSpectator)
                        SmartKeyboard(
                          compact: true,
                          enabled: canEdit,
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
                    winnerName: session.winner?.name,
                    onDismiss: () => bloc.add(const CelebrationDismissed()),
                    onRematch: state.activeCelebration == CelebrationType.gameWon &&
                            !isSpectator
                        ? () => bloc.add(const GameRematch())
                        : null,
                    onChangePlayers: state.activeCelebration ==
                                CelebrationType.gameWon &&
                            !isSpectator
                        ? () {
                            bloc.add(const GameReset());
                            Navigator.of(context).pop();
                          }
                        : null,
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .then()
                      .shake(duration: 500.ms, hz: 2),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}

class _CompactToolbar extends StatelessWidget {
  const _CompactToolbar({
    required this.winScore,
    required this.mode,
    required this.seconds,
    required this.isShotClockActive,
    required this.onReset,
    required this.onOpenLog,
    this.isSpectator = false,
    this.onToggleClock,
    this.onOpenCounter,
    this.onOpenVisionScan,
  });

  final int winScore;
  final GameMode mode;
  final int seconds;
  final bool isShotClockActive;
  final bool isSpectator;
  final VoidCallback? onToggleClock;
  final VoidCallback? onOpenCounter;
  final VoidCallback? onOpenVisionScan;
  final VoidCallback onOpenLog;
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
            onToggle: onToggleClock ?? () {},
          ),
          if (!isSpectator) ...[
            const SizedBox(width: 2),
            IconButton(
              onPressed: onOpenCounter,
              tooltip: 'Conteo de fichas',
              icon: Icon(
                Icons.view_module_outlined,
                size: 22,
                color: AppColors.neonCyan.withValues(alpha: 0.85),
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.neonCyan.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.neonCyan.withValues(alpha: 0.25),
                  ),
                ),
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
              ),
            ),
            VisionScanIconButton(onPressed: onOpenVisionScan),
          ],
          IconButton(
            onPressed: onOpenLog,
            icon: const Icon(Icons.history_rounded, size: 18),
            color: AppColors.textSecondary,
            tooltip: 'Bitácora',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          IconButton(
            onPressed: onReset,
            icon: Icon(
              isSpectator ? Icons.close_rounded : Icons.refresh_rounded,
              size: 18,
            ),
            color: AppColors.textSecondary,
            tooltip: isSpectator ? 'Salir' : 'Nueva partida',
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

class _LiveRoomHostBanner extends StatelessWidget {
  const _LiveRoomHostBanner({required this.info});

  final LiveRoomConnectionInfo info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      child: Material(
        color: AppColors.neonCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => showLiveRoomQrSheet(context, info),
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: info.shareLine));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('IP y código copiados'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 16, color: AppColors.neonCyan),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Toca para ver QR · ${info.roomCode}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.neonCyan),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.neonCyan),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveRoomSpectatorBanner extends StatelessWidget {
  const _LiveRoomSpectatorBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.neonAmber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.neonAmber.withValues(alpha: 0.25)),
        ),
        child: const Row(
          children: [
            Icon(Icons.visibility_rounded, size: 16, color: AppColors.neonAmber),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Espectador · solo lectura',
                style: TextStyle(fontSize: 11, color: AppColors.neonAmber),
              ),
            ),
          ],
        ),
      ),
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
    this.readOnly = false,
    this.onSwipeScore,
  });

  final List<PlayerScore> participants;
  final int winScore;
  final int highestScore;
  final String selectedId;
  final bool gameOver;
  final bool readOnly;
  final ValueChanged<String> onSelect;
  final ValueChanged<String>? onSwipeScore;

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
      onSwipeScore: readOnly || gameOver ? null : () => onSwipeScore?.call(player.id),
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
