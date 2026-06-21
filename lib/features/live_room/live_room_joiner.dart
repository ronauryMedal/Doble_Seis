import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/live_room_connection_info.dart';
import '../../domain/enums/live_room_connection_mode.dart';
import '../../domain/enums/room_role.dart';
import '../../core/constants/app_constants.dart';
import 'live_room_manager.dart';
import 'local_wifi_live_room_service.dart';
import '../../presentation/bloc/game/game_bloc.dart';
import '../../presentation/screens/scoreboard/scoreboard_screen.dart';

/// Conecta un espectador a la sala (desde QR o entrada manual).
class LiveRoomJoiner {
  LiveRoomJoiner._();

  static Future<void> joinAsSpectator({
    required BuildContext context,
    required LiveRoomManager manager,
    required LiveRoomConnectionInfo connection,
  }) async {
    if (connection.mode == LiveRoomConnectionMode.cloud) {
      throw LiveRoomException('Sala en la nube — próximamente.');
    }

    final spectatorConnection = LiveRoomConnectionInfo(
      mode: connection.mode,
      roomCode: connection.roomCode.toUpperCase(),
      role: RoomRole.spectator,
      hostAddress: connection.hostAddress,
      port: connection.port ?? AppConstants.liveRoomPort,
    );

    final service = manager.serviceFor(spectatorConnection.mode);
    await service.joinRoom(connection: spectatorConnection);

    final session = await service.watchSession().first.timeout(
          AppConstants.liveRoomConnectTimeout,
          onTimeout: () => throw LiveRoomException(
            'No llegó el marcador del anfitrión.',
          ),
        );

    if (!context.mounted) return;

    context.read<GameBloc>().add(
          LiveRoomSpectatorStarted(
            session: session,
            info: spectatorConnection,
          ),
        );

    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const ScoreboardScreen()),
      (route) => route.isFirst,
    );
  }
}
