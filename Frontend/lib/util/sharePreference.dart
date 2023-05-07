import 'package:shared_preferences/shared_preferences.dart';

void login() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('login', true);
}

Future<bool?> loginCheck() async {
  final prefs = await SharedPreferences.getInstance();
  bool? loginSave = prefs.getBool('login');
  return loginSave;
}
