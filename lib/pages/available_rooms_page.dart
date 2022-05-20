import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nsd/nsd.dart';
import '../const/nsd.dart';
import '../routing/navigator.dart';
import '../store/game_match.dart';
import '../store/user_profile.dart';
import '../theme/dp.dart';
import '../theme/typo.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/loading_ellipsis.dart';
import '../widgets/room_list_tile.dart';
import 'game_board.dart';
import 'wait_room.dart';

class AvailableRoomsPage extends HookWidget {
  const AvailableRoomsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading = useState<bool>(true);
    final services = useState<List<Service>>([]);
    final opponentName = useState<String?>(null);
    final isMounted = useIsMounted();

    var inGame = false;

    useEffect(
      () {
        Discovery? discovery;

        void updateServices() => services.value = discovery!.services;

        Future<void> discoveryServices() async {
          discovery = await startDiscovery(kServiceType, autoResolve: false);

          discovery?.addListener(updateServices);

          updateServices();

          isLoading.value = false;
        }

        discoveryServices();

        return () async {
          if (discovery != null) await stopDiscovery(discovery!);

          discovery?.removeListener(updateServices);
          discovery?.dispose();
        };
      },
      const [],
    );

    Widget buildLoadingIndicator() {
      return Container(
        alignment: Alignment.center,
        padding: k20dp.padding(),
        child: const LoadingEllipsis(
          'Discovering services',
          style: kLoadingTxt,
        ),
      );
    }

    Widget buildDiscoveredServices() {
      if (services.value.isEmpty) {
        return Center(
          child: Padding(
            padding: k20dp.padding(),
            child: const LoadingEllipsis(
              'No results found, searching again',
              textAlign: TextAlign.center,
              style: kLoadingTxt,
            ),
          ),
        );
      }

      return ListView.builder(
        itemBuilder: (context, index) {
          final service = services.value[index];
          var popOnExit = false;

          return RoomListTile(
            service: service,
            onTap: () async {
              try {
                final target = await resolve(service);

                final socket = await Socket.connect(
                  target.host,
                  target.port!,
                );

                final broadcast = socket.asBroadcastStream();

                late StreamSubscription<String> sub;

                sub = broadcast
                    .map((bytes) => String.fromCharCodes(bytes))
                    .listen(
                  (message) async {
                    if (message == 'error:already_in_game') {
                      print('Already in game with someone else');
                    } else if (message.startsWith('success')) {
                      final parts = message.split(':');

                      socket.write('success:${userName.value}');

                      opponentName.value = parts[1];

                      popOnExit = true;

                      await context.push(
                        (context) => WaitRoom(
                          isClient: true,
                          players: [parts[1], userName.value],
                          port: '${socket.remotePort}',
                          roomName: target.name,
                          onNext: () => {},
                        ),
                      );

                      popOnExit = false;

                      socket.destroy();
                      socket.close();
                    } else if (message.startsWith('event')) {
                      final parts = message.split(':');

                      final eventCode = parts[1];

                      if (eventCode == 'start') {
                        inGame = true;
                        await context.push(
                          (context) => GameBoard(
                            iAmPlayingAs: Player.o,
                            myself: userName.value,
                            opponent: opponentName.value!,
                            send: (updatedState) =>
                                socket.write(encodeGameState(updatedState)),
                            server: broadcast.map(
                              (bytes) => decodeGameState(
                                String.fromCharCodes(bytes),
                              ),
                            ),
                          ),
                        );
                        inGame = false;
                        socket.write('event:left');
                      } else if (eventCode == 'left') {
                        if (inGame && isMounted()) {
                          context.pop();
                        }
                      }
                    }
                  },
                  onDone: () {
                    if (popOnExit) context.pop();
                    sub.cancel();
                    socket.destroy();
                  },
                );
              } on SocketException catch (e) {
                print('This server is not available: $e');
              }
            },
          );
        },
        itemCount: services.value.length,
      );
    }

    return AppScaffold(
      body:
          isLoading.value ? buildLoadingIndicator() : buildDiscoveredServices(),
    );
  }
}
