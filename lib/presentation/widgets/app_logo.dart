import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Logo de la app. Si no existe `assets/images/logo.png`, muestra el nombre.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 88,
    this.showName = true,
  });

  final double height;
  final bool showName;

  static const _assetPath = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          _assetPath,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _FallbackLogo(height: height),
        ),
        if (showName) ...[
          const SizedBox(height: 10),
          Text(
            AppConstants.appName.toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 4,
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ],
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.nightCard,
        borderRadius: BorderRadius.circular(height * 0.22),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.35),
        ),
      ),
      child: Icon(
        Icons.grid_view_rounded,
        size: height * 0.45,
        color: AppColors.neonCyan.withValues(alpha: 0.85),
      ),
    );
  }
}
