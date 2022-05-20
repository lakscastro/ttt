import 'package:flutter/animation.dart';

extension AnimationControllerAlias on AnimationController {
  bool isForwardOrComplete() =>
      status == AnimationStatus.completed || status == AnimationStatus.forward;
}
