import 'package:flutter/material.dart';

class ColorStyles {
  static const Color primaryColor = Color(0xFF242b57);
  static const Color secondaryColor = Color(0xFF3f91c6);
  static const Color blankColor = Color(0xFFf1f4f9);
  static const Color blankColorSecondary = Color(0xffeceef1);
  static const Color textColor = Color(0xFF2B2B2B);

  // Método para obtener el tema de la aplicación
  static ThemeData getAppTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: blankColor,
      textTheme: TextTheme(
      ),
    );
  }
}