import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/create_room_name_page.dart';
import 'pages/list_available_rooms_page.dart';
import 'routing/navigator.dart';
import 'theme/colors.dart';
import 'theme/dp.dart';
import 'theme/time.dart';
import 'theme/typo.dart';
import 'widgets/menu_button.dart';
import 'widgets/no_glow.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: kHighContrast,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: kHighContrast,
    ),
  );

  runApp(const TicTacApp());
}

class TicTacApp extends StatelessWidget {
  const TicTacApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.light().copyWith();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: NoGlow(),
          child: child!,
        );
      },
      title: 'Tic Tac Toe',
      theme: theme.copyWith(
        scaffoldBackgroundColor: Colors.white,
        textTheme: theme.textTheme.apply(
          fontFamily: kFontFamily,
          bodyColor: kDarkerColor,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: k5dp.padding(),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Divider(color: Colors.transparent),
              const Divider(color: Colors.transparent),
              const Text(
                'TIC\nTAC\nTOE\n',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: k20dp,
                  fontFamily: 'Crackman',
                ),
              ),
              const MenuButton(
                'Set your name',
                color: Colors.grey,
              ),
              const Divider(color: Colors.transparent),
              MenuButton(
                'Create room',
                color: Colors.grey,
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: k0ms,
                    reverseTransitionDuration: k0ms,
                    pageBuilder: (_, __, ___) => const CreateRoomNamePage(),
                    transitionsBuilder: (_, animation, ___, child) => child,
                  ),
                ),
              ),
              const Divider(color: Colors.transparent),
              MenuButton(
                'Join room',
                color: Colors.grey,
                onTap: () =>
                    context.push((context) => const ListAvailableRoomsPage()),
              ),
              const Divider(color: Colors.transparent),
              const MenuButton(
                'Multiplayer (Soon!)',
                color: Colors.grey,
                disabled: true,
              ),
            ].map((e) => Center(child: e)).toList(),
          ),
        ),
      ),
    );
  }
}
