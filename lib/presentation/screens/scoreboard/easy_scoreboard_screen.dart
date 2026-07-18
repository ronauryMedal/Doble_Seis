import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/game_session.dart';
import '../../../features/ads/ads_service.dart';
import '../../../features/ads/bottom_banner_ad.dart';
import '../../bloc/game/game_bloc.dart';
import '../../widgets/app_background.dart';
import '../../widgets/celebration_overlay.dart';
import '../../widgets/shot_clock.dart';

enum _EasyExitAction { cancel, saveAndLeave, discard }

/// Marcador simple estilo Kapicú: nombres, sumar ronda e historial P1, P2…
class EasyScoreboardScreen extends StatefulWidget {
  const EasyScoreboardScreen({super.key});

  @override
  State<EasyScoreboardScreen> createState() => _EasyScoreboardScreenState();
}

class _EasyScoreboardScreenState extends State<EasyScoreboardScreen> {
  late final TextEditingController _pointsAController;
  late final TextEditingController _pointsBController;

  @override
  void initState() {
    super.initState();
    _pointsAController = TextEditingController();
    _pointsBController = TextEditingController();
  }

  @override
  void dispose() {
    _pointsAController.dispose();
    _pointsBController.dispose();
    super.dispose();
  }

  void _addRound(GameBloc bloc, String teamAId, String teamBId) {
    final a = int.tryParse(_pointsAController.text.trim()) ?? 0;
    final b = int.tryParse(_pointsBController.text.trim()) ?? 0;
    if (a <= 0 && b <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa los puntos de al menos un equipo.'),
          backgroundColor: AppColors.neonRose,
        ),
      );
      return;
    }
    HapticUtils.mediumTap();
    bloc.add(RoundAdded(pointsByTeamId: {
      teamAId: a,
      teamBId: b,
    }));
    _pointsAController.clear();
    _pointsBController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _attemptExit(
    BuildContext context, {
    required bool inProgress,
  }) async {
    final bloc = context.read<GameBloc>();
    final navigator = Navigator.of(context);

    // Sin rondas: preguntar igual (evitar salir sin querer / abrir modo completo).
    final action = await showDialog<_EasyExitAction>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.nightSurface,
        title: Text(inProgress ? '¿Salir de la partida?' : '¿Salir?'),
        content: Text(
          inProgress
              ? 'Puedes guardar y continuar después en modo fácil, '
                  'o anular la partida.'
              : 'Si sales ahora, puedes continuar esta partida desde el inicio.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_EasyExitAction.cancel),
            child: const Text('Seguir jugando'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_EasyExitAction.saveAndLeave),
            child: const Text('Salir y guardar'),
          ),
          if (inProgress)
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_EasyExitAction.discard),
              child: const Text(
                'Anular partida',
                style: TextStyle(color: AppColors.neonRose),
              ),
            ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (action == null || action == _EasyExitAction.cancel) return;

    if (action == _EasyExitAction.discard) {
      bloc.add(const GameReset());
      // Dar tiempo a que Hive borre "current" antes de volver al home.
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }

    if (navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final bloc = context.read<GameBloc>();
        final session = state.session;
        final players = session.participants;
        final teamA = players.isNotEmpty ? players[0] : null;
        final teamB = players.length > 1 ? players[1] : null;
        final rounds = session.easyRounds;
        // Hay partida en curso si ya hay rondas o algún punto.
        final inProgress = !session.isGameOver &&
            (session.events.isNotEmpty ||
                session.participants.any((p) => p.score > 0));

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _attemptExit(context, inProgress: inProgress);
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text('Modo fácil · Primero a ${session.winScore}'),
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () =>
                    _attemptExit(context, inProgress: inProgress),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: ShotClock(
                      compact: true,
                      seconds: state.shotClockSeconds,
                      isActive: state.isShotClockActive,
                      onToggle: session.isGameOver
                          ? () {}
                          : () => bloc.add(const ShotClockToggled()),
                    ),
                  ),
                ),
              ],
            ),
            body: AppBackground(
              child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.sm,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          children: [
                            if (teamA != null && teamB != null) ...[
                              SoftCard(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _TeamHeader(
                                            name: teamA.name,
                                            color: AppColors.teamA,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: _TeamHeader(
                                            name: teamB.name,
                                            color: AppColors.teamB,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _RoundPointsField(
                                            controller: _pointsAController,
                                            color: AppColors.teamA,
                                            enabled: !session.isGameOver,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: _RoundPointsField(
                                            controller: _pointsBController,
                                            color: AppColors.teamB,
                                            enabled: !session.isGameOver,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        onPressed: session.isGameOver
                                            ? null
                                            : () => _addRound(
                                                  bloc,
                                                  teamA.id,
                                                  teamB.id,
                                                ),
                                        icon: const Icon(Icons.add_rounded),
                                        label: const Text('Añadir ronda'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AnimatedSwitcher(
                                duration: AppMotion.normal,
                                switchInCurve: AppMotion.easeOut,
                                switchOutCurve: AppMotion.easeInOut,
                                child: _RoundsTable(
                                  key: ValueKey(rounds.length),
                                  teamA: teamA,
                                  teamB: teamB,
                                  rounds: rounds,
                                  onDeleteRound: session.isGameOver
                                      ? null
                                      : (roundId) =>
                                          bloc.add(RoundRemoved(roundId)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const BottomBannerAd(),
                    ],
                  ),
                  if (state.activeCelebration != null)
                    CelebrationOverlay(
                      type: state.activeCelebration!,
                      winnerName: session.winner?.name,
                      onDismiss: () {
                        final wasWin = state.activeCelebration ==
                            CelebrationType.gameWon;
                        bloc.add(const CelebrationDismissed());
                        if (wasWin) {
                          AdsService.instance.onGameFinished();
                        }
                      },
                      onRematch: state.activeCelebration ==
                              CelebrationType.gameWon
                          ? () {
                              bloc.add(const GameRematch());
                              AdsService.instance.onGameFinished();
                            }
                          : null,
                      onChangePlayers: state.activeCelebration ==
                              CelebrationType.gameWon
                          ? () {
                              bloc.add(const GameReset());
                              Navigator.of(context).pop();
                            }
                          : null,
                    )
                        .animate()
                        .fadeIn(duration: AppMotion.normal),
                ],
              ),
            ),
            ),
          ),
        );
      },
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _RoundPointsField extends StatelessWidget {
  const _RoundPointsField({
    required this.controller,
    required this.color,
    required this.enabled,
  });

  final TextEditingController controller;
  final Color color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6)),
        filled: true,
        fillColor: AppColors.nightCard,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color.withValues(alpha: 0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color.withValues(alpha: 0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
    );
  }
}

class _RoundsTable extends StatelessWidget {
  const _RoundsTable({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.rounds,
    required this.onDeleteRound,
  });

  final PlayerScore teamA;
  final PlayerScore teamB;
  final List<EasyRound> rounds;
  final ValueChanged<String>? onDeleteRound;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _TableRow(
            label: 'TOTAL',
            valueA: '${teamA.score}',
            valueB: '${teamB.score}',
            labelColor: AppColors.textSecondary,
            valueAColor: AppColors.teamA,
            valueBColor: AppColors.teamB,
            isHeader: true,
          ),
          if (rounds.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Text(
                'Aún no hay rondas.\nAnota los puntos y pulsa “Añadir ronda”.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            )
          else
            ...List.generate(rounds.length, (index) {
              final round = rounds[index];
              final pointsA = round.pointsFor(teamA.id);
              final pointsB = round.pointsFor(teamB.id);
              final aWins = pointsA > pointsB;
              final bWins = pointsB > pointsA;
              return _TableRow(
                label: 'P${index + 1}',
                valueA: '$pointsA',
                valueB: '$pointsB',
                valueAColor: aWins
                    ? AppColors.neonCyan
                    : (pointsA > 0
                        ? AppColors.neonRose
                        : AppColors.textMuted),
                valueBColor: bWins
                    ? AppColors.neonCyan
                    : (pointsB > 0
                        ? AppColors.neonRose
                        : AppColors.textMuted),
                onDelete: onDeleteRound == null
                    ? null
                    : () => onDeleteRound!(round.roundId),
              );
            }),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.label,
    required this.valueA,
    required this.valueB,
    this.labelColor = AppColors.textSecondary,
    this.valueAColor = AppColors.textPrimary,
    this.valueBColor = AppColors.textPrimary,
    this.isHeader = false,
    this.onDelete,
  });

  final String label;
  final String valueA;
  final String valueB;
  final Color labelColor;
  final Color valueAColor;
  final Color valueBColor;
  final bool isHeader;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isHeader
            ? AppColors.nightCard
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: labelColor,
                fontSize: isHeader ? 13 : 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valueA,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isHeader ? 22 : 18,
                fontWeight: FontWeight.w700,
                color: valueAColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valueB,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isHeader ? 22 : 18,
                fontWeight: FontWeight.w700,
                color: valueBColor,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: onDelete == null
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.remove_circle,
                      color: AppColors.neonRose,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
          ),
        ],
      ),
    );
  }
}
