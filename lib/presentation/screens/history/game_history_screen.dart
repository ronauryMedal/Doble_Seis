import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/score_event_formatter.dart';
import '../../../data/models/game_history_entry.dart';
import '../../../data/models/game_session.dart';
import '../../../data/models/score_event.dart';
import '../../../data/repositories/game_repository.dart';
import '../../../domain/enums/special_event_type.dart';
import '../../widgets/app_background.dart';

/// Historial de partidas ganadas guardadas en Hive.
class GameHistoryScreen extends StatelessWidget {
  const GameHistoryScreen({super.key, required this.repository});

  final GameRepository repository;

  @override
  Widget build(BuildContext context) {
    final history = repository.loadHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partidas ganadas'),
      ),
      body: AppBackground(
        child: history.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Aún no hay partidas guardadas.\n'
                    'Al terminar una partida se guardará aquí.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: history.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return _HistoryCard(entry: history[index]);
                },
              ),
      ),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  const _HistoryCard({required this.entry});

  final GameHistoryEntry entry;

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _expanded = false;

  GameSession get _session => GameSession(
        id: widget.entry.id,
        mode: widget.entry.mode,
        participants: widget.entry.finalScores,
        winScore: widget.entry.winScore,
        events: widget.entry.events,
        createdAt: widget.entry.finishedAt,
      );

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final date = entry.finishedAt;
    final dateStr =
        '${date.day}/${date.month}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final dominoCount = entry.events.length;

    return SoftCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: AppRadii.borderLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_outlined,
                      color: AppColors.neonAmber,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.winnerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neonAmber,
                            ),
                          ),
                          Text(
                            '${entry.mode.label} · a ${entry.winScore} · ${_formatDuration(entry.durationSeconds)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: AppMotion.normal,
                      child: const Icon(
                        Icons.expand_more,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$dateStr · $dominoCount dominadas',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                ),
                AnimatedSize(
                  duration: AppMotion.normal,
                  curve: AppMotion.easeOut,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.sm),
                            const Divider(height: 1),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Marcador final',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _FinalScoresGrid(scores: entry.finalScores),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Cada domina (${entry.events.length})',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _DominoEventsGrid(
                              events: entry.events,
                              session: _session,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      return '${h}h ${m % 60}m';
    }
    return '${m}m ${s}s';
  }
}

/// Marcador final — 2 columnas.
class _FinalScoresGrid extends StatelessWidget {
  const _FinalScoresGrid({required this.scores});

  final List<PlayerScore> scores;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.4,
      ),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final p = scores[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.nightSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${p.score}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Todas las dominadas de la partida — 2 columnas.
class _DominoEventsGrid extends StatelessWidget {
  const _DominoEventsGrid({
    required this.events,
    required this.session,
  });

  final List<ScoreEvent> events;
  final GameSession session;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Text(
        'Sin anotaciones registradas.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.55,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _DominoEventTile(
          index: index + 1,
          event: event,
          session: session,
        );
      },
    );
  }
}

class _DominoEventTile extends StatelessWidget {
  const _DominoEventTile({
    required this.index,
    required this.event,
    required this.session,
  });

  final int index;
  final ScoreEvent event;
  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final color = event.isGameVictory
        ? AppColors.neonAmber
        : switch (event.specialEvent) {
            SpecialEventType.capicua => AppColors.capicua,
            SpecialEventType.tranque => AppColors.tranque,
            null => AppColors.neonCyan,
          };

    final tag = switch (event.specialEvent) {
      SpecialEventType.capicua => 'Capicúa',
      SpecialEventType.tranque => 'Tranque',
      null => null,
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: event.isGameVictory ? 0.5 : 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#$index',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              if (event.isGameVictory)
                Icon(Icons.emoji_events_outlined, size: 14, color: color)
              else if (event.specialEvent == SpecialEventType.capicua)
                Icon(Icons.auto_awesome, size: 14, color: color)
              else if (event.specialEvent == SpecialEventType.tranque)
                Icon(Icons.block, size: 14, color: color),
            ],
          ),
          const Spacer(),
          Text(
            '+${event.points}',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w300,
              height: 1,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ScoreEventFormatter.gridLabel(event, session),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
          if (tag != null && !event.isGameVictory)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
