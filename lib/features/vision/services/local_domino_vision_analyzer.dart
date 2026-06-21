import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../../core/utils/domino_pips.dart';
import '../models/domino_vision_result.dart';

/// Análisis local sin nube — mejor con 1 ficha centrada y buena luz.
class LocalDominoVisionAnalyzer {
  Future<DominoVisionResult> analyze(Uint8List jpegBytes) async {
    final decoded = img.decodeImage(jpegBytes);
    if (decoded == null) {
      throw DominoVisionLocalException('No se pudo leer la imagen.');
    }

    final resized = img.copyResize(
      decoded,
      width: decoded.width > 900 ? 900 : decoded.width,
    );

    final crop = _centerCrop(resized, 0.55, 0.65);
    final tile = _detectSingleTile(crop);

    if (tile == null) {
      return const DominoVisionResult(
        tiles: [],
        source: VisionAnalysisSource.local,
        confidence: 0.2,
        message:
            'Modo local: coloca una ficha centrada con buena luz, o configura Gemini IA.',
      );
    }

    return DominoVisionResult(
      tiles: [tile],
      source: VisionAnalysisSource.local,
      confidence: 0.55,
      message: 'Modo local: 1 ficha detectada. Para varias fichas usa Gemini IA.',
    );
  }

  img.Image _centerCrop(img.Image source, double widthFactor, double heightFactor) {
    final w = (source.width * widthFactor).round().clamp(1, source.width);
    final h = (source.height * heightFactor).round().clamp(1, source.height);
    final x = ((source.width - w) / 2).round();
    final y = ((source.height - h) / 2).round();
    return img.copyCrop(source, x: x, y: y, width: w, height: h);
  }

  DominoTile? _detectSingleTile(img.Image crop) {
    final gray = img.grayscale(crop);
    final components = _findDarkComponents(gray);
    if (components.isEmpty) return null;

    final minArea = (crop.width * crop.height * 0.0008).round();
    final maxArea = (crop.width * crop.height * 0.04).round();
    final pips = components
        .where((c) => c.area >= minArea && c.area <= maxArea)
        .toList();

    if (pips.isEmpty) return null;

    final midX = crop.width / 2;
    final gap = crop.width * 0.06;
    var left = 0;
    var right = 0;

    for (final pip in pips) {
      if (pip.cx < midX - gap) {
        left++;
      } else if (pip.cx > midX + gap) {
        right++;
      }
    }

    left = left.clamp(0, DominoPips.maxPip);
    right = right.clamp(0, DominoPips.maxPip);

    if (left == 0 && right == 0) return null;
    return DominoTile(left: left, right: right);
  }

  List<_Component> _findDarkComponents(img.Image gray) {
    final w = gray.width;
    final h = gray.height;
    final visited = List.generate(w * h, (_) => false);
    final threshold = _estimateThreshold(gray);
    final components = <_Component>[];

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final idx = y * w + x;
        if (visited[idx]) continue;
        final lum = gray.getPixel(x, y).r.toInt();
        if (lum >= threshold) continue;

        var area = 0;
        var sumX = 0;
        var sumY = 0;
        final stack = <(int, int)>[(x, y)];

        while (stack.isNotEmpty) {
          final (cx, cy) = stack.removeLast();
          if (cx < 0 || cy < 0 || cx >= w || cy >= h) continue;
          final cIdx = cy * w + cx;
          if (visited[cIdx]) continue;
          if (gray.getPixel(cx, cy).r.toInt() >= threshold) continue;

          visited[cIdx] = true;
          area++;
          sumX += cx;
          sumY += cy;
          stack.add((cx + 1, cy));
          stack.add((cx - 1, cy));
          stack.add((cx, cy + 1));
          stack.add((cx, cy - 1));
        }

        if (area > 4) {
          components.add(
            _Component(
              area: area,
              cx: sumX / area,
              cy: sumY / area,
            ),
          );
        }
      }
    }

    return components;
  }

  int _estimateThreshold(img.Image gray) {
    var sum = 0;
    final total = gray.width * gray.height;
    for (var y = 0; y < gray.height; y++) {
      for (var x = 0; x < gray.width; x++) {
        sum += gray.getPixel(x, y).r.toInt();
      }
    }
    final mean = sum / total;
    return (mean * 0.72).round().clamp(60, 170);
  }
}

class _Component {
  const _Component({
    required this.area,
    required this.cx,
    required this.cy,
  });

  final int area;
  final double cx;
  final double cy;
}

class DominoVisionLocalException implements Exception {
  DominoVisionLocalException(this.message);
  final String message;

  @override
  String toString() => message;
}
