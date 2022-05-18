import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../const/room_names.dart';
import '../pages/create_room_page.dart';
import '../routing/navigator.dart';
import '../theme/colors.dart';
import '../theme/dp.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/clickable_text.dart';

class CreateRoomNamePage extends HookWidget {
  const CreateRoomNamePage({Key? key}) : super(key: key);

  int randomPort() => Random().nextInt(65535 - 1024) + 1024;

  @override
  Widget build(BuildContext context) {
    final defaultName = useState(generateDefaultRoomName());
    final controller = useTextEditingController(text: defaultName.value);
    final port = useState<int>(randomPort());

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
                style: const TextStyle(
                  fontSize: 26,
                ),
                cursorColor: kDarkerColor,
                decoration: InputDecoration(
                  suffix: Text('#${port.value}'),
                  hintText: defaultName.value,
                  labelText: 'ROOM NAME',
                  labelStyle: TextStyle(
                    color: kDarkerColor.withOpacity(.1),
                    fontSize: 18,
                  ),
                  hintStyle: TextStyle(
                    color: kDarkerColor.withOpacity(.2),
                  ),
                  border: InputBorder.none,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    return ClickableText(
                      'Next',
                      disabled: controller.text.length < 3,
                      onTap: () => context.push(
                        (context) => CreateRoomPage(
                          roomName: '${controller.text}#${port.value}',
                          port: port.value,
                        ),
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
