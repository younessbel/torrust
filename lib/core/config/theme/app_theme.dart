import 'package:flutter/material.dart';
import 'package:netflix/core/config/theme/app_colors.dart';

class AppTheme {
  static final appTheme = ThemeData(
      primaryColor: const Color.fromARGB(255, 155, 155, 241),
      scaffoldBackgroundColor: const Color.fromARGB(255, 160, 197, 212),
      brightness: Brightness.dark,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: TextStyle(color: Colors.black),
      ), // SnackBarThemeData
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color.fromARGB(255, 83, 59, 59),
        hintStyle: const TextStyle(
          color: Color.fromARGB(255, 71, 70, 70),
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ), // TextStyle

        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(90),
          borderSide:
              BorderSide(width: 4, color: Color.fromARGB(0, 75, 212, 222)),
        ), // OutlineInputBorder
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(90),
          borderSide: BorderSide(width: 4),
        ),
        // OutlineInputBorder
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(100)) // RoundedRectangleBorder
              )) // ElevatedButtonThemeData
      // InputDecorationTheme
      );
}
