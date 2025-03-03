import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflix/core/config/theme/app_theme.dart';
import 'package:netflix/presentaion/splash/bloc/splash_cubit.dart';
import 'package:netflix/presentaion/splash/pages/splash.dart';
import 'package:netflix/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: ((context) => SplashCubit()..appStarted()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.appTheme,
        home: const SplashPage(),
      ),
    );
  }
}
