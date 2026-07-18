import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/live_room_connection_info.dart';
import '../../../domain/enums/live_room_connection_mode.dart';
import '../../../domain/enums/room_role.dart';
import '../../../features/live_room/live_room_joiner.dart';
import '../../../features/live_room/live_room_manager.dart';
import '../../../features/live_room/local_wifi_live_room_service.dart';
import '../../widgets/app_background.dart';
import 'scan_room_qr_screen.dart';

/// Unirse como espectador — QR primero, entrada manual opcional.
class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key, required this.liveRoomManager});

  final LiveRoomManager liveRoomManager;

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  bool _showManual = false;
  bool _connecting = false;
  final _hostIpController = TextEditingController();
  final _roomCodeController = TextEditingController();

  @override
  void dispose() {
    _hostIpController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  void _openScanner() {
    Navigator.of(context).push(
      AppPageRoute(
        page: ScanRoomQrScreen(
          liveRoomManager: widget.liveRoomManager,
        ),
      ),
    );
  }

  Future<void> _connectManual() async {
    final host = _hostIpController.text.trim();
    final code = _roomCodeController.text.trim().toUpperCase();

    if (host.isEmpty) {
      _showError('Ingresa la IP del anfitrión.');
      return;
    }
    if (code.length != AppConstants.liveRoomCodeLength) {
      _showError(
        'El código debe tener ${AppConstants.liveRoomCodeLength} caracteres.',
      );
      return;
    }

    setState(() => _connecting = true);
    HapticUtils.mediumTap();

    try {
      await LiveRoomJoiner.joinAsSpectator(
        context: context,
        manager: widget.liveRoomManager,
        connection: LiveRoomConnectionInfo(
          mode: LiveRoomConnectionMode.localWifi,
          roomCode: code,
          role: RoomRole.spectator,
          hostAddress: host,
          port: AppConstants.liveRoomPort,
        ),
      );
    } on LiveRoomException catch (e) {
      await widget.liveRoomManager.disconnect();
      _showError(e.message);
    } catch (_) {
      await widget.liveRoomManager.disconnect();
      _showError(
        'No se pudo conectar. Verifica IP, código y que ambos estén en la misma WiFi.',
      );
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
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
      appBar: AppBar(
        title: const Text('Unirse a sala'),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ver marcador en vivo',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Escanea el QR que muestra el anfitrión. '
                        'Ambos celulares deben estar en la misma WiFi.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: _openScanner,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Escanear QR'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => setState(() => _showManual = !_showManual),
                  child: Text(
                    _showManual
                        ? 'Ocultar entrada manual'
                        : 'Ingresar IP y código manualmente',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
                AnimatedSwitcher(
                  duration: AppMotion.normal,
                  child: !_showManual
                      ? const SizedBox.shrink()
                      : SoftCard(
                          key: const ValueKey('manual'),
                          child: Column(
                            children: [
                              TextField(
                                controller: _hostIpController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'IP del anfitrión',
                                  hintText: 'Ej: 192.168.1.42',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TextField(
                                controller: _roomCodeController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z0-9]'),
                                  ),
                                  LengthLimitingTextInputFormatter(
                                    AppConstants.liveRoomCodeLength,
                                  ),
                                ],
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  letterSpacing: 4,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Código de sala',
                                  hintText: '6 caracteres',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              FilledButton(
                                onPressed: _connecting ? null : _connectManual,
                                child: _connecting
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Conectar'),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
