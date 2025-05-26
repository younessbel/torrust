import 'package:tottrust/common/helper/navigation/app_navigation.dart';
import 'package:tottrust/presentaion/welcometototrust/pages/WelcomeToTotTrust.dart';
import 'package:flutter/material.dart';

class WelcommePagesFirst extends StatelessWidget {
  const WelcommePagesFirst({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0ECFF), // updated background color
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Stack(
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tottrust',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF508CD4), // updated text color
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Find the perfect tottrust anytime!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2D5F9A), // updated title text color
                ),
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/img1.png',
                height: 350,
                width: 350,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor:
                        const Color(0xFF508CD4), // updated button color
                    shadowColor: Colors.blue.withOpacity(0.3),
                    elevation: 6,
                  ),
                  onPressed: () {
                    // Navigate using named route
                    AppNavigator.push(context, WelcomeToTotTrust());
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
