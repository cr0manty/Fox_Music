import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fox_music/utils/urls.dart';

appVersionGet() async {
  final response =
      await http.get(APP_VERSION_URL).timeout(Duration(seconds: 30));

  return json.decode(response.body);
}
