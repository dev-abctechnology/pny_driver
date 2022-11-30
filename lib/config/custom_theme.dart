import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor customGreyDark = MaterialColor(
    0xFF1d272d,
    <int, Color>{
      50: Color(0xff1a2329), //10%
      100: Color(0xff171f24), //20%
      200: Color(0xff141b1f), //30%
      300: Color(0xff11171b), //40%
      400: Color(0xff0f1417), //50%
      500: Color(0xff0c1012), //60%
      600: Color(0xff090c0d), //70%
      700: Color(0xff060809), //80%
      800: Color(0xff030404), //90%
      900: Color(0xff000000), //100%
    },
  );

  static const MaterialColor customGreyLight = MaterialColor(
    0x1d272d,
    <int, Color>{
      50: Color(0xffe8e9ea),
      100: Color(0xffd2d4d5),
      200: Color(0xffbbbec0),
      300: Color(0xffa5a9ab),
      400: Color(0xff8e9396),
      500: Color(0xff777d81),
      600: Color(0xff61686c),
      700: Color(0xff4a5257),
      800: Color(0xff343d42),
      900: Color(0xff1d272d),
    },
  );

  static const MaterialColor persianasColor = MaterialColor(
    0xff00b2dd,
    <int, Color>{
      50: Color(0xff80d9ee),
      100: Color(0xff66d1eb),
      200: Color(0xff4dc9e7),
      300: Color(0xff33c1e4),
      400: Color(0xff1abae0),
      500: Color(_persianasPrimaryValue),
      600: Color(0xff00a0c7),
      700: Color(0xff008eb1),
      800: Color(0xff007d9b),
      900: Color(0xff006b85),
    },
  );

  static const int _persianasPrimaryValue = 0xFF00b2dd;
}
