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
    return Clickable(
      onTap: onTap,
      disabled: disabled,
      builder: (context, child, isHovered) {
        return Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 26,
              color: disabled
                  ? kDisabledColor
                  : isHovered
                      ? kHighContrast
                      : kDarkerColor,
            ),
          ),
        );
      },
    );
  }
}
