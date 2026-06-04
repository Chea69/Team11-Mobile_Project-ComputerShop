import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color bgBase = Color(0xFF0A0A0F);
  static const Color bgSurface = Color(0xFF12121A);
  static const Color bgSurfaceLight = Color(0xFF1A1A24);
  static const Color textMain = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color magenta = Color(0xFFFF2BD6);
  static const Color violet = Color(0xFF7C3AFF);

  static const Color primary = cyan;
  static const Color secondary = magenta;
  static const Color accent = cyan;
  static const Color purple = violet;
  static const Color warning = Color.fromRGBO(255, 183, 77, 1);
  static const Color danger = Color.fromRGBO(255, 82, 82, 1);

  static const Color darkBackground = bgBase;
  static const Color darkSurface = bgSurface;
  static const Color darkSurfaceHigh = bgSurfaceLight;
  static const Color darkText = textMain;
  static const Color darkMutedText = textMuted;

  static const Color lightBackground = Color.fromRGBO(245, 247, 251, 1);
  static const Color lightSurface = Color.fromRGBO(255, 255, 255, 1);
  static const Color lightSurfaceHigh = Color.fromRGBO(226, 232, 240, 1);
  static const Color lightText = Color.fromRGBO(15, 23, 42, 1);
  static const Color lightMutedText = Color.fromRGBO(71, 85, 105, 1);

  static const LinearGradient rgbGradient = LinearGradient(
    colors: [cyan, magenta, violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rgbBorderGradient = LinearGradient(
    colors: [cyan, magenta, violet, cyan],
    stops: [0, 0.42, 0.72, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
