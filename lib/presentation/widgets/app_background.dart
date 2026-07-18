import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';

/// Fondo moderno: gradiente + luces suaves de ambiente.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.includeSafeArea = false,
  });

  final Widget child;
  final bool includeSafeArea;

  @override
  Widget build(BuildContext context) {
    final content = includeSafeArea ? SafeArea(child: child) : child;
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.atmosphereTop,
                AppColors.nightBackground,
                AppColors.atmosphereBottom,
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),
        // Luz menta arriba-izquierda
        Positioned(
          top: -80,
          left: -60,
          child: IgnorePointer(
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.glowMint, Colors.transparent],
                ),
              ),
            ),
          ),
        ),
        // Luz coral abajo-derecha
        Positioned(
          bottom: -40,
          right: -50,
          child: IgnorePointer(
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.glowCoral, Colors.transparent],
                ),
              ),
            ),
          ),
        ),
        content,
      ],
    );
  }
}

/// Card moderna con borde suave y sombra elegante.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: AppMotion.normal,
      curve: AppMotion.soft,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.nightCard,
        borderRadius: AppRadii.borderLg,
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.borderLg,
        child: card,
      ),
    );
  }
}

/// Chip selector con animación de selección.
class SelectChip extends StatelessWidget {
  const SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppColors.neonCyan,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.soft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.nightSurface,
          borderRadius: AppRadii.borderMd,
          border: Border.all(
            color: selected ? color : Colors.white.withValues(alpha: 0.08),
            width: selected ? 0 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: AppMotion.fast,
          curve: AppMotion.easeOut,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.ink : AppColors.textSecondary,
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

/// Escala táctil al pulsar (botones, chips).
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel:
          widget.enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: AppMotion.fast,
        curve: AppMotion.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Entrada escalonada elegante para listas de widgets.
extension AppEntrance on Widget {
  Widget entrance({int index = 0}) {
    final delay = AppMotion.stagger * index;
    return animate(delay: delay)
        .fadeIn(duration: AppMotion.slow, curve: AppMotion.soft)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: AppMotion.slow,
          curve: AppMotion.soft,
        );
  }
}
