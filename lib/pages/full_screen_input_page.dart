import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../theme/colors.dart';
import '../theme/dp.dart';
import '../theme/typo.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/clickable_text.dart';

class FullScreenInputPage extends HookWidget {
  const FullScreenInputPage({
    Key? key,
    this.generatePort = false,
    required this.onSubmit,
    required this.labelText,
    this.defaultName,
    required this.buttonText,
  }) : super(key: key);

  final bool generatePort;
  final Function(String, int) onSubmit;
  final String labelText;
  final String? defaultName;
  final String buttonText;

  int _randomPort() => Random().nextInt(65535 - 1024) + 1024;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: defaultName);
    final port = useState<int>(_randomPort());

    return AppScaffold(
      body: Padding(
        padding: k20dp.padding(),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_ ]'))
                ],
                style: kFullScreenTextFieldTxt,
                cursorColor: kDarkerColor,
                decoration: InputDecoration(
                  suffix: generatePort ? Text('#${port.value}') : null,
                  hintText: defaultName,
                  labelText: labelText,
                  labelStyle: kFullScreenTextFieldLabelTxt,
                  hintStyle: kFullScreenTextFieldHintTxt,
                  border: InputBorder.none,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    return ClickableText(
                      buttonText,
                      disabled: controller.text.length < 3,
                      onTap: () => onSubmit(
                        controller.text,
                        port.value,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
