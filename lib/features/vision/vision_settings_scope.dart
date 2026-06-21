import 'package:flutter/material.dart';

import 'data/vision_settings_repository.dart';

class VisionSettingsScope extends InheritedWidget {
  const VisionSettingsScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final VisionSettingsRepository repository;

  static VisionSettingsRepository of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<VisionSettingsScope>();
    assert(scope != null, 'VisionSettingsScope no encontrado');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(VisionSettingsScope oldWidget) =>
      repository != oldWidget.repository;
}
