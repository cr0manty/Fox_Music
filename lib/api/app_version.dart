import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fox_music/utils/urls.dart';

appVersionGet() async {
  try {
    final response =
        await http.get(APP_VERSION_URL).timeout(Duration(seconds: 20));

    if (response.statusCode == 200) return json.decode(response.body);
  } catch (_) {
    return;
  }
}
