import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pixelarticons/pixel.dart';
import '../routing/navigator.dart';
import '../theme/colors.dart';
import '../theme/dp.dart';
import '../widgets/clickable.dart';

class AppScaffold extends HookWidget {
  const AppScaffold({Key? key, required this.body}) : super(key: key);

  final Widget body;

  @override
  Widget build(BuildContext context) {
    final isHovered = useValueNotifier(false);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Clickable(
            padding: EdgeInsets.zero,
            strokeWidth: 0.0,
            onIsHoveredStateChanged: (hovered) => isHovered.value = hovered,
            onTap: () => context.pop(),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AspectRatio(
                aspectRatio: k1p1,
                child: Padding(
                  padding: k20dp.symmetric(horizontal: true),
                  child: AnimatedBuilder(
                    animation: isHovered,
                    builder: (context, child) {
                      return Icon(
                        Pixel.arrowleft,
                        color: isHovered.value ? kHighContrast : kDarkerColor,
                        size: k10dp,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}
