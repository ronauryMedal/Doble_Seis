import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Colores asignados a cada jugador/equipo en el marcador.
class PlayerColors {
  PlayerColors._();

  static const List<Color> palette = [
    AppColors.teamA,
    AppColors.teamB,
    AppColors.neonRose,
    AppColors.capicua,
    AppColors.neonAmber,
    Color(0xFF7CB3FF),
  ];

  static Color forIndex(int index) => palette[index % palette.length];
}
