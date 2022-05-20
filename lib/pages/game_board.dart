import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

import '../alias/animation_controller.dart';
import '../alias/list.dart';
import '../store/game_match.dart';
import '../theme/colors.dart';
import '../theme/dp.dart';
import '../theme/time.dart';
import '../theme/typo.dart';
import '../widgets/board_painter.dart';
import '../widgets/clickable.dart';
import '../widgets/clickable_text.dart';
import '../widgets/const.dart';
import '../widgets/loading_ellipsis.dart';

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
  List<List<AnimationController>> _createMultiAnimationControllers() {
    return [3, 3].generateMatrix(
      (_, __) => AnimationController(vsync: this, duration: k200ms),
    );
  }

  late List<List<AnimationController>> _boardColorAnimationControllers;
  late List<List<AnimationController>> _boardAnimationControllers;
  late AnimationController _paddingViewSizeAnimationController;
  late ValueNotifier<bool> _isMyTurnIndicatorNotifier;
  late GameMatch _match;
  late StreamSubscription<GameMatch> _subscription;

  Listenable _animationsOf(int i, int j) => Listenable.merge(
        [
          _boardColorAnimationControllers[i][j],
          _boardAnimationControllers[i][j],
          _paddingViewSizeAnimationController,
          _isMyTurnIndicatorNotifier,
        ],
      );

  @override
  void initState() {
    super.initState();

    _match = widget.initialMatch ?? GameMatch();

    _boardColorAnimationControllers = _createMultiAnimationControllers();
    _boardAnimationControllers = _createMultiAnimationControllers();
    _paddingViewSizeAnimationController =
        AnimationController(vsync: this, duration: k200ms);
    _isMyTurnIndicatorNotifier =
        ValueNotifier(widget.iAmPlayingAs == _match.turnOf);

    _subscription = widget.server.listen((updatedMatch) {
      setState(() => _match = updatedMatch);
      _syncAnimationsWithCurrentMatchState();
    });
  }

  void _syncAnimationsWithCurrentMatchState() {
    _isMyTurnIndicatorNotifier.value = widget.iAmPlayingAs == _match.turnOf;

    [3, 3].through((i, j) {
      if (_match.board[i][j] == null) {
        _boardAnimationControllers[i][j].reset();
        _boardColorAnimationControllers[i][j].reset();
      } else {
        _boardAnimationControllers[i][j]
            .forward(from: _boardAnimationControllers[i][j].value);

        if (_match.isComplete) {
          if (_match.isDraw) {
            [3, 3].through((i, j) {
              _boardColorAnimationControllers[i][j].forward(
                from: _boardColorAnimationControllers[i][j].value,
              );
            });
          } else {
            for (final cell in _match.winnerCells!) {
              _boardColorAnimationControllers[cell.first][cell.last].forward(
                from: _boardColorAnimationControllers[cell.first][cell.last]
                    .value,
              );
            }
          }
        }
      }
    });
  }

  void _byExitMatch() {
    Navigator.maybePop(context);
  }

  @override
  void dispose() {
    [3, 3].through((i, j) {
      _boardColorAnimationControllers[i][j].dispose();
      _boardAnimationControllers[i][j].dispose();
    });

    _paddingViewSizeAnimationController.dispose();
    _isMyTurnIndicatorNotifier.dispose();

    _subscription.cancel();

    super.dispose();
  }

  double _applyCurve(AnimationController controller) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    return animation.value;
  }

  void _byRestartMatch() {
    _match = GameMatch();
    setState(() {});
    _syncAnimationsWithCurrentMatchState();
    widget.send(_match);
  }

  void _byPlayAt(int i, int j) {
    final isValidMove = _match.play(i, j, player: widget.iAmPlayingAs);

    if (isValidMove) {
      widget.send(_match);

      _syncAnimationsWithCurrentMatchState();
      setState(() {});
    }
  }

  Widget _buildPlayerName(
    String name, {
    required bool winner,
    required bool itsHisTurn,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: winner ? kDarkerColor : kHighContrast,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: k20dp),
          child: LoadingEllipsis(
            name,
            enabled: itsHisTurn,
            style: kFullScreenTextFieldTxt.copyWith(
              color: winner ? kHighContrast : kDarkerColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayAgainButton() {
    return Padding(
      padding: const EdgeInsets.all(k20dp),
      child: IgnorePointer(
        ignoring: !_match.isComplete,
        child: AnimatedOpacity(
          duration: k500ms,
          curve: Curves.easeInOut,
          opacity: _match.isComplete ? 1 : 0,
          child: ClickableText(
            'Play Again',
            onTap: _byRestartMatch,
          ),
        ),
      ),
    );
  }

  Widget _buildBoardCell(int i, int j) {
    return GestureDetector(
      onTap: () => _byPlayAt(i, j),
      child: AnimatedBuilder(
        animation: _animationsOf(i, j),
        builder: (context, child) {
          final colorAnimation =
              _applyCurve(_boardColorAnimationControllers[i][j]);

          final cross = _match.board[i][j] == Player.x;

          final padding =
              (k10dp * _applyCurve(_paddingViewSizeAnimationController) + k2dp)
                  .padding();

          return ColoredBox(
            color: Color.lerp(
              kHighContrast,
              kDarkerColor,
              colorAnimation,
            )!,
            child: Padding(
              padding: padding,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: BoardPainter(
                    cross: cross,
                    value: _applyCurve(_boardAnimationControllers[i][j]),
                    highlight: colorAnimation,
                    indicateTurn:
                        _isMyTurnIndicatorNotifier.value && !_match.isComplete,
                    clip: cross ||
                        !_paddingViewSizeAnimationController
                            .isForwardOrComplete(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackArrow() {
    return Row(
      children: [
        Clickable(
          padding: k20dp.symmetric(horizontal: true),
          onTap: _byExitMatch,
          strokeWidth: 0.0,
          builder: (context, child, isHovered) {
            return Icon(
              Pixel.arrowleft,
              color: isHovered ? kHighContrast : kDarkerColor,
            );
          },
        ),
      ],
    );
  }

  void _byTogglePaddingSizeView() {
    if (_paddingViewSizeAnimationController.isForwardOrComplete()) {
      _paddingViewSizeAnimationController.reverse(
        from: _paddingViewSizeAnimationController.value,
      );
    } else {
      _paddingViewSizeAnimationController.forward(
        from: _paddingViewSizeAnimationController.value,
      );
    }
  }

  Widget _buildPaddingSizeViewButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _paddingViewSizeAnimationController,
          builder: (context, child) {
            return Clickable(
              padding: k20dp.symmetric(horizontal: true),
              onTap: _byTogglePaddingSizeView,
              strokeWidth: 0.0,
              builder: (context, child, isHovered) {
                return Icon(
                  _paddingViewSizeAnimationController.isForwardOrComplete()
                      ? Pixel.viewportnarrow
                      : Pixel.viewportwide,
                  color: isHovered ? kHighContrast : kDarkerColor,
                );
              },
            );
          },
        ),
      ],
    );
  }

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
              _buildBackArrow(),
              _buildPaddingSizeViewButton(),
            ],
          ),
        ),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            _buildPlayerName(
              widget.opponent,
              winner: _match.hasWinner &&
                  _match.winner == widget.iAmPlayingAs.opposite(),
              itsHisTurn: !_match.isComplete &&
                  _match.turnOf == widget.iAmPlayingAs.opposite(),
            ),
            kTransparentDivider,
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
                  children: [3, 3]
                      .generateMatrix((i, j) => _buildBoardCell(i, j))
                      .rflatten<Widget>()
                      .toList(),
                ),
              ),
            ),
            kTransparentDivider,
            _buildPlayerName(
              widget.myself,
              winner: _match.hasWinner && _match.winner == widget.iAmPlayingAs,
              itsHisTurn:
                  !_match.isComplete && _match.turnOf == widget.iAmPlayingAs,
            ),
            _buildPlayAgainButton(),
          ],
        ),
      ),
    );
  }
}
