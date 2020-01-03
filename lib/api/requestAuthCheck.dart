import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:vk_parse/utils/urls.dart';
import 'package:vk_parse/functions/format/headersToken.dart';
import 'package:vk_parse/functions/get/getToken.dart';

requestAuthCheck() async {
  try {
    final token = await getToken();
    final response = await http.get(AUTH_CHECK, headers: formatToken(token)).timeout(Duration(seconds: 15));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } on TimeoutException catch(e) {
    return false;
  }
  catch (e) {
    print(e);
    return false;
  }
}
