import 'package:flutter/material.dart';

class AppNavigator {
  // Navigate to a new screen
  static void navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // Navigate to a new screen and remove all previous screens
  static void pushAndRemove(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  // Navigate to a new screen and remove until a specific route
  static void pushAndRemoveUntil(BuildContext context, Widget screen, RoutePredicate predicate) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      predicate,
    );
  }

  // Replace the current screen
  static void replace(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // Pop to the previous screen
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
