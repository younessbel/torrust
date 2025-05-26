import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    final String email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.8.102:4000/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      print('response: ${response.body}');

      final data = jsonDecode(response.body);
      print('data: $data');
      if (response.statusCode == 200) {
        setState(() {
          _message = data['message'] ?? "A code has been sent to your email.";
        });

        // Optional: Navigate to code confirmation screen
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (_) => ConfirmCodeScreen(email: email),
        // ));
      } else {
        setState(() {
          _message = data['message'] ?? "Something went wrong.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Network error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFe0ecff),
        child: SingleChildScrollView(
          child: Column(
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
              const SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        _emailController,
                        "Email",
                        false,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          final bool emailValid = RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                          ).hasMatch(value);
                          if (!emailValid) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading ? null : sendResetCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC3DFFF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Send Reset Code',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      if (_message != null)
                        Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: _message!.contains("✅")
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      bool isObscure, String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      enabled: !_isLoading,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC3C3C3)),
        filled: true,
        fillColor: _isLoading ? Colors.grey.shade100 : Colors.white,
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
          borderSide: const BorderSide(color: Color(0xFFA8D0FF), width: 3),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 3),
        ),
      ),
    );
  }
}
