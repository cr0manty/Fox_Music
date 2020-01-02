import 'package:shared_preferences/shared_preferences.dart';

saveCurrentRoute(String lastRoute) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString('LastRoute', lastRoute);
}
