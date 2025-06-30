import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(0xFF3498db),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: const Color(0xFF3498db),
        secondary: const Color(0xFF3498db),
      ),
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: Colors.white,
    );
  }
}
