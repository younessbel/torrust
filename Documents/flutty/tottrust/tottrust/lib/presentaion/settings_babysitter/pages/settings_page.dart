import 'package:flutter/material.dart';
import 'package:tottrust/common/helper/navigation/app_navigation.dart';
import 'package:tottrust/presentaion/auth/pages/signin.dart';
import 'package:tottrust/presentaion/settings_babysitter/pages/change_password_page.dart';
import 'package:tottrust/presentaion/settings_babysitter/pages/contact_support_page.dart';
import 'package:tottrust/presentaion/settings_babysitter/pages/delete_account_page.dart';
import 'package:tottrust/presentaion/settings_babysitter/pages/terms_conditions.dart';

class SettingsPagetottrust extends StatelessWidget {
  const SettingsPagetottrust({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFe0ecff), // Light blue background color
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
            SizedBox(height: 100), // Increased spacing
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  SettingsButton(
                    text: 'Change Password',
                    nextscreen: ChangePasswordPage(),
                  ),

                  SizedBox(height: 20), // Increased spacing
                  SettingsButton(
                    text: 'Contact Support',
                    nextscreen: ContactSupportPagetottrust(),
                  ),
                  SizedBox(height: 20), // Increased spacing

                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Logout'),
                            content: Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context); // Just close the dialog for "No"
                                },
                                child: Text('No',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context); // First close the dialog
                                  AppNavigator.pushAndRemove(
                                      context, SigninPage());
                                },
                                child: Text('Sure',
                                    style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20), // Increased spacing
                  SettingsButton(
                    text: 'Terms and Conditions',
                    nextscreen: BabysitterTermsPage(),
                  ),
                  SizedBox(height: 20), // Increased spacing
                  SettingsButton(
                    text: 'Delete Account',
                    nextscreen: DeleteAccountPage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  final String text;
  final Widget nextscreen;
  final VoidCallback? onPressed;
  const SettingsButton({
    required this.text,
    required this.nextscreen,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ??
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => nextscreen,
              ),
            );
          },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
