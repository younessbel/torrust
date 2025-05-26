import 'package:flutter/material.dart';

class DisplayMessage {
  static void errMessage(String message, BuildContext context) {
    var snackBar = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
