import 'package:flutter/material.dart';

extension Navigation on BuildContext {
  Future<T?> push<T extends Object>(WidgetBuilder builder) {
    return Navigator.push<T>(
      this,
      PageRouteBuilder(
        pageBuilder: (context, __, ___) => builder(context),
        transitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    );
  }

  void pop<T extends Object>([T? result]) {
    return Navigator.pop<T>(this, result);
  }

  Future<void> maybePop<T extends Object>([T? result]) {
    return Navigator.maybePop<T>(this, result);
  }
}
