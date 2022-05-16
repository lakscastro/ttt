import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../theme/colors.dart';
import '../theme/dp.dart';
import '../theme/time.dart';

class Clickable extends HookWidget {
  const Clickable({
    Key? key,
    this.onTap,
    required this.child,
    this.onIsHoveredStateChanged,
    this.onHoverAnimationChanged,
    this.disabled = false,
    this.strokeWidth = k2dp,
    this.padding = const EdgeInsets.symmetric(horizontal: k8dp),
  }) : super(key: key);

  final Widget child;
  final VoidCallback? onTap;
  final void Function(bool)? onIsHoveredStateChanged;
  final void Function(double)? onHoverAnimationChanged;
  final bool disabled;
  final double strokeWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final hoverController = useAnimationController(duration: k0ms);

    useEffect(
      () {
        onHoverAnimationChanged?.call(hoverController.value);

        return null;
      },
      [hoverController.value],
    );

    useEffect(
      () {
        onIsHoveredStateChanged?.call(
          hoverController.status == AnimationStatus.forward ||
              hoverController.status == AnimationStatus.completed,
        );

        return null;
      },
      [hoverController.status],
    );

    void hovered() => hoverController.forward();
    void notHovered() => hoverController.reverse();

    void byOnPointerDown(PointerDownEvent event) {
      if (!disabled) hovered();
    }

    void byOnPointerCancel(PointerCancelEvent event) {
      if (!disabled) notHovered();
    }

    void byOnPointerUp(PointerUpEvent event) {
      if (disabled) return;

      final renderBox = context.findRenderObject() as RenderBox?;

      notHovered();

      if (renderBox == null) return;

      final position = renderBox.localToGlobal(Offset.zero);

      final inBoundaries = event.position.dx >= position.dx &&
          event.position.dx <= position.dx + renderBox.size.width &&
          event.position.dy >= position.dy &&
          event.position.dy <= position.dy + renderBox.size.height;

      if (inBoundaries) {
        onTap?.call();
      }
    }

    return Listener(
      onPointerDown: byOnPointerDown,
      onPointerCancel: byOnPointerCancel,
      onPointerUp: byOnPointerUp,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled
              ? Colors.transparent
              : Color.lerp(
                  kDarkerColor,
                  kHighContrast,
                  1 - useAnimation(hoverController),
                ),
          border: strokeWidth == 0
              ? null
              : Border.all(
                  color: disabled ? kDisabledColor : kDarkerColor,
                  width: strokeWidth,
                ),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
