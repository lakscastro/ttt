import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nsd/nsd.dart';
import 'package:pixelarticons/pixel.dart';
import '../const/nsd.dart';
import '../routing/navigator.dart';
import '../store/game_match.dart';
import '../theme/colors.dart';
import '../theme/dp.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/clickable_text.dart';
import '../widgets/loading_ellipsis.dart';
import 'game_board.dart';

class WaitRoom extends StatefulWidget {
  const WaitRoom({
    Key? key,
    this.roomName,
    this.port,
    this.isLoading = false,
    this.loadingText,
    this.players = const [],
    required this.isClient,
    required this.onNext,
  }) : super(key: key);

  final String? roomName;
  final String? port;
  final String? loadingText;
  final bool isLoading;
  final List<String> players;
  final bool isClient;
  final VoidCallback onNext;

  @override
  State<WaitRoom> createState() => _WaitRoomState();
}

class _WaitRoomState extends State<WaitRoom> {
  Widget _buildPlayerText(String Function() playerName) {
    try {
      return Text(
        playerName(),
        style: const TextStyle(
          fontSize: 24,
        ),
      );
    } on RangeError {
      return const LoadingEllipsis(
        'Waiting opponent',
        style: TextStyle(
          fontSize: 24,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildLoadingIndicator() {
      return Padding(
        padding: k10dp.padding(),
        child: Center(
          child: LoadingEllipsis(
            widget.loadingText!,
            style: const TextStyle(
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
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Pixel.close),
                    title: _buildPlayerText(() => widget.players[0]),
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Pixel.circle),
                    title: _buildPlayerText(() => widget.players[1]),
                  ),
                ],
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
                          text: '${widget.roomName?.split('#').first}',
                          style: const TextStyle(
                            fontSize: 26,
                            color: kDarkerColor,
                          ),
                        ),
                        TextSpan(
                          text: '#${widget.roomName?.split('#').last}',
                          style: const TextStyle(
                            fontSize: 26,
                            color: kDisabledColor,
                          ),
                        ),
                        TextSpan(
                          text: '\nPort: ${widget.port}',
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
                  if (!widget.isClient)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ClickableText(
                        'Next',
                        disabled: widget.players.length != 2,
                        onTap: widget.onNext,
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
          widget.isLoading ? buildLoadingIndicator() : buildRegisteredService(),
    );
  }
}
