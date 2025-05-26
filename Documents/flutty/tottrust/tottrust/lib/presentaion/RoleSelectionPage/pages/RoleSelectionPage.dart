import 'package:flutter/material.dart';
import 'package:tottrust/common/helper/navigation/app_navigation.dart';
import 'package:tottrust/presentaion/auth/pages/signin.dart';
import 'package:tottrust/presentaion/auth_parents/LoginPage.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCE9FC), // Light blue background
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom AppBar
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 90,
                decoration: BoxDecoration(
                  color: Color(0xFFBFE0FF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                top: 32,
                child: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Colors.blue.shade900, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Centered baby image
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/bebe.png',
                    width: 90,
                    height: 50,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 100),
          Column(
            children: [
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        "Choose your role to continue!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5F9A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 60),

                      // Parent Button
                      _buildRoleButton(
                        text: "I'm a Parent",
                        backgroundColor: Color(0xFFA5C8FF),
                        onPressed: () {
                          AppNavigator.push(context, LoginPage());
                        },
                      ),
                      SizedBox(height: 20),

                      // baby  Button
                      _buildRoleButton(
                        text: "I'm a Babysitter",
                        backgroundColor: Color(0xFFA5C8FF),
                        onPressed: () {
                          AppNavigator.push(context, SigninPage());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 🔹 Custom Button Widget
  Widget _buildRoleButton({
    required String text,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 250,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
