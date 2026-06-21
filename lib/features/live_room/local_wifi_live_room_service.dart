import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/game_session.dart';
import '../../data/models/live_room_connection_info.dart';
import '../../domain/enums/live_room_connection_mode.dart';
import '../../domain/enums/room_role.dart';
import 'live_room_protocol.dart';
import 'live_room_service.dart';

/// Sala en la misma red WiFi — el anfitrión levanta un servidor WebSocket.
class LocalWifiLiveRoomService implements LiveRoomService {
  HttpServer? _server;
  final Set<WebSocket> _clients = {};
  WebSocketChannel? _clientChannel;
  StreamSubscription<dynamic>? _clientSubscription;
  final StreamController<GameSession> _sessionController =
      StreamController<GameSession>.broadcast();

  String? _roomCode;
  String? _hostIp;
  GameSession? _currentSession;
  bool _connected = false;

  @override
  LiveRoomConnectionMode get mode => LiveRoomConnectionMode.localWifi;

  @override
  bool get isConnected => _connected;

  @override
  Future<LiveRoomConnectionInfo> createRoom({
    required GameSession initialSession,
  }) async {
    await leaveRoom();

    _currentSession = initialSession;
    _roomCode = _generateRoomCode();
    _hostIp = await _resolveLocalIp();

    if (_hostIp == null) {
      throw LiveRoomException(
        'No se detectó IP WiFi. Conecta el celular a la misma red.',
      );
    }

    _server = await HttpServer.bind(
      InternetAddress.anyIPv4,
      AppConstants.liveRoomPort,
    );
    _server!.listen(_handleHttpRequest, onError: (_) {});

    _connected = true;
    _sessionController.add(initialSession);

    return LiveRoomConnectionInfo(
      mode: LiveRoomConnectionMode.localWifi,
      roomCode: _roomCode!,
      role: RoomRole.leader,
      hostAddress: _hostIp,
      port: AppConstants.liveRoomPort,
    );
  }

  @override
  Future<void> joinRoom({required LiveRoomConnectionInfo connection}) async {
    await leaveRoom();

    final host = connection.hostAddress;
    final port = connection.port ?? AppConstants.liveRoomPort;
    if (host == null || host.isEmpty) {
      throw LiveRoomException('Ingresa la IP del anfitrión.');
    }

    final uri = Uri.parse('ws://$host:$port');
    final channel = WebSocketChannel.connect(uri);
    _clientChannel = channel;

    final joined = Completer<void>();
    final firstSession = Completer<GameSession>();

    _clientSubscription = channel.stream.listen(
      (data) {
        final message = LiveRoomProtocol.decode(data as String);
        switch (message['type']) {
          case LiveRoomProtocol.joinedType:
            if (!joined.isCompleted) joined.complete();
          case LiveRoomProtocol.sessionType:
            final session = LiveRoomProtocol.sessionFromMessage(message);
            if (session != null) {
              _sessionController.add(session);
              if (!firstSession.isCompleted) firstSession.complete(session);
            }
          case LiveRoomProtocol.errorType:
            final error = message['message'] as String? ?? 'Error de conexión';
            if (!joined.isCompleted) {
              joined.completeError(LiveRoomException(error));
            }
        }
      },
      onError: (Object error) {
        if (!joined.isCompleted) {
          joined.completeError(
            LiveRoomException('No se pudo conectar a $host:$port'),
          );
        }
      },
      onDone: () {
        _connected = false;
        if (!joined.isCompleted) {
          joined.completeError(
            LiveRoomException('La sala se cerró o perdió conexión.'),
          );
        }
      },
    );

    channel.sink.add(
      LiveRoomProtocol.encodeJoin(roomCode: connection.roomCode),
    );

    await joined.future.timeout(
      AppConstants.liveRoomConnectTimeout,
      onTimeout: () => throw LiveRoomException(
        'Tiempo agotado. Verifica IP, código y que estés en la misma WiFi.',
      ),
    );

    await firstSession.future.timeout(
      AppConstants.liveRoomConnectTimeout,
      onTimeout: () => throw LiveRoomException(
        'Conectado, pero no llegó el marcador del anfitrión.',
      ),
    );

    _connected = true;
  }

  @override
  Stream<GameSession> watchSession() => _sessionController.stream;

  @override
  Future<void> pushScoreUpdate({
    required GameSession session,
    required RoomRole role,
  }) async {
    if (role != RoomRole.leader) {
      throw LiveRoomException('Solo el anfitrión puede modificar el marcador.');
    }
    _currentSession = session;
    _broadcastSession(session);
    _sessionController.add(session);
  }

  @override
  Future<void> leaveRoom() async {
    _connected = false;

    for (final client in _clients.toList()) {
      try {
        await client.close();
      } catch (_) {}
    }
    _clients.clear();

    await _clientSubscription?.cancel();
    _clientSubscription = null;
    try {
      await _clientChannel?.sink.close();
    } catch (_) {}
    _clientChannel = null;

    await _server?.close(force: true);
    _server = null;

    _roomCode = null;
    _hostIp = null;
    _currentSession = null;
  }

  void _handleHttpRequest(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final socket = await WebSocketTransformer.upgrade(request);
    _clients.add(socket);

    socket.listen(
      (data) => _handleClientMessage(socket, data),
      onDone: () => _clients.remove(socket),
      onError: (_) => _clients.remove(socket),
    );

    if (_currentSession != null) {
      socket.add(LiveRoomProtocol.encodeSession(_currentSession!));
    }
  }

  void _handleClientMessage(WebSocket socket, dynamic data) {
    try {
      final message = LiveRoomProtocol.decode(data as String);
      if (message['type'] != LiveRoomProtocol.joinType) return;

      final code = (message['roomCode'] as String?)?.toUpperCase();
      if (code != _roomCode) {
        socket.add(LiveRoomProtocol.encodeError('Código de sala incorrecto.'));
        return;
      }

      socket.add(LiveRoomProtocol.encodeJoined());
      if (_currentSession != null) {
        socket.add(LiveRoomProtocol.encodeSession(_currentSession!));
      }
    } on Object {
      socket.add(LiveRoomProtocol.encodeError('Mensaje inválido.'));
    }
  }

  void _broadcastSession(GameSession session) {
    final payload = LiveRoomProtocol.encodeSession(session);
    for (final client in _clients.toList()) {
      try {
        client.add(payload);
      } on Object {
        _clients.remove(client);
      }
    }
  }

  Future<String?> _resolveLocalIp() async {
    try {
      for (final interface
          in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
        for (final address in interface.addresses) {
          if (!address.isLoopback) return address.address;
        }
      }
    } on Object {
      // Sin permisos de red o plataforma no soportada.
    }

    return null;
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(
      AppConstants.liveRoomCodeLength,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}

class LiveRoomException implements Exception {
  LiveRoomException(this.message);
  final String message;

  @override
  String toString() => message;
}
