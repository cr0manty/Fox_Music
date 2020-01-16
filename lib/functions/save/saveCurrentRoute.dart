import 'package:shared_preferences/shared_preferences.dart';

saveCurrentRoute({int route}) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setInt('Route', route);
}
