import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../widgets/clickable_text.dart';

class MenuButton extends HookWidget {
  const MenuButton(
    this.text, {
    Key? key,
    this.onTap,
    this.disabled = false,
  }) : super(key: key);

  final String text;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) =>
      ClickableText(text, onTap: onTap, disabled: disabled);
}
