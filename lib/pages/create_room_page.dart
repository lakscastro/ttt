import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nsd/nsd.dart';
import 'package:ttt/pages/game_board.dart';
import '../const/nsd.dart';
import '../routing/navigator.dart';
import '../store/game_match.dart';
import 'wait_room.dart';

// class MatchState {
//   final List<String> players;
// }

String encodeGameState(GameMatch match) {
  final a = match.board
      .map<List<String?>>((e) => e.map<String?>((e) => e?.name).toList())
      .toList();
  return jsonEncode(
    <String, dynamic>{
      'board': a,
      'turnOf': match.turnOf.name,
      'paused': match.paused,
    },
  );
}

GameMatch decodeGameState(String match) {
  final map = jsonDecode(match) as Map<String, dynamic>;

  return GameMatch(
    board: (map['board'] as List<dynamic>)
        .map(
          (e) => (e as List)
              .map<Player?>((e) => e == null ? null : parsePlayer(e as String))
              .toList(),
        )
        .cast<List<Player?>>()
        .toList(),
    paused: map['paused'] as bool,
    turnOf: parsePlayer(map['turnOf'] as String)!,
  );
}

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({
    Key? key,
    required this.roomName,
    required this.port,
  }) : super(key: key);

  final String roomName;
  final int port;

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  late bool isLoading;
  late Registration? serverServiceRegistration;

  @override
  void initState() {
    super.initState();

    isLoading = true;
    serverServiceRegistration = null;
    _registerService();
  }

  ServerSocket? serverSocket;

  int get _port => widget.port;

  Socket? opponentSocket;
  Stream<Uint8List>? _broadcast;
  String? _opponentName;

  Future<void> _registerService() async {
    final registration = await register(
      Service(
        host: InternetAddress.anyIPv4.address,
        port: _port,
        name: widget.roomName,
        type: kServiceType,
      ),
    );

    // final service = await resolve(registration.service);

    serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, _port);

    serverSocket?.listen((socket) {
      if (opponentSocket != null) {
        socket
          ..write('error:already_in_game')
          ..close();

        return;
      }

      opponentSocket = socket;
      _broadcast = socket.asBroadcastStream();

      print('Connected! ${socket.remoteAddress}');

      socket.write('success:Server Player');

      _broadcast?.map((data) => String.fromCharCodes(data)).listen(
        (message) {
          final parts = message.split(':');

          if (parts[0].startsWith('success')) {
            setState(() {
              _opponentName = parts[1];
            });
          }

          print('Received data: $message');
        },
        onDone: () {
          socket.destroy();
          socket.close();
          opponentSocket?.destroy();
          opponentSocket = null;
          _opponentName = null;
          setState(() {});
        },
      );
    });

    setState(() {
      serverServiceRegistration = registration;
      isLoading = false;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;

    super.setState(fn);
  }

  @override
  void dispose() {
    if (serverServiceRegistration != null) {
      unregister(serverServiceRegistration!);
    }
    opponentSocket?.destroy();
    opponentSocket?.close();
    serverSocket?.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WaitRoom(
      isLoading: isLoading,
      loadingText: 'Creating room',
      players: ['Server Player', if (_opponentName != null) _opponentName!],
      port: '$_port',
      roomName: widget.roomName,
      isClient: false,
      onNext: () {
        opponentSocket!.write('event:start');

        context.push(
          (context) => GameBoard(
            iAmPlayingAs: Player.x,
            myself: 'Server Player',
            opponent: 'Client Player',
            send: (updatedState) =>
                opponentSocket?.write(encodeGameState(updatedState)),
            server: _broadcast!
                .map((bytes) => decodeGameState(String.fromCharCodes(bytes))),
          ),
        );
      },
    );
  }
}
