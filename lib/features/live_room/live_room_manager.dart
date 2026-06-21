import '../../domain/enums/live_room_connection_mode.dart';
import 'cloud_live_room_service.dart';
import 'live_room_service.dart';
import 'local_wifi_live_room_service.dart';

/// Elige el servicio correcto según WiFi o nube.
class LiveRoomManager {
  LocalWifiLiveRoomService? _wifi;
  CloudLiveRoomService? _cloud;
  LiveRoomService? _active;
  LiveRoomConnectionMode? _activeMode;

  LiveRoomService? get activeService => _active;
  LiveRoomConnectionMode? get activeMode => _activeMode;

  LiveRoomService serviceFor(LiveRoomConnectionMode mode) {
    switch (mode) {
      case LiveRoomConnectionMode.offline:
        throw StateError('Modo offline no usa servicio de sala.');
      case LiveRoomConnectionMode.localWifi:
        _wifi ??= LocalWifiLiveRoomService();
        _active = _wifi;
        _activeMode = mode;
        return _wifi!;
      case LiveRoomConnectionMode.cloud:
        _cloud ??= CloudLiveRoomService();
        _active = _cloud;
        _activeMode = mode;
        return _cloud!;
    }
  }

  Future<void> disconnect() async {
    await _active?.leaveRoom();
    _active = null;
    _activeMode = null;
  }
}
