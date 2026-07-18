import '../../data/models/game_session.dart';
import '../../data/models/live_room_connection_info.dart';
import '../../domain/enums/live_room_connection_mode.dart';
import '../../domain/enums/room_role.dart';

/// Contrato para sincronizar el marcador entre dispositivos.
abstract class LiveRoomService {
  LiveRoomConnectionMode get mode;

  bool get isConnected;

  /// Anfitrión: abre sala y devuelve datos para compartir.
  Future<LiveRoomConnectionInfo> createRoom({
    required GameSession initialSession,
  });

  /// Espectador: se conecta a la sala del anfitrión y devuelve el marcador
  /// inicial recibido (evita depender del siguiente broadcast).
  Future<GameSession> joinRoom({required LiveRoomConnectionInfo connection});

  /// Emite cada actualización del marcador remoto.
  Stream<GameSession> watchSession();

  /// Aviso de que la sala se cerró (anfitrión terminó o se perdió la conexión).
  Stream<String> watchRoomClosed();

  /// Solo el anfitrión puede escribir.
  Future<void> pushScoreUpdate({
    required GameSession session,
    required RoomRole role,
  });

  Future<void> leaveRoom();
}
