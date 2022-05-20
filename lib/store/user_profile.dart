import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? _preferences;
Future<SharedPreferences> preferences() async =>
    _preferences ??= await SharedPreferences.getInstance();

const kUserNameKey = 'user.name';

Future<void> setUserName(String name) async {
  final prefs = await preferences();

  prefs.setString(kUserNameKey, name);
}

Future<String> getUserName() async {
  final prefs = await preferences();

  return prefs.getString(kUserNameKey) ?? 'Unnamed Player';
}

late final ValueNotifier<String> userName;
