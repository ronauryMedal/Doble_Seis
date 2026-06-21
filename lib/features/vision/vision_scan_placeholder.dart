import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// HOOK FUTURO: placeholder para escaneo de fichas con ML Kit / YOLO.
///
/// La UI ya reserva espacio y muestra el flujo previsto;
/// la lógica de cámara se conectará en una fase posterior.
class VisionScanPlaceholder extends StatelessWidget {
  const VisionScanPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
        color: AppColors.nightCard.withValues(alpha: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonCyan.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.document_scanner_outlined,
              color: AppColors.neonCyan.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escaneo IA',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Próximamente: reconocer fichas con cámara',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline,
            size: 18,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
