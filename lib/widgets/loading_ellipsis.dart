import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../theme/time.dart';

class LoadingEllipsis extends HookWidget {
  const LoadingEllipsis(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    const kDots = 5;

    final controller = useAnimationController(duration: k2000ms);
    final dots = '.' * ((useAnimation(controller) * kDots + 1) ~/ 1);

    useEffect(
      () {
        controller.repeat();

        return null;
      },
      const [],
    );

    return Text(
      '$text$dots',
      style: style,
      textAlign: textAlign,
    );
  }
}
