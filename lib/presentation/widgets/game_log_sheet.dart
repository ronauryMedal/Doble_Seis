import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/score_event_formatter.dart';
import '../../domain/enums/special_event_type.dart';
import '../bloc/game/game_bloc.dart';

/// Bitácora de anotaciones de la partida actual.
///
/// [canEdit] habilita eliminar anotaciones (corregir errores). Se desactiva
/// para espectadores o cuando la partida ya terminó.
void showGameLogSheet(
  BuildContext context, {
  bool canEdit = false,
}) {
  final bloc = context.read<GameBloc>();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.nightSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: _GameLogSheet(canEdit: canEdit),
    ),
  );
}

class _GameLogSheet extends StatelessWidget {
  const _GameLogSheet({required this.canEdit});

  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            final session = state.session;
            // Mostramos lo más reciente arriba, pero recordamos el índice real.
            final total = session.events.length;
            final entries = [
              for (var i = total - 1; i >= 0; i--)
                (originalIndex: i, event: session.events[i]),
            ];

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
                        const Icon(Icons.history_rounded,
                            color: AppColors.neonCyan),
                        const SizedBox(width: 10),
                        Text(
                          'Bitácora',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(fontSize: 20),
                        ),
                        const Spacer(),
                        Text(
                          '${entries.length} '
                          '${entries.length == 1 ? 'registro' : 'registros'}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (canEdit && entries.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.swipe_left_alt_rounded,
                            size: 14,
                            color: AppColors.textMuted.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Desliza o toca el bote para borrar una anotación',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: entries.isEmpty
                        ? Center(
                            child: Text(
                              'Aún no hay anotaciones.\n'
                              'Capicúa o Tranque → luego ingresa los puntos.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: entries.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return _LogEntryTile(
                                key: ValueKey(
                                  '${entry.event.timestamp.microsecondsSinceEpoch}'
                                  '_${entry.originalIndex}',
                                ),
                                text: ScoreEventFormatter.describe(
                                  entry.event,
                                  session,
                                ),
                                specialEvent: entry.event.specialEvent,
                                isVictory: entry.event.isGameVictory,
                                canDelete: canEdit,
                                onDelete: () => _confirmDelete(
                                  context,
                                  entry.originalIndex,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context, int originalIndex) async {
    final bloc = context.read<GameBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.nightSurface,
        title: const Text('¿Eliminar anotación?'),
        content: const Text(
          'Se restará del puntaje. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.neonRose),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(ScoreEventRemoved(originalIndex));
      return true;
    }
    return false;
  }
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({
    super.key,
    required this.text,
    required this.specialEvent,
    required this.isVictory,
    required this.canDelete,
    required this.onDelete,
  });

  final String text;
  final SpecialEventType? specialEvent;
  final bool isVictory;
  final bool canDelete;
  final Future<bool> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final color = isVictory
        ? AppColors.neonAmber
        : switch (specialEvent) {
            SpecialEventType.capicua => AppColors.capicua,
            SpecialEventType.tranque => AppColors.tranque,
            null => AppColors.textPrimary,
          };

    final tile = Container(
      padding: EdgeInsets.fromLTRB(14, 12, canDelete ? 6 : 14, 12),
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
          if (canDelete)
            IconButton(
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
              tooltip: 'Eliminar',
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.neonRose.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );

    if (!canDelete) return tile;

    return Dismissible(
      key: key ?? UniqueKey(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.neonRose.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.neonRose,
        ),
      ),
      child: tile,
    );
  }
}
