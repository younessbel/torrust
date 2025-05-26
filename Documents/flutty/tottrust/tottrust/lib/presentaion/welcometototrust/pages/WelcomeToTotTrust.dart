import 'package:flutter/material.dart';
import 'package:tottrust/common/helper/navigation/app_navigation.dart';
import 'package:tottrust/presentaion/RoleSelectionPage/pages/RoleSelectionPage.dart';

class WelcomeToTotTrust extends StatelessWidget {
  const WelcomeToTotTrust({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDCE9FC), // Light blue background
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 71,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFC3DFFF),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(70),
                bottomRight: Radius.circular(70),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 7), // Add space between row and image
                Image.asset('assets/images/bebe.png',
                    width: 60, height: 60), // Centered image
              ],
            ),
          ),
          // Back Button
          IconButton(
            icon: Icon(Icons.arrow_back, size: 30, color: Colors.blue),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          SizedBox(height: 130),

          // White Container with Welcome Text
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Expanded(
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        "Welcome to Tottrust",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 12),

                      // Description
                      Text(
                        "Browse trusted babysitters, check ratings, and choose the best fit for your child.\n\n"
                        "Sign up to book and chat with them.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 35),

                      // Continue Button
                      _buildButton(
                        text: "Continue",
                        color: Color(0xFF508CD4),
                        textColor: Colors.white,
                        onPressed: () {
                          AppNavigator.push(context, RoleSelectionPage());
                        },
                      ),

                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Button Widget
  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class ParentSignupScreen {}
