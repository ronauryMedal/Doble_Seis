import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../bloc/game/game_bloc.dart';

/// Overlay de celebración — al ganar pregunta revancha o cambiar jugadores.
class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({
    super.key,
    required this.type,
    required this.onDismiss,
    this.winnerName,
    this.onRematch,
    this.onChangePlayers,
  });

  final CelebrationType type;
  final VoidCallback onDismiss;
  final String? winnerName;
  final VoidCallback? onRematch;
  final VoidCallback? onChangePlayers;

  bool get _isGameEnd => type == CelebrationType.gameWon;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (type) {
      CelebrationType.capicua => (
          '¡CAPICÚA!',
          AppColors.capicua,
          Icons.auto_awesome,
        ),
      CelebrationType.tranque => (
          '¡TRANQUE!',
          AppColors.tranque,
          Icons.block,
        ),
      CelebrationType.gameWon => (
          '¡GANADOR!',
          AppColors.neonAmber,
          Icons.emoji_events_outlined,
        ),
    };

    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: color),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: color,
                  shadows: [
                    Shadow(color: color.withValues(alpha: 0.6), blurRadius: 30),
                  ],
                ),
              ),
              if (_isGameEnd && winnerName != null) ...[
                const SizedBox(height: 8),
                Text(
                  winnerName!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 22,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
              const SizedBox(height: 28),
              if (_isGameEnd && onRematch != null && onChangePlayers != null) ...[
                Text(
                  '¿Volver a jugar con los mismos jugadores?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onRematch,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.neonCyan,
                      foregroundColor: AppColors.nightBackground,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Sí, revancha',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onChangePlayers,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('No, cambiar jugadores'),
                  ),
                ),
              ] else if (_isGameEnd) ...[
                Text(
                  'La partida terminó. Escanea de nuevo el QR para unirte '
                  'a otra sala.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onDismiss,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.neonAmber,
                    foregroundColor: AppColors.nightBackground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Escanear otra sala'),
                ),
              ] else
                GestureDetector(
                  onTap: onDismiss,
                  child: Text(
                    'Toca para continuar',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
