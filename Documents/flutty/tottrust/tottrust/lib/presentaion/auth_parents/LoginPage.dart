import 'package:flutter/material.dart';
import 'package:tottrust/common/helper/navigation/app_navigation.dart';
import 'package:tottrust/presentaion/auth_parents/Sign_up.dart';
import 'package:tottrust/presentaion/auth_parents/services/auth_service_login.dart';
import 'package:tottrust/presentaion/changepassword/change_password.dart';
import 'package:tottrust/presentaion/homepgaeformother/homy.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _login() async {
    print('==== Login Process Started ====');
    print('1. Checking form validation...');

    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed - required fields are empty');
      return;
    }
    print('✅ Form validation successful');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    print('2. Updated UI state: Loading started, cleared any previous errors');

    try {
      print('3. Attempting login with:');
      print(
          '   - Identifier: ${_identifierController.text.substring(0, 3)}***');
      print('   - Password: ********');

      final result = await AuthService.loginMother(
        identifier: _identifierController.text,
        password: _passwordController.text,
      );
      print('4. Received server response:');
      print('   - Success: ${result['success']}');
      print('   - Message: ${result['message']}');

      if (result['success']) {
        print('5. ✅ Login successful!');
        print('6. Navigating to home screen...');
        AppNavigator.pushReplacement(context, HomeScreen());
      } else {
        print('5. ❌ Login failed');
        print('   - Error: ${result['message']}');
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      print('❌ Error during login:');
      print('   - Type: ${e.runtimeType}');
      print('   - Message: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      print('7. Cleaning up...');
      setState(() {
        _isLoading = false;
      });
      print('8. Login process completed');
      print('========================');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCE9FC), // Background color
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFBFE0FF),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(80),
              bottomRight: Radius.circular(80),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon:
                  Icon(Icons.arrow_back, color: Colors.blue.shade900, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Image(
              image: AssetImage('assets/images/bebe.png'),
              width: 90,
              height: 50,
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    "Mother Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5F9A),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Error message if any
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
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

                  const SizedBox(height: 20),

                  // Username / Phone Input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        _buildTextField(
                          _identifierController,
                          "Full Name or Phone Number",
                          false,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your full name or phone number";
                            }
                            return null;
                          },
                          prefixIcon: const Icon(Icons.person,
                              color: Color(0xFF65A1E9)),
                        ),
                        const SizedBox(height: 20),

                        // Password Input
                        _buildTextField(
                          _passwordController,
                          "Password",
                          _obscurePassword,
                          (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password";
                            }
                            return null;
                          },
                          prefixIcon:
                              const Icon(Icons.lock, color: Color(0xFF65A1E9)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF65A1E9),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
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
                        const SizedBox(height: 30),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF65A1E9), // Smooth Deep Blue
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(25), // More rounded
                              ),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    "Log in",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style:
                            TextStyle(fontSize: 16, color: Color(0xFF508CD4)),
                      ),
                      TextButton(
                        onPressed: () {
                          AppNavigator.push(context, SignUpMother());
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
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isObscure,
    String? Function(String?) validator, {
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFC3C3C3),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFA8D0FF), width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFA8D0FF), width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF65A1E9), width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red.shade300, width: 3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red.shade300, width: 3),
        ),
      ),
    );
  }
}
