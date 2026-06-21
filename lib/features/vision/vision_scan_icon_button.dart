import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Escaneo IA de fichas con cámara (activable con [AppConstants.dominoVisionScanEnabled]).
class VisionScanIconButton extends StatelessWidget {
  const VisionScanIconButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  void _onTap(BuildContext context) {
    if (!AppConstants.dominoVisionScanEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Conteo con cámara — en desarrollo'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.nightCard,
        ),
      );
      return;
    }
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = AppConstants.dominoVisionScanEnabled && onPressed != null;
    final color = enabled
        ? AppColors.neonCyan.withValues(alpha: 0.85)
        : AppColors.textMuted.withValues(alpha: 0.55);

    return IconButton(
      onPressed: () => _onTap(context),
      tooltip: enabled
          ? 'Escaneo IA con cámara'
          : 'Conteo con cámara (en desarrollo)',
      icon: Icon(
        Icons.document_scanner_outlined,
        size: 22,
        color: color,
      ),
      style: IconButton.styleFrom(
        backgroundColor: enabled
            ? AppColors.neonCyan.withValues(alpha: 0.1)
            : AppColors.nightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: enabled
                ? AppColors.neonCyan.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        minimumSize: const Size(40, 40),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
