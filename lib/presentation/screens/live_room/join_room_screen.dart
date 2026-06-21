import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../data/models/live_room_connection_info.dart';
import '../../../domain/enums/live_room_connection_mode.dart';
import '../../../domain/enums/room_role.dart';
import '../../../features/live_room/live_room_joiner.dart';
import '../../../features/live_room/live_room_manager.dart';
import '../../../features/live_room/local_wifi_live_room_service.dart';
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
      MaterialPageRoute<void>(
        builder: (_) => ScanRoomQrScreen(
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ver marcador en vivo',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Escanea el QR que muestra el anfitrión en su pantalla. '
                'Ambos celulares deben estar en la misma WiFi.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _openScanner,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text(
                  'Escanear QR',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: AppColors.nightBackground,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => setState(() => _showManual = !_showManual),
                child: Text(
                  _showManual ? 'Ocultar entrada manual' : 'Ingresar IP y código manualmente',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
              if (_showManual) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _hostIpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration(
                    label: 'IP del anfitrión',
                    hint: 'Ej: 192.168.1.42',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _roomCodeController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(
                      AppConstants.liveRoomCodeLength,
                    ),
                  ],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _inputDecoration(
                    label: 'Código de sala',
                    hint: '6 caracteres',
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _connecting ? null : _connectManual,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.neonCyan,
                    side: BorderSide(
                      color: AppColors.neonCyan.withValues(alpha: 0.4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _connecting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Conectar manualmente'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.nightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.neonCyan.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
