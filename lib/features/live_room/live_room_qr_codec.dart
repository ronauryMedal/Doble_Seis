import '../../core/constants/app_constants.dart';
import '../../data/models/live_room_connection_info.dart';
import '../../domain/enums/live_room_connection_mode.dart';
import '../../domain/enums/room_role.dart';

/// Codifica / decodifica el QR de sala: dobleseis://join?h=IP&p=8765&c=CODIGO
class LiveRoomQrCodec {
  LiveRoomQrCodec._();

  static const scheme = 'dobleseis';

  static String encode(LiveRoomConnectionInfo info) {
    final host = info.hostAddress;
    if (host == null || host.isEmpty) {
      throw ArgumentError('Se necesita la IP del anfitrión para el QR.');
    }

    return Uri(
      scheme: scheme,
      host: 'join',
      queryParameters: {
        'h': host,
        'p': '${info.port ?? AppConstants.liveRoomPort}',
        'c': info.roomCode.toUpperCase(),
        'm': info.mode.name,
      },
    ).toString();
  }

  static LiveRoomConnectionInfo? decode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    try {
      final uri = Uri.parse(trimmed);
      if (uri.scheme != scheme || uri.host != 'join') return null;

      final host = uri.queryParameters['h'];
      final code = uri.queryParameters['c']?.toUpperCase();
      final port = int.tryParse(uri.queryParameters['p'] ?? '');
      final modeName = uri.queryParameters['m'] ?? LiveRoomConnectionMode.localWifi.name;

      if (host == null || host.isEmpty || code == null || code.isEmpty) {
        return null;
      }
      if (code.length != AppConstants.liveRoomCodeLength) return null;

      final mode = LiveRoomConnectionMode.values.asNameMap()[modeName] ??
          LiveRoomConnectionMode.localWifi;

      if (mode == LiveRoomConnectionMode.cloud) return null;

      return LiveRoomConnectionInfo(
        mode: mode,
        roomCode: code,
        role: RoomRole.spectator,
        hostAddress: host,
        port: port ?? AppConstants.liveRoomPort,
      );
    } on Object {
      return null;
    }
  }
}
