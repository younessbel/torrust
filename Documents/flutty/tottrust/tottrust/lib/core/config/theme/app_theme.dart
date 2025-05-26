import 'package:flutter/material.dart';

class AppTheme {
  static final appTheme = ThemeData(
    fontFamily: 'MochiyPopP',
    useMaterial3: true,
    primaryColor: const Color.fromARGB(255, 0, 0, 0),
    scaffoldBackgroundColor: const Color.fromARGB(255, 224, 236, 255),
    brightness: Brightness.light,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Colors.white,
      contentTextStyle: TextStyle(color: Colors.black),
    ), // SnackBarThemeData
  );
}
