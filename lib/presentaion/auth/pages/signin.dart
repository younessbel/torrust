import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:netflix/common/helper/navigation/app_navigation.dart';
import 'package:netflix/core/config/theme/app_colors.dart';
import 'package:netflix/presentaion/auth/pages/signup.dart';
import 'package:reactive_button/reactive_button.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          minimum: EdgeInsets.only(top: 100, right: 16, left: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _signinText(),
              SizedBox(
                height: 25,
              ),
              _emailField(),
              SizedBox(
                height: 25,
              ),
              _passField(),
              SizedBox(
                height: 25,
              ),
              _signinBut(),
              SizedBox(
                height: 5,
              ),
              _SignUptext(context)
            ],
          )),
    );
  }
}

Widget _signinText() {
  return Text(
    'Sign in',
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
  );
}

Widget _emailField() {
  return TextField(
    decoration: InputDecoration(hintText: 'Email'),
  );
}

Widget _passField() {
  return TextField(
    decoration: InputDecoration(hintText: 'Password'),
  );
}

Widget _signinBut() {
  return ReactiveButton(
    title: 'Sign in',
    activeColor: AppColors.primary,
    onPressed: () async {},
    onSuccess: () {},
    onFailure: (error) {},
  );
}

Widget _SignUptext(BuildContext context) {
  return Text.rich(TextSpan(children: [
    TextSpan(text: 'don\'t have an account '),
    TextSpan(
        style: TextStyle(color: Colors.blue),
        text: 'SignUp',
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            AppNavigator.push(context, SignupPage());
          })
  ]));
}
