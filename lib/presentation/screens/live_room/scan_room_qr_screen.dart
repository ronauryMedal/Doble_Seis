import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../features/live_room/live_room_joiner.dart';
import '../../../features/live_room/live_room_manager.dart';
import '../../../features/live_room/live_room_qr_codec.dart';
import '../../../features/live_room/local_wifi_live_room_service.dart';

/// Escanea el QR del anfitrión y entra a la sala automáticamente.
class ScanRoomQrScreen extends StatefulWidget {
  const ScanRoomQrScreen({super.key, required this.liveRoomManager});

  final LiveRoomManager liveRoomManager;

  @override
  State<ScanRoomQrScreen> createState() => _ScanRoomQrScreenState();
}

class _ScanRoomQrScreenState extends State<ScanRoomQrScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _connecting = false;
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onQrDetected(String raw) async {
    if (_connecting || _handled) return;

    final connection = LiveRoomQrCodec.decode(raw);
    if (connection == null) return;

    setState(() {
      _connecting = true;
      _handled = true;
    });

    await _controller.stop();
    HapticUtils.mediumTap();

    if (!mounted) return;

    try {
      await LiveRoomJoiner.joinAsSpectator(
        context: context,
        manager: widget.liveRoomManager,
        connection: connection,
      );
    } on LiveRoomException catch (e) {
      await widget.liveRoomManager.disconnect();
      if (!mounted) return;
      _showError(e.message);
      _resetScanner();
    } on Exception {
      await widget.liveRoomManager.disconnect();
      if (!mounted) return;
      _showError('No se pudo conectar. ¿Estás en la misma WiFi?');
      _resetScanner();
    }
  }

  void _resetScanner() {
    if (!mounted) return;
    setState(() {
      _connecting = false;
      _handled = false;
    });
    _controller.start();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.neonRose),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nightBackground,
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final value = barcode.rawValue;
                if (value != null) {
                  _onQrDetected(value);
                  break;
                }
              }
            },
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _connecting
                              ? 'Conectando a la sala…'
                              : 'Apunta al QR del anfitrión',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (_connecting) ...[
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(
                          color: AppColors.neonCyan,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
