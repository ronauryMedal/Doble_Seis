import 'package:flutter/services.dart';

/// Utilidad para feedback háptico consistente en toda la app.
///
/// Flutter expone [HapticFeedback] del SDK — no necesitamos paquete extra.
/// Diferentes intensidades comunican distintas acciones al usuario.
class HapticUtils {
  HapticUtils._();

  static Future<void> lightTap() => HapticFeedback.lightImpact();

  static Future<void> mediumTap() => HapticFeedback.mediumImpact();

  static Future<void> heavyTap() => HapticFeedback.heavyImpact();

  static Future<void> selection() => HapticFeedback.selectionClick();

  /// Vibración de advertencia (shot clock agotándose).
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
  }

  /// Celebración al ganar o evento especial.
  static Future<void> celebration() async {
    for (var i = 0; i < 3; i++) {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }
}
