import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Colores de jugadores — menta, coral y acentos amigables.
class PlayerColors {
  PlayerColors._();

  static const List<Color> palette = [
    AppColors.teamA,
    AppColors.teamB,
    AppColors.neonRose,
    AppColors.capicua,
    Color(0xFF818CF8),
    Color(0xFF34D399),
  ];

  static Color forIndex(int index) => palette[index % palette.length];
}
