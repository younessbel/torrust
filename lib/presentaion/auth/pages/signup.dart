import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:netflix/common/helper/navigation/app_navigation.dart';
import 'package:netflix/core/config/theme/app_colors.dart';
import 'package:netflix/data/auth/models/auth/signup_req_params.dart';
import 'package:netflix/domain/auth/usecases/suignup.dart';
import 'package:netflix/presentaion/auth/pages/signin.dart';
import 'package:netflix/service_locator.dart';
import 'package:reactive_button/reactive_button.dart';

class SignupPage extends StatefulWidget {
  SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailContero = TextEditingController();

  final TextEditingController _passContero = TextEditingController();

  final TextEditingController _usernameController = TextEditingController();

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
              _fullNameField(),
              SizedBox(
                height: 25,
              ),
              _emailField(),
              SizedBox(
                height: 26,
              ),
              _passField(),
              SizedBox(
                height: 25,
              ),
              _phoneField(),
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

  Widget _signinText() {
    return Text(
      'Sign Up',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailContero,
      decoration: InputDecoration(hintText: 'Email'),
    );
  }

  Widget _passField() {
    return TextField(
      controller: _passContero,
      decoration: InputDecoration(hintText: 'Password'),
    );
  }

  Widget _fullNameField() {
    return TextField(
      controller: _usernameController,
      decoration: InputDecoration(hintText: 'FullName'),
    );
  }

  Widget _phoneField() {
    return TextField(
      decoration: InputDecoration(hintText: 'phone'),
    );
  }

  Widget _signinBut() {
    return ReactiveButton(
      title: 'Sign Up',
      activeColor: AppColors.primary,
      onPressed: () async {
        await sl<SignupUSeCase>().call(
            params: SignupReqParams(
                username: _usernameController.text,
                name: _emailContero.text,
                password: _passContero.text));
      },
      onSuccess: () {},
      onFailure: (error) {
        print(error);
      },
    );
  }

  Widget _SignUptext(BuildContext context) {
    return Text.rich(TextSpan(children: [
      TextSpan(text: 'Already have an account '),
      TextSpan(
          style: TextStyle(color: Colors.blue),
          text: 'SignIp',
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              AppNavigator.push(context, SigninPage());
            })
    ]));
  }
}
