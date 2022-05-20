import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nsd/nsd.dart';

import '../const/nsd.dart';
import '../routing/navigator.dart';
import '../store/game_match.dart';
import '../store/user_profile.dart';
import 'game_board.dart';
import 'wait_room.dart';

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
  late bool _isLoading;
  late Registration? _serverServiceRegistration;

  @override
  void initState() {
    super.initState();

    _isLoading = true;
    _serverServiceRegistration = null;
    _registerService();
  }

  ServerSocket? _serverSocket;

  int get _port => widget.port;

  Socket? _opponentSocket;
  Stream<Uint8List>? _broadcast;
  String? _opponentName;

  String messageError = 'Creating room';

  Future<void> _registerService() async {
    try {
      final registration = await register(
        Service(
          host: InternetAddress.anyIPv4.address,
          port: _port,
          name: widget.roomName,
          type: kServiceType,
        ),
      );

      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, _port);

      _serverSocket?.listen((socket) {
        if (_opponentSocket != null) {
          socket
            ..write('error:already_in_game')
            ..close();
        } else {
          _opponentSocket = socket;
          _broadcast = socket.asBroadcastStream();

          socket.write('success:${userName.value}');

          _broadcast?.map((data) => String.fromCharCodes(data)).listen(
            (message) {
              if (_disposed) return;
              final parts = message.split(':');

              if (parts[0].startsWith('success')) {
                setState(() => _opponentName = parts[1]);
              } else if (parts[0].startsWith('event')) {
                if (parts[1].startsWith('left')) {
                  if (_inGame) {
                    context.pop();
                  }
                }
              }
            },
            onDone: () {
              if (_disposed) return;
              socket.destroy();
              socket.close();
              _opponentSocket?.destroy();
              _opponentSocket = null;
              _opponentName = null;
              setState(() {});
            },
          );
        }
      });
      setState(() {
        _serverServiceRegistration = registration;
        _isLoading = false;
      });
    } catch (e) {
      messageError = e.toString();
      setState(() {});
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;

    super.setState(fn);
  }

  var _disposed = false;
  var _inGame = false;

  @override
  void dispose() {
    _disposed = true;
    if (_serverServiceRegistration != null) {
      unregister(_serverServiceRegistration!);
    }
    _opponentSocket?.destroy();
    _opponentSocket?.close();
    _serverSocket?.close();
    _opponentSocket = null;
    _opponentName = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: userName,
      builder: (context, child) {
        return WaitRoom(
          isLoading: _isLoading,
          loadingText: messageError,
          players: [userName.value, if (_opponentName != null) _opponentName!],
          port: '$_port',
          roomName: widget.roomName,
          isClient: false,
          onNext: () async {
            _opponentSocket!.write('event:start');

            _inGame = true;
            await context.push(
              (context) => GameBoard(
                iAmPlayingAs: Player.x,
                myself: userName.value,
                opponent: _opponentName!,
                send: (updatedState) =>
                    _opponentSocket?.write(encodeGameState(updatedState)),
                server: _broadcast!.map(
                  (bytes) => decodeGameState(
                    String.fromCharCodes(bytes),
                  ),
                ),
              ),
            );
            _inGame = false;
            _opponentSocket?.write('event:left');
          },
        );
      },
    );
  }
}
