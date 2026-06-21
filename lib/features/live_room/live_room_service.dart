import '../../../data/models/game_session.dart';
import '../../../domain/enums/room_role.dart';

/// Contrato para sincronización en tiempo real (Firebase / Supabase).
///
/// HOOK FUTURO: implementa esta interfaz cuando conectes el backend.
/// El BLoC podrá escuchar [watchSession] como un Stream remoto.
abstract class LiveRoomService {
  /// Crea una sala y devuelve el ID para compartir.
  Future<String> createRoom({required String leaderId});

  /// Une a un espectador a la sala.
  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required RoomRole role,
  });

  /// Stream que emite cada cambio del marcador desde la nube.
  Stream<GameSession> watchSession(String roomId);

  /// Solo el líder puede escribir — los espectadores reciben error.
  Future<void> pushScoreUpdate({
    required String roomId,
    required GameSession session,
    required RoomRole role,
  });

  Future<void> leaveRoom(String roomId);
}

/// Implementación local vacía — la app funciona offline por ahora.
class LiveRoomServiceStub implements LiveRoomService {
  @override
  Future<String> createRoom({required String leaderId}) async {
    throw UnimplementedError('Conectar Firebase o Supabase en fase 2');
  }

  @override
  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required RoomRole role,
  }) async {
    throw UnimplementedError('Conectar Firebase o Supabase en fase 2');
  }

  @override
  Stream<GameSession> watchSession(String roomId) {
    throw UnimplementedError('Conectar Firebase o Supabase en fase 2');
  }

  @override
  Future<void> pushScoreUpdate({
    required String roomId,
    required GameSession session,
    required RoomRole role,
  }) async {
    throw UnimplementedError('Conectar Firebase o Supabase en fase 2');
  }

  @override
  Future<void> leaveRoom(String roomId) async {}
}
