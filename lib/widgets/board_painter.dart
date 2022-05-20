import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../theme/colors.dart';
import '../theme/dp.dart';

class BoardPainter extends CustomPainter {
  const BoardPainter({
    required this.cross,
    required this.value,
    required this.clip,
    required this.highlight,
    required this.indicateTurn,
  });

  final double value;
  final bool clip;
  final bool cross;
  final double highlight;
  final bool indicateTurn;

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
      ..color = Color.lerp(kLightColor, kTransparent, highlight)!
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
      ..color = Color.lerp(kLightColor, kTransparent, highlight)!
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

  void _paintTurnIndicator(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width / 2 * (1 - value),
        height: size.height / 2 * (1 - value),
      ),
      Paint()
        ..color = kLightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = k1dp,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (cross) {
      _paintCross(canvas, size);
    } else {
      _paintCircle(canvas, size);
    }

    if (indicateTurn) {
      _paintTurnIndicator(canvas, size);
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) =>
      oldDelegate.cross != cross ||
      oldDelegate.value != value ||
      oldDelegate.clip != clip ||
      oldDelegate.highlight != highlight ||
      oldDelegate.indicateTurn != indicateTurn;
}
