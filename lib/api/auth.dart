import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:fox_music/utils/urls.dart';
import 'package:fox_music/functions/format/token.dart';
import 'package:fox_music/functions/get/token.dart';

authCheckGet() async {
  try {
    final token = await getToken();
    final response = await http.get(AUTH_CHECK, headers: formatToken(token)).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  } on TimeoutException catch(e) {
    return false;
  }
  catch (e) {
    print(e);
    return false;
  }
}
