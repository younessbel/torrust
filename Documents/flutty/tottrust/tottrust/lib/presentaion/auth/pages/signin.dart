import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tottrust/common/helper/navigation/app_navigation.dart';
import 'package:tottrust/presentaion/auth/pages/debug_service.dart';
import 'package:tottrust/presentaion/auth/pages/signup.dart';
import 'package:tottrust/presentaion/changepassword/change_password.dart';
import 'package:tottrust/presentaion/home/pages/home.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    // Log the request (without password for security)
    DebugService.logInfo(
        'Login', 'Attempting login with identifier: $identifier');

    try {
      // Log API request details
      DebugService.logApiRequest('http://192.168.8.102:4000/login/babysitter',
          {'identifier': identifier, 'password': '***REDACTED***'});

      final response = await http.post(
        Uri.parse('http://192.168.8.102:4000/login/babysitter'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': identifier,
          'password': password,
        }),
      );

      // Log API response details
      DebugService.logApiResponse(
          'login/babysitter', response.body, response.statusCode);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        DebugService.logInfo('Login', 'Login successful: $responseData');
        // Save tokens to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', responseData['access']);
        await prefs.setString('userId', responseData['information']['_id']);
        await prefs.setString('email', responseData['information']['email']);
        await prefs.setString('photo', responseData['profilePicture']);
        await prefs.setString(
            'fullname', responseData['information']['fullname']);
        await prefs.setString(
            'phone_number', responseData['information']['phone_number']);

        // Store tokens
        await prefs.setString('access', responseData['access']);
        await prefs.setString(
            'refreshToken', responseData['information']['refreshToken']);

        await prefs.setString('refreshToken', responseData['access']);

        // Save profile picture URL if available
        if (responseData['profilePicture'] != null) {
          await prefs.setString(
              'profilePictureUrl', responseData['profilePicture']);
        }

        DebugService.logInfo('Login', 'Login successful');

        // Navigate to home page
        if (mounted) {
          AppNavigator.pushAndRemove(context, const HomePages());
        }
      } else {
        DebugService.logError(
          'Login',
          'Login failed with status: ${response.statusCode}',
        );

        setState(() {
          _errorMessage = responseData['message'] ??
              'Server error (${response.statusCode}). Please contact support if this persists.';
        });
      }
    } catch (error, stackTrace) {
      DebugService.logError('Login', error, stackTrace);

      setState(() {
        _errorMessage = 'Error: ${error.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCE9FC), // Background color
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 90,
                    decoration: const BoxDecoration(
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
                  const Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image(
                        image: AssetImage('assets/images/bebe.png'),
                        width: 90,
                        height: 50,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Error message if login fails
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Username / Phone Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _identifierController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your username or phone";
                        }
                        return null;
                      },
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: "Username / Phone",
                        hintStyle: const TextStyle(
                          color: Color(0xFFC3C3C3),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: Color(0xFFA8D0FF), width: 3),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: Color(0xFFA8D0FF), width: 3),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: Color(0xFFA8D0FF), width: 3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Input
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }
                        return null;
                      },
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: const TextStyle(
                          color: Color(0xFFC3C3C3),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: Color(0xFFA8D0FF), width: 3),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: Color(0xFFA8D0FF), width: 3),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: Color(0xFFA8D0FF), width: 3),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF508CD4),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Forgot Password
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          AppNavigator.push(context, ForgotPass());
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xFF508CD4), // Deep Blue
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Login Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF65A1E9), // Smooth Deep Blue
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(25), // More rounded
                        ),
                        disabledBackgroundColor:
                            const Color(0xFF65A1E9).withOpacity(0.6),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Log in",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 16, color: Color(0xFF508CD4)),
                  ),
                  TextButton(
                    onPressed: () {
                      AppNavigator.push(context, const Signuppp());
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF508CD4), // Deep Blue
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}
