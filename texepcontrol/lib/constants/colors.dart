import 'package:flutter/material.dart';

class ColorsExt {
  ColorsExt._();

  static const Map<int, Color> brown500Map = {
    50: Color.fromARGB(255, 31, 20, 9),
    100: Color(0xFF3a2613),
    200: Color.fromARGB(255, 66, 44, 23),
    300: Color.fromARGB(255, 71, 47, 25),
    400: Color.fromARGB(255, 83, 54, 27),
    500: Color(0xFF9a6432),
    600: Color.fromARGB(255, 179, 113, 52),
    700: Color.fromARGB(255, 179, 111, 48),
    800: Color.fromARGB(255, 187, 116, 49),
    900: Color.fromARGB(255, 194, 111, 34),
  };

  static const MaterialColor brown500Swatch =
      MaterialColor(0xFF3a2613, brown500Map);
}
