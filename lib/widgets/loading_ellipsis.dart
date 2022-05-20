import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../theme/time.dart';

class LoadingEllipsis extends HookWidget {
  const LoadingEllipsis(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.dots = 5,
    this.enabled = true,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int dots;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: k2000ms);
    final ellipsis = '.' * ((useAnimation(controller) * dots + 1) ~/ 1);

    useEffect(
      () {
        controller.repeat();

        return null;
      },
      const [],
    );

    return Text(
      '$text${enabled ? ellipsis : ''}',
      style: style,
      textAlign: textAlign,
    );
  }
}
