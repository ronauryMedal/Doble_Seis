import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../bloc/game/game_bloc.dart';
import 'app_background.dart';

/// Overlay de celebración — claro y humano, sin glow neón.
class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({
    super.key,
    required this.type,
    required this.onDismiss,
    this.winnerName,
    this.onRematch,
    this.onChangePlayers,
    this.waitingForHostRematch = false,
  });

  final CelebrationType type;
  final VoidCallback onDismiss;
  final String? winnerName;
  final VoidCallback? onRematch;
  final VoidCallback? onChangePlayers;

  /// Espectador: espera revancha del anfitrión (misma sala).
  final bool waitingForHostRematch;

  bool get _isGameEnd => type == CelebrationType.gameWon;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (type) {
      CelebrationType.capicua => (
          '¡Capicúa!',
          AppColors.capicua,
          Icons.auto_awesome_rounded,
        ),
      CelebrationType.tranque => (
          '¡Tranque!',
          AppColors.tranque,
          Icons.block_rounded,
        ),
      CelebrationType.gameWon => (
          '¡Ganó!',
          AppColors.neonAmber,
          Icons.emoji_events_rounded,
        ),
    };

    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SoftCard(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            borderColor: color,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: color)
                    .animate()
                    .fadeIn(duration: AppMotion.normal)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: AppMotion.slow,
                      curve: AppMotion.emphasized,
                    ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: color,
                      ),
                ).animate().fadeIn(delay: 60.ms, duration: AppMotion.normal),
                if (_isGameEnd && winnerName != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    winnerName!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (_isGameEnd &&
                    onRematch != null &&
                    onChangePlayers != null) ...[
                  Text(
                    '¿Otra con los mismos?\n'
                    'Si terminas la sala, los espectadores deberán escanear el QR otra vez.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: onRematch,
                    child: const Text('Sí, revancha'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: onChangePlayers,
                    child: const Text('Terminar sala'),
                  ),
                ] else if (_isGameEnd && waitingForHostRematch) ...[
                  Text(
                    'Esperando revancha del anfitrión…\n'
                    'Si cierra la sala, tendrás que escanear el QR otra vez.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: onDismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                    ),
                    child: const Text('Salir y escanear QR'),
                  ),
                ] else if (_isGameEnd) ...[
                  Text(
                    'La sala se cerró. Escanea el QR del anfitrión '
                    'para unirte de nuevo.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: onDismiss,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.neonAmber,
                      foregroundColor: AppColors.ink,
                    ),
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Escanear sala'),
                  ),
                ] else
                  TextButton(
                    onPressed: onDismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                    ),
                    child: const Text('Seguir'),
                  ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: AppMotion.normal)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: AppMotion.slow,
                curve: AppMotion.easeOut,
              ),
        ),
      ),
    );
  }
}
