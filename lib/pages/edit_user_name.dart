import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../routing/navigator.dart';
import '../store/user_profile.dart';
import 'full_screen_input_page.dart';

class EditUserName extends HookWidget {
  const EditUserName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FullScreenInputPage(
      buttonText: 'Save',
      defaultName: userName.value,
      labelText: 'Your Name',
      onSubmit: (text, _) async {
        if (text.isNotEmpty) {
          userName.value = text;
          context.pop();
        }
      },
    );
  }
}
