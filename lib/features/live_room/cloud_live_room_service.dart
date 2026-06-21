import '../../data/models/game_session.dart';
import '../../data/models/live_room_connection_info.dart';
import '../../domain/enums/live_room_connection_mode.dart';
import '../../domain/enums/room_role.dart';
import 'live_room_service.dart';

/// Placeholder para Firebase / Supabase — fase 2.
class CloudLiveRoomService implements LiveRoomService {
  @override
  LiveRoomConnectionMode get mode => LiveRoomConnectionMode.cloud;

  @override
  bool get isConnected => false;

  @override
  Future<LiveRoomConnectionInfo> createRoom({
    required GameSession initialSession,
  }) async {
    throw UnimplementedError('Sala en la nube — próximamente.');
  }

  @override
  Future<void> joinRoom({required LiveRoomConnectionInfo connection}) async {
    throw UnimplementedError('Sala en la nube — próximamente.');
  }

  @override
  Stream<GameSession> watchSession() {
    throw UnimplementedError('Sala en la nube — próximamente.');
  }

  @override
  Future<void> pushScoreUpdate({
    required GameSession session,
    required RoomRole role,
  }) async {
    throw UnimplementedError('Sala en la nube — próximamente.');
  }

  @override
  Future<void> leaveRoom() async {}
}
