import 'package:flutter/material.dart';


class HexColor extends Color {
  static Color background() => HexColor('#222222');
  static Color greyText() => HexColor('#cccccc');
  static Color mainText() => HexColor('#303030');
  static Color icon() => HexColor('#8c8c8c');
  static Color main() => Color.fromRGBO(193, 39, 45, 1);

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
