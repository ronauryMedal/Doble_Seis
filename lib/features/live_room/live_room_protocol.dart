import 'dart:convert';

import '../../data/models/game_session.dart';

/// Mensajes JSON entre anfitrión y espectadores por WebSocket.
class LiveRoomProtocol {
  LiveRoomProtocol._();

  static const sessionType = 'session';
  static const joinType = 'join';
  static const joinedType = 'joined';
  static const errorType = 'error';
  static const roomClosedType = 'room_closed';

  static String encodeJoin({required String roomCode}) => jsonEncode({
        'type': joinType,
        'roomCode': roomCode.toUpperCase(),
      });

  static String encodeSession(GameSession session) => jsonEncode({
        'type': sessionType,
        'session': session.toMap(),
      });

  static String encodeJoined() => jsonEncode({
        'type': joinedType,
        'role': 'spectator',
      });

  static String encodeError(String message) => jsonEncode({
        'type': errorType,
        'message': message,
      });

  static String encodeRoomClosed({
    String message =
        'El anfitrión cerró la sala. Escanea el QR o ingresa el código de nuevo.',
  }) =>
      jsonEncode({
        'type': roomClosedType,
        'message': message,
      });

  static Map<String, dynamic> decode(String raw) =>
      Map<String, dynamic>.from(jsonDecode(raw) as Map);

  static GameSession? sessionFromMessage(Map<String, dynamic> message) {
    if (message['type'] != sessionType) return null;
    final data = message['session'];
    if (data is! Map) return null;
    return GameSession.fromMap(Map<dynamic, dynamic>.from(data));
  }
}
