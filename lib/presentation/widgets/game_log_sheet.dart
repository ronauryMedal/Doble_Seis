import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/score_event_formatter.dart';
import '../../data/models/game_session.dart';
import '../../domain/enums/special_event_type.dart';

/// Bitácora de anotaciones de la partida actual.
void showGameLogSheet(BuildContext context, GameSession session) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.nightSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _GameLogSheet(session: session),
  );
}

class _GameLogSheet extends StatelessWidget {
  const _GameLogSheet({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final events = session.events.reversed.toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, color: AppColors.neonCyan),
                    const SizedBox(width: 10),
                    Text(
                      'Bitácora',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${events.length} registros',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: events.isEmpty
                    ? Center(
                        child: Text(
                          'Aún no hay anotaciones.\n'
                          'Capicúa o Tranque → luego ingresa los puntos.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: events.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return _LogEntryTile(
                            text: ScoreEventFormatter.describe(event, session),
                            specialEvent: event.specialEvent,
                            isVictory: event.isGameVictory,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({
    required this.text,
    required this.specialEvent,
    required this.isVictory,
  });

  final String text;
  final SpecialEventType? specialEvent;
  final bool isVictory;

  @override
  Widget build(BuildContext context) {
    final color = isVictory
        ? AppColors.neonAmber
        : switch (specialEvent) {
            SpecialEventType.capicua => AppColors.capicua,
            SpecialEventType.tranque => AppColors.tranque,
            null => AppColors.textPrimary,
          };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.nightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isVictory ? 0.4 : 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVictory
                ? Icons.emoji_events_outlined
                : switch (specialEvent) {
                    SpecialEventType.capicua => Icons.auto_awesome,
                    SpecialEventType.tranque => Icons.block,
                    null => Icons.add_circle_outline,
                  },
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: isVictory ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
