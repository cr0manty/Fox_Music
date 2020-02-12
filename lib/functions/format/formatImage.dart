import 'package:vk_parse/utils/urls.dart';

formatImage(String imageUrl) {
  if (imageUrl.startsWith('http')) return imageUrl;
  return BASE_URL + imageUrl;
}
