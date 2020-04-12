import 'package:shared_preferences/shared_preferences.dart';

saveLastTab(int tabIndex) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  await preferences.setInt('LastTab', tabIndex);
}
