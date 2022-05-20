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
    return Scaffold(
      body: body,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Clickable(
                    padding: k20dp.symmetric(horizontal: true),
                    strokeWidth: 0.0,
                    onTap: () => context.maybePop(),
                    builder: (context, child, isHovered) {
                      return Icon(
                        Pixel.arrowleft,
                        color: isHovered ? kHighContrast : kDarkerColor,
                        size: k10dp,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
