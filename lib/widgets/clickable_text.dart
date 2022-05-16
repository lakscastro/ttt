import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../theme/colors.dart';
import '../widgets/clickable.dart';

class ClickableText extends HookWidget {
  const ClickableText(
    this.text, {
    Key? key,
    this.onTap,
    this.disabled = false,
  }) : super(key: key);

  final String text;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final hoverAnimation = useValueNotifier<double>(0);

    return Clickable(
      onHoverAnimationChanged: (value) => hoverAnimation.value = value,
      onTap: onTap,
      disabled: disabled,
      child: AnimatedBuilder(
        animation: hoverAnimation,
        builder: (context, child) {
          return Text(
            text,
            style: TextStyle(
              fontSize: 26,
              color: disabled
                  ? kDisabledColor
                  : Color.lerp(
                      kDarkerColor,
                      kHighContrast,
                      hoverAnimation.value,
                    ),
            ),
          );
        },
      ),
    );
  }
}
