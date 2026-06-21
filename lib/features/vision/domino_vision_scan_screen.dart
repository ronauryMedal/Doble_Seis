import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/domino_pips.dart';
import '../../core/utils/haptic_utils.dart';
import 'domino_vision_pipeline.dart';
import 'models/domino_vision_result.dart';
import 'services/gemini_domino_vision_service.dart';
import 'vision_settings_scope.dart';
import 'widgets/gemini_api_key_dialog.dart';

/// Pantalla de cámara para escanear fichas con IA.
class DominoVisionScanScreen extends StatefulWidget {
  const DominoVisionScanScreen({
    super.key,
    required this.targetName,
    required this.onApply,
  });

  final String targetName;
  final ValueChanged<int> onApply;

  @override
  State<DominoVisionScanScreen> createState() => _DominoVisionScanScreenState();
}

class _DominoVisionScanScreenState extends State<DominoVisionScanScreen> {
  CameraController? _controller;
  bool _initializing = true;
  String? _error;
  bool _processing = false;
  DominoVisionResult? _result;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _error = 'Se necesita permiso de cámara.';
        _initializing = false;
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = 'No hay cámara disponible.';
          _initializing = false;
        });
        return;
      }

      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al abrir cámara: $e';
        _initializing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _processing) {
      return;
    }

    setState(() {
      _processing = true;
      _result = null;
    });

    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      await _analyzeBytes(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al capturar: $e'),
            backgroundColor: AppColors.neonRose,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _analyzeBytes(Uint8List bytes) async {
    final settings = VisionSettingsScope.of(context);
    final pipeline = DominoVisionPipeline(settings);

    try {
      final result = await pipeline.analyze(bytes);
      if (!mounted) return;
      setState(() => _result = result);

      if (result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'No se detectaron fichas.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        HapticUtils.mediumTap();
      }
    } on DominoVisionException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.neonRose,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeTile(int index) {
    if (_result == null) return;
    final tiles = List<DominoTile>.from(_result!.tiles)..removeAt(index);
    setState(() {
      _result = _result!.copyWith(tiles: tiles);
    });
  }

  void _apply() {
    final total = _result?.total ?? 0;
    if (total <= 0) return;
    widget.onApply(total);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = VisionSettingsScope.of(context);
    final pipeline = DominoVisionPipeline(settings);

    return Scaffold(
      backgroundColor: AppColors.nightBackground,
      appBar: AppBar(
        title: const Text('Escaneo IA'),
        actions: [
          IconButton(
            onPressed: () => showGeminiApiKeyDialog(context),
            icon: Icon(
              pipeline.hasCloudAi ? Icons.key : Icons.key_off_outlined,
              color: pipeline.hasCloudAi
                  ? AppColors.neonCyan
                  : AppColors.textMuted,
            ),
            tooltip: 'Clave Gemini IA',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildCameraArea()),
          _buildBottomPanel(context, pipeline.hasCloudAi),
        ],
      ),
    );
  }

  Widget _buildCameraArea() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_controller!),
        if (_processing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.neonCyan),
                  SizedBox(height: 12),
                  Text(
                    'Analizando fichas…',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        IgnorePointer(
          child: CustomPaint(
            painter: _ScanGuidePainter(),
            child: Container(),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Text(
            'Enmarca las fichas del perdedor con buena luz',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              shadows: const [Shadow(blurRadius: 8, color: Colors.black)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel(BuildContext context, bool hasCloudAi) {
    final result = _result;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.nightSurface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                hasCloudAi ? Icons.auto_awesome : Icons.memory_outlined,
                size: 16,
                color: hasCloudAi ? AppColors.neonCyan : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hasCloudAi
                      ? 'IA Gemini — varias fichas'
                      : 'Modo local — configura Gemini para más precisión',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                ),
              ),
            ],
          ),
          if (result != null && result.tiles.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Total: ${result.total} pts · ${result.tiles.length} fichas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.neonCyan,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(result.tiles.length, (i) {
                final tile = result.tiles[i];
                return InputChip(
                  label: Text('${tile.label} (${tile.pips})'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeTile(i),
                  backgroundColor: AppColors.nightCard,
                );
              }),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: result.total > 0 ? _apply : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.neonCyan,
                foregroundColor: AppColors.nightBackground,
              ),
              child: Text('Anotar ${result.total} a ${widget.targetName}'),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (result != null)
                TextButton(
                  onPressed: () => setState(() => _result = null),
                  child: const Text('Repetir'),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _processing ? null : _captureAndAnalyze,
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: const Text('Capturar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.nightCard,
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.88,
      height: size.height * 0.55,
    );
    final overlay = Paint()..color = Colors.black.withValues(alpha: 0.45);
    final full = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(full)
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlay);

    final border = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      border,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
