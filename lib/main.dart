import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/available_rooms_page.dart';
import 'pages/create_room_name_page.dart';
import 'pages/edit_user_name.dart';
import 'routing/navigator.dart';
import 'store/user_profile.dart';
import 'theme/colors.dart';
import 'theme/dp.dart';
import 'theme/typo.dart';
import 'widgets/const.dart';
import 'widgets/menu_button.dart';
import 'widgets/no_glow.dart';

Future<void> _setupUserProfileStore() async {
  userName = ValueNotifier(await getUserName());
  var previousName = userName.value;

  userName.addListener(() async {
    if (userName.value != previousName) {
      previousName = userName.value;
      await setUserName(userName.value);
    }
  });
}

Future<void> setupDependencies() async {
  await _setupUserProfileStore();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

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
        scaffoldBackgroundColor: kHighContrast,
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

  void _byOpenCreateRoomPage() =>
      context.push((context) => const CreateRoomNamePage());

  void _byOpenServerListPage() =>
      context.push((context) => const AvailableRoomsPage());

  void _byOpenEditProfilePage() =>
      context.push((context) => const EditUserName());

  Widget _buildLogo() =>
      const Center(child: Text('Tic\nTac\nToe\n', style: kLogoTxt));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kHighContrast,
      body: Padding(
        padding: k20dp.symmetric(horizontal: true),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              ...kLargeDivider,
              _buildLogo(),
              MenuButton('Create room', onTap: _byOpenCreateRoomPage),
              kTransparentDivider,
              MenuButton('Join room', onTap: _byOpenServerListPage),
              kTransparentDivider,
              MenuButton('Set your name', onTap: _byOpenEditProfilePage),
              ...kLargeDivider,
            ],
          ),
        ),
      ),
    );
  }
}
