import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Icono compacto de Escaneo IA (futuro ML Kit / YOLO).
class VisionScanIconButton extends StatelessWidget {
  const VisionScanIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escaneo IA — próximamente'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      tooltip: 'Escaneo IA (próximamente)',
      icon: Icon(
        Icons.document_scanner_outlined,
        size: 22,
        color: AppColors.neonCyan.withValues(alpha: 0.7),
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
    );
  }
}
