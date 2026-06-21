/// Modelo de sala en vivo — preparado para Streams remotos.
///
/// Este modelo NO conecta a Firebase todavía; define la forma de los datos
/// para que la integración futura sea un "enchufar y listo".
class LiveRoom {
  const LiveRoom({
    required this.roomId,
    required this.leaderId,
    required this.spectatorIds,
    required this.isActive,
    required this.lastSyncedAt,
  });

  final String roomId;
  final String leaderId;
  final List<String> spectatorIds;
  final bool isActive;
  final DateTime? lastSyncedAt;

  Map<String, dynamic> toMap() => {
        'roomId': roomId,
        'leaderId': leaderId,
        'spectatorIds': spectatorIds,
        'isActive': isActive,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      };

  factory LiveRoom.fromMap(Map<dynamic, dynamic> map) => LiveRoom(
        roomId: map['roomId'] as String,
        leaderId: map['leaderId'] as String,
        spectatorIds: List<String>.from(map['spectatorIds'] as List),
        isActive: map['isActive'] as bool,
        lastSyncedAt: map['lastSyncedAt'] != null
            ? DateTime.parse(map['lastSyncedAt'] as String)
            : null,
      );

  LiveRoom copyWith({
    String? roomId,
    String? leaderId,
    List<String>? spectatorIds,
    bool? isActive,
    DateTime? lastSyncedAt,
  }) =>
      LiveRoom(
        roomId: roomId ?? this.roomId,
        leaderId: leaderId ?? this.leaderId,
        spectatorIds: spectatorIds ?? this.spectatorIds,
        isActive: isActive ?? this.isActive,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );
}
