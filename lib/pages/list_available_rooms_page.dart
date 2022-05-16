import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nsd/nsd.dart';
import 'package:pixelarticons/pixel.dart';
import '../const/nsd.dart';
import '../theme/colors.dart';
import '../theme/dp.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/clickable.dart';
import '../widgets/loading_ellipsis.dart';

class ListAvailableRoomsPage extends HookWidget {
  const ListAvailableRoomsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading = useState<bool>(true);
    final services = useState<List<Service>>([]);

    useEffect(
      () {
        Discovery? discovery;

        void updateServices() => services.value = discovery!.services;

        Future<void> discoveryServices() async {
          discovery = await startDiscovery(kServiceType);

          discovery?.addListener(updateServices);

          updateServices();

          isLoading.value = false;
        }

        discoveryServices();

        return () => discovery?.removeListener(updateServices);
      },
      const [],
    );

    Widget buildLoadingIndicator() {
      return const Center(
        child: LoadingEllipsis(
          'Discovering services',
          style: TextStyle(fontSize: k10dp),
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
              style: TextStyle(
                fontSize: k10dp,
                color: kDarkerColor,
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        itemBuilder: (context, index) {
          final service = services.value[index];

          return ServiceTile(
            service: service,
            onTap: () async {
              final target = await resolve(service);

              final connection =
                  await Socket.startConnect(target.host, target.port!);

              final socket = await connection.socket;

              print([target.host, target.port!]);

              socket.write('hey from here');
              late StreamSubscription<String> sub;

              sub = socket.map((bytes) => String.fromCharCodes(bytes)).listen(
                (message) {
                  print('CLIENT message: $message');
                },
                onDone: () => {print('CLIENT DONE!!'), sub.cancel()},
              );
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

class ServiceTile extends HookWidget {
  const ServiceTile({
    Key? key,
    required this.service,
    required this.onTap,
  }) : super(key: key);

  final Service service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isHovered = useValueNotifier<bool>(false);

    return Clickable(
      onIsHoveredStateChanged: (hover) => isHovered.value = hover,
      strokeWidth: 0.0,
      child: ListTile(
        onTap: onTap,
        title: AnimatedBuilder(
          animation: isHovered,
          builder: (context, child) {
            return Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: service.name!.split('#').first,
                    style: TextStyle(
                      color: isHovered.value ? kHighContrast : kDarkerColor,
                      fontSize: k10dp,
                    ),
                  ),
                  TextSpan(
                    text: '#${service.name!.split('#').last}',
                    style: const TextStyle(
                      color: kDisabledColor,
                      fontSize: k10dp,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        leading: AnimatedBuilder(
          animation: isHovered,
          builder: (context, child) {
            return Icon(
              Pixel.devices,
              color: isHovered.value ? kHighContrast : kDarkerColor,
              size: k5dp * 3,
            );
          },
        ),
      ),
    );
  }
}
