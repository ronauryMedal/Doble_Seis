import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/live_room_connection_info.dart';
import '../../../features/live_room/live_room_qr_codec.dart';

/// Muestra el QR grande para que otros lo escaneen.
void showLiveRoomQrSheet(
  BuildContext context,
  LiveRoomConnectionInfo info,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.nightSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _LiveRoomQrSheet(info: info),
  );
}

class _LiveRoomQrSheet extends StatelessWidget {
  const _LiveRoomQrSheet({required this.info});

  final LiveRoomConnectionInfo info;

  @override
  Widget build(BuildContext context) {
    final payload = LiveRoomQrCodec.encode(info);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Escanea para unirte',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Abre Doble Seis en otro celular y elige\n"Escanear QR para unirse".',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: payload,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.nightBackground,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.nightBackground,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Código: ${info.roomCode}',
              style: const TextStyle(
                fontSize: 18,
                letterSpacing: 6,
                fontWeight: FontWeight.w600,
                color: AppColors.neonCyan,
              ),
            ),
            if (info.hostAddress != null) ...[
              const SizedBox(height: 4),
              Text(
                'Misma WiFi · ${info.hostAddress}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}
