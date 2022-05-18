import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:ttt/theme/colors.dart';
import 'package:ttt/theme/dp.dart';
import 'package:ttt/widgets/clickable_text.dart';

import '../store/game_match.dart';
import '../theme/time.dart';
import '../widgets/clickable.dart';
import '../widgets/loading_ellipsis.dart';
import 'create_room_page.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({
    Key? key,
    required this.myself,
    required this.opponent,
    required this.server,
    required this.send,
    this.initialMatch,
    required this.iAmPlayingAs,
  }) : super(key: key);

  final String myself;
  final String opponent;
  final void Function(GameMatch) send;
  final Stream<GameMatch> server;
  final GameMatch? initialMatch;
  final Player iAmPlayingAs;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  List<List<AnimationController>> createMultiAnimationControllers() {
    return [
      for (var i = 0; i < 3; i++)
        [
          for (var j = 0; j < 3; j++)
            AnimationController(vsync: this, duration: k200ms)
        ]
    ];
  }

  late List<List<AnimationController>> _boardColorAnimationState;
  late List<List<AnimationController>> _boardAnimationState;
  late AnimationController _boxPadding;
  late ValueNotifier<bool> _isMyTurnIndicator;
  late GameMatch _match;
  late StreamSubscription<GameMatch> _subscription;

  @override
  void initState() {
    super.initState();

    _boardColorAnimationState = createMultiAnimationControllers();
    _boardAnimationState = createMultiAnimationControllers();
    _boxPadding = AnimationController(vsync: this, duration: k200ms);
    _match = widget.initialMatch ?? GameMatch();
    _isMyTurnIndicator = ValueNotifier(widget.iAmPlayingAs == _match.turnOf);
    _subscription = widget.server.listen((updatedMatch) {
      setState(() {
        _match = updatedMatch;
      });
      _verifyGame();
    });
  }

  void _verifyGame() {
    _isMyTurnIndicator.value = widget.iAmPlayingAs == _match.turnOf;

    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        if (_match.board[i][j] == null) {
          _boardAnimationState[i][j].reset();
          _boardColorAnimationState[i][j].reset();
          continue;
        }

        _boardAnimationState[i][j]
            .forward(from: _boardAnimationState[i][j].value);

        if (_match.isComplete) {
          if (_match.isDraw) {
            for (var i = 0; i < 3; i++) {
              for (var j = 0; j < 3; j++) {
                _boardColorAnimationState[i][j].forward(
                  from: _boardColorAnimationState[i][j].value,
                );
              }
            }
          } else {
            for (final cell in _match.winnerCells!) {
              _boardColorAnimationState[cell.first][cell.last].forward(
                from: _boardColorAnimationState[cell.first][cell.last].value,
              );
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        _boardColorAnimationState[i][j].dispose();
        _boardAnimationState[i][j].dispose();
      }
    }
    _boxPadding.dispose();
    _isMyTurnIndicator.dispose();

    _subscription.cancel();

    super.dispose();
  }

  bool isBoxAnimationComplete() =>
      _boxPadding.status == AnimationStatus.completed ||
      _boxPadding.status == AnimationStatus.forward;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kHighContrast,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _boxPadding,
                    builder: (context, child) {
                      return Clickable(
                        padding: k20dp.symmetric(horizontal: true),
                        onTap: () {
                          Navigator.maybePop(context);
                        },
                        strokeWidth: 0.0,
                        builder: (context, child, isHovered) {
                          return Icon(
                            Pixel.arrowleft,
                            color: isHovered ? kHighContrast : kDarkerColor,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedBuilder(
                    animation: _boxPadding,
                    builder: (context, child) {
                      return Clickable(
                        padding: k20dp.symmetric(horizontal: true),
                        onTap: () {
                          if (_boxPadding.status == AnimationStatus.completed ||
                              _boxPadding.status == AnimationStatus.forward) {
                            _boxPadding.reverse(from: _boxPadding.value);
                          } else {
                            _boxPadding.forward(from: _boxPadding.value);
                          }
                        },
                        strokeWidth: 0.0,
                        builder: (context, child, isHovered) {
                          return Icon(
                            !isBoxAnimationComplete()
                                ? Pixel.viewportnarrow
                                : Pixel.viewportwide,
                            color: isHovered ? kHighContrast : kDarkerColor,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: k10dp),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _match.winner != null &&
                          _match.winner != widget.iAmPlayingAs
                      ? kDarkerColor
                      : kHighContrast,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: k20dp),
                    child: _match.turnOf != widget.iAmPlayingAs &&
                            !_match.isComplete
                        ? LoadingEllipsis(
                            widget.opponent,
                            style: TextStyle(
                              fontSize: 26,
                              color: _match.winner != null &&
                                      _match.winner != widget.iAmPlayingAs
                                  ? kHighContrast
                                  : kDarkerColor,
                            ),
                          )
                        : Text(
                            widget.opponent,
                            style: TextStyle(
                              fontSize: 26,
                              color: _match.winner != null &&
                                      _match.winner != widget.iAmPlayingAs
                                  ? kHighContrast
                                  : kDarkerColor,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: k20dp),
              child: DecoratedBox(
                decoration: const BoxDecoration(color: kDarkerColor),
                child: GridView(
                  padding: const EdgeInsets.all(k5dp),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: k5dp,
                    mainAxisSpacing: k5dp,
                  ),
                  shrinkWrap: true,
                  children: [
                    for (var i = 0; i < 3; i++)
                      for (var j = 0; j < 3; j++)
                        GestureDetector(
                          onTap: () {
                            if (_match.board[i][j] != null) {
                              return;
                            }

                            if (_match.play(i, j,
                                player: widget.iAmPlayingAs)) {
                              widget.send(_match);
                            }

                            _verifyGame();
                            setState(() {});
                          },
                          child: AnimatedBuilder(
                            animation: Listenable.merge(
                              [
                                _boardColorAnimationState[i][j],
                                _boardAnimationState[i][j],
                                _boxPadding,
                                _isMyTurnIndicator,
                              ],
                            ),
                            builder: (context, child) {
                              final boxPaddingAnimation = CurvedAnimation(
                                parent: _boxPadding,
                                curve: Curves.easeInOut,
                              );

                              final animation = CurvedAnimation(
                                parent: _boardAnimationState[i][j],
                                curve: Curves.easeInOut,
                              );
                              final colorAnimation = CurvedAnimation(
                                parent: _boardColorAnimationState[i][j],
                                curve: Curves.easeInOut,
                              );

                              final cross = _match.board[i][j] == Player.x;

                              return ColoredBox(
                                color: Color.lerp(
                                  kHighContrast,
                                  kDarkerColor,
                                  colorAnimation.value,
                                )!,
                                child: Padding(
                                  padding:
                                      (k10dp * boxPaddingAnimation.value + k2dp)
                                          .padding(),
                                  child: RepaintBoundary(
                                    child: CustomPaint(
                                      painter: _ShapePainter(
                                        cross: cross,
                                        value: animation.value,
                                        highlight: colorAnimation.value,
                                        dot: _isMyTurnIndicator.value &&
                                            !_match.isComplete,
                                        clip:
                                            cross || !isBoxAnimationComplete(),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: k10dp),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _match.winner == widget.iAmPlayingAs
                      ? kDarkerColor
                      : kHighContrast,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: k20dp),
                  child:
                      _match.turnOf == widget.iAmPlayingAs && !_match.isComplete
                          ? LoadingEllipsis(
                              widget.myself,
                              style: TextStyle(
                                fontSize: 26,
                                color: _match.winner == widget.iAmPlayingAs
                                    ? kHighContrast
                                    : kDarkerColor,
                              ),
                            )
                          : Text(
                              widget.myself,
                              style: TextStyle(
                                fontSize: 26,
                                color: _match.winner == widget.iAmPlayingAs
                                    ? kHighContrast
                                    : kDarkerColor,
                              ),
                            ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(k20dp),
              child: IgnorePointer(
                ignoring: !_match.isComplete,
                child: AnimatedOpacity(
                  duration: k500ms,
                  curve: Curves.easeInOut,
                  opacity: _match.isComplete ? 1 : 0,
                  child: ClickableText(
                    'Play Again',
                    onTap: () {
                      _match = GameMatch();
                      setState(() {});
                      _verifyGame();
                      widget.send(_match);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  const _ShapePainter({
    required this.cross,
    required this.value,
    required this.clip,
    required this.highlight,
    required this.dot,
  });

  final double value;
  final bool clip;
  final bool cross;
  final double highlight;
  final bool dot;

  static const k3d = k6dp;

  void _paintCross(Canvas canvas, Size size) {
    if (clip) {
      canvas.clipRect(
        Rect.fromLTRB(
          k5dp / 2,
          k5dp / 2,
          size.width - k5dp / 2,
          size.height - k5dp / 2,
        ),
      );
    }

    final v = value * 2;

    final start = min(v, 1);
    final end = v - start;

    final paint = Paint()
      ..color = Color.lerp(kDarkerColor, kHighContrast, highlight)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = k5dp;

    final shadow = Paint()
      ..color = Color.lerp(kDisabledColor, Colors.transparent, highlight)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = k5dp;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * start, size.height * start)
      ..moveTo(0, size.height)
      ..lineTo(size.width * end, size.height - size.height * end);

    canvas.translate(k3d, k3d);
    canvas.drawPath(path, shadow);
    canvas.translate(-k3d, -k3d);
    canvas.drawPath(path, paint);
  }

  void _paintCircle(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.lerp(kDarkerColor, kHighContrast, highlight)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = k5dp;

    final shadow = Paint()
      ..color = Color.lerp(kDisabledColor, Colors.transparent, highlight)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = k5dp;

    final path = Path()
      ..addArc(
        Rect.fromLTWH(
          k5dp / 2,
          k5dp / 2,
          size.width - k5dp,
          size.height - k5dp,
        ),
        0,
        2 * pi * value,
      );

    canvas.save();
    canvas.clipRRect(
      RRect.fromLTRBR(
        k5dp / 2,
        k5dp / 2,
        size.width - k5dp,
        size.height - k5dp,
        Radius.circular(size.width / 2 - k5dp),
      ),
    );
    canvas.translate(k3d, k3d);
    canvas.drawPath(path, shadow);
    canvas.translate(-k3d, -k3d);
    canvas.restore();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (cross) {
      _paintCross(canvas, size);
    } else {
      _paintCircle(canvas, size);
    }

    if (dot) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width / 2 * (1 - value),
          height: size.height / 2 * (1 - value),
        ),
        Paint()
          ..color = kAlmostTransparent
          ..style = PaintingStyle.stroke
          ..strokeWidth = k1dp,
      );
    }
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) =>
      oldDelegate.cross != cross ||
      oldDelegate.value != value ||
      oldDelegate.clip != clip ||
      oldDelegate.highlight != highlight ||
      oldDelegate.dot != dot;
}
