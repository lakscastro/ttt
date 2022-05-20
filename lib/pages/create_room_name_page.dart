import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../const/room_names.dart';
import '../pages/create_room_page.dart';
import '../routing/navigator.dart';
import 'full_screen_input_page.dart';

class CreateRoomNamePage extends HookWidget {
  const CreateRoomNamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultName = useState(generateDefaultRoomName());

    return FullScreenInputPage(
      defaultName: defaultName.value,
      buttonText: 'Next',
      labelText: 'Room Name',
      onSubmit: (text, port) => context.push(
        (context) => CreateRoomPage(
          roomName: '$text#$port',
          port: port,
        ),
      ),
    );
  }
}
