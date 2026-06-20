import "package:flutter/material.dart";

class AppColors {
  const AppColors._();

  // Logo pin gradient (golden yellow → orange → deep orange-red)
  static const Color gradientStart = Color(0xFFFFD54F);
  static const Color gradientMid = Color(0xFFFF9800);
  static const Color gradientEnd = Color(0xFFE65100);
  static const Color primaryDark = Color(0xFFBF360C);

  static const Color primary = gradientMid;
  static const Color secondary = gradientStart;
  static const Color accent = Color(0xFF26C6DA);
  static const Color accentGreen = Color(0xFFAED581);

  static const Color backgroundLight = Color(0xFFFFFBF7);
  static const Color backgroundGradientStart = Color(0xFFFFF8EE);
  static const Color backgroundGradientEnd = Color(0xFFFFF0E3);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D2018);

  static const Color backgroundDark = Color(0xFF1A120E);
  static const Color backgroundDarkGradientEnd = Color(0xFF2A1A12);
  static const Color surfaceDark = Color(0xFF2A1F18);
  static const Color textLight = Color(0xFFFFF8F3);

  static const Color success = Color(0xFF22A06B);
  static const Color danger = Color(0xFFE24755);

  static const List<Color> primaryGradient = <Color>[
    gradientStart,
    gradientMid,
    gradientEnd,
  ];

  static const List<Color> primaryGradientPair = <Color>[
    gradientStart,
    gradientEnd,
  ];

  static const List<Color> backgroundGradient = <Color>[
    backgroundGradientStart,
    backgroundGradientEnd,
  ];

  static const List<Color> backgroundGradientDark = <Color>[
    backgroundDark,
    backgroundDarkGradientEnd,
  ];

  static const List<Color> wheelSegmentColors = <Color>[
    gradientStart,
    gradientMid,
    gradientEnd,
    primaryDark,
    gradientStart,
    gradientMid,
    gradientEnd,
    primaryDark,
  ];
}
