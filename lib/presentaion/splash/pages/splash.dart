import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflix/common/helper/navigation/app_navigation.dart';
import 'package:netflix/presentaion/auth/pages/signin.dart';
import 'package:netflix/presentaion/home/pages/home.dart';
import 'package:netflix/presentaion/splash/bloc/splash_cubit.dart';
import 'package:netflix/presentaion/splash/bloc/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is UnAuthenticated) {
            AppNavigator.pushReplacement(context, SigninPage());
          }
          if (state is Authenticated) {
            AppNavigator.pushReplacement(context, HomePage());
          }
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      // ignore: deprecated_member_use
                      colors: [
                    // ignore: deprecated_member_use
                    Color(0xff1A1B20).withOpacity(0),
                    Color(0xff1A1B20)
                  ])),
            )
          ],
        ),
      ),
    );
  }
}
