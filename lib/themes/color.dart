import 'package:flutter/material.dart';

class MyTheme {
  static const Color blue1 = Color(0xff4182d8);
  static const Color blue2 = Color(0xff6b9ee1);
  static const Color blue3 = Color(0xff2768bf);
  static const Color blue4 = Color(0xff96bae9);
  static const Color white = Color(0xffffffff);
  static const Color greyWhite = Color(0xffe6e6e6);
  static final ThemeData defaultTheme = _buildMyTheme();

  static ThemeData _buildMyTheme() {
    final ThemeData base = ThemeData.light();

    return base.copyWith(
        // accentColor:
        );
  }
}
