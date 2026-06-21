import 'package:equatable/equatable.dart';

import '../../domain/enums/live_room_connection_mode.dart';
import '../../domain/enums/room_role.dart';

/// Datos para conectar o compartir una sala en vivo.
class LiveRoomConnectionInfo extends Equatable {
  const LiveRoomConnectionInfo({
    required this.mode,
    required this.roomCode,
    required this.role,
    this.hostAddress,
    this.port,
  });

  final LiveRoomConnectionMode mode;
  final String roomCode;
  final RoomRole role;
  final String? hostAddress;
  final int? port;

  String get shareLine {
    if (mode == LiveRoomConnectionMode.localWifi &&
        hostAddress != null &&
        port != null) {
      return '$hostAddress:$port · $roomCode';
    }
    return roomCode;
  }

  LiveRoomConnectionInfo copyWith({
    LiveRoomConnectionMode? mode,
    String? roomCode,
    RoomRole? role,
    String? hostAddress,
    int? port,
  }) =>
      LiveRoomConnectionInfo(
        mode: mode ?? this.mode,
        roomCode: roomCode ?? this.roomCode,
        role: role ?? this.role,
        hostAddress: hostAddress ?? this.hostAddress,
        port: port ?? this.port,
      );

  Map<String, dynamic> toMap() => {
        'mode': mode.name,
        'roomCode': roomCode,
        'role': role.name,
        'hostAddress': hostAddress,
        'port': port,
      };

  factory LiveRoomConnectionInfo.fromMap(Map<dynamic, dynamic> map) =>
      LiveRoomConnectionInfo(
        mode: LiveRoomConnectionMode.values.byName(map['mode'] as String),
        roomCode: map['roomCode'] as String,
        role: RoomRole.values.byName(map['role'] as String),
        hostAddress: map['hostAddress'] as String?,
        port: map['port'] as int?,
      );

  @override
  List<Object?> get props => [mode, roomCode, role, hostAddress, port];
}
