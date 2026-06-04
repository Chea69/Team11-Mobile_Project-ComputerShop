import 'package:flutter/material.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const String fontFamily = 'monospace';

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
}
