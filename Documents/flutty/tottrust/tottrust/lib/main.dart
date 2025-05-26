import 'package:flutter/material.dart';
import 'package:tottrust/core/config/theme/app_theme.dart';
import 'package:tottrust/presentaion/chat/services/api_service.dart';
import 'package:tottrust/presentaion/chat/services/logger_service.dart';
import 'package:tottrust/presentaion/welcome_page/pages/welcome_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LoggerService.logInfo('🚀 Starting Babysitter Chat App');

  // Initialize user session for testing
  await ApiService.initializeUserSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appTheme,
      home: const WelcommePagesFirst(),
    );
  }
}
