import 'package:fox_music/utils/constants.dart';

formatImage(String imageUrl) {
  if (imageUrl == null) return '';
  if (imageUrl.startsWith('http')) return imageUrl;
  return BASE_URL + imageUrl;
}
