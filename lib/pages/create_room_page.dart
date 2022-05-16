import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nsd/nsd.dart';
import '../const/nsd.dart';
import '../theme/colors.dart';
import '../theme/dp.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/clickable_text.dart';
import '../widgets/loading_ellipsis.dart';

class CreateRoomPage extends HookWidget {
  const CreateRoomPage({Key? key, required this.roomName}) : super(key: key);

  final String roomName;

  @override
  Widget build(BuildContext context) {
    int randomPort() => Random().nextInt(65535 - 1024) + 1024;
    // int randomPort() => 8888;

    final serverServiceRegistration = useState<Registration?>(null);
    final serverService = useState<Service?>(null);
    final isLoading = useState<bool>(true);
    final port = useState(randomPort());
    final serviceName = useState<String>(roomName);
    final clientSockets = useState<Map<String, Socket>>({});
    final clientSocketListeners =
        useState<Map<String, StreamSubscription<String>>>({});
    final serverSocket = useState<ServerSocket?>(null);
    final serverSocketListener = useState<StreamSubscription<Socket>?>(null);
    final service = useMemoized<Service>(
      () => Service(
        name: serviceName.value,
        type: kServiceType,
        port: port.value,
      ),
    );

    useEffect(
      () {
        String mapBytesToString(Uint8List bytes) => String.fromCharCodes(bytes);

        Future<void> registerService() async {
          final registration = await register(service);
          final registeredService = await resolve(registration.service);

          serverSocket.value = await ServerSocket.bind(
            registeredService.host,
            registeredService.port!,
          );

          serverSocketListener.value = serverSocket.value!.listen((socket) {
            final id = socket.remoteAddress.address;

            clientSockets.value = {...clientSockets.value, id: socket};
            clientSocketListeners.value[id] =
                socket.map(mapBytesToString).listen((message) {
              print('Message received: $message');
            });
          });

          serverServiceRegistration.value = registration;
          serverService.value = registeredService;
          isLoading.value = false;
        }

        registerService();

        return () async {
          if (serverServiceRegistration.value != null) {
            await unregister(serverServiceRegistration.value!);
          }

          if (serverSocketListener.value != null) {
            serverSocketListener.value!.cancel();
          }

          if (serverSocket.value != null) {
            await serverSocket.value!.close();
          }

          for (final id in clientSocketListeners.value.keys) {
            clientSocketListeners.value[id]?.cancel();
          }

          for (final socket in clientSockets.value.values) {
            socket.destroy();
          }
        };
      },
      const [],
    );

    Widget buildLoadingIndicator() {
      return Padding(
        padding: k10dp.padding(),
        child: const Center(
          child: LoadingEllipsis(
            'Creating room',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
        ),
      );
    }

    Widget buildRegisteredService() {
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: k20dp.padding(),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const Text(
                    'Your room is ready!',
                    style: TextStyle(
                      fontSize: 18,
                      color: kDisabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: k20dp.symmetric(horizontal: true),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate([
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    border: Border.all(
                      color: kDarkerColor,
                      width: k2dp,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'You',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    border: Border.all(
                      color: kDarkerColor,
                      width: k2dp,
                    ),
                  ),
                  child: const Center(
                    child: LoadingEllipsis(
                      'Waiting opponent',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
              ]),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: k4dp,
                mainAxisSpacing: k4dp,
              ),
            ),
          ),
          SliverPadding(
            padding: k20dp.padding(),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${serverServiceRegistration.value!.service.name?.split('#').first}',
                          style: const TextStyle(
                            fontSize: 26,
                            color: kDarkerColor,
                          ),
                        ),
                        TextSpan(
                          text:
                              '#${serverServiceRegistration.value!.service.name?.split('#').last}',
                          style: const TextStyle(
                            fontSize: 26,
                            color: kDisabledColor,
                          ),
                        ),
                        TextSpan(
                          text:
                              '\nPort: ${serverServiceRegistration.value!.service.port}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: kDisabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.transparent),
                  const Divider(color: Colors.transparent),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: ClickableText(
                      'Next',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return AppScaffold(
      body:
          isLoading.value ? buildLoadingIndicator() : buildRegisteredService(),
    );
  }
}
