import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ContactSupportPagetottrust extends StatefulWidget {
  const ContactSupportPagetottrust({super.key});

  @override
  State<ContactSupportPagetottrust> createState() =>
      _ContactSupportPagetottrustState();
}

class _ContactSupportPagetottrustState
    extends State<ContactSupportPagetottrust> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  String? _feedback;

  Future<String?> sendSupportMessage({required String message}) async {
    final url = Uri.parse('http://192.168.8.102:4000/contact-support');
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      return 'Support message sent successfully!';
    } else {
      final error = jsonDecode(response.body);
      return 'Failed: ${error['message']}';
    }
  }

  void _handleSend() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() => _feedback = 'Please enter a message.');
      return;
    }

    setState(() {
      _isLoading = true;
      _feedback = null;
    });

    final result = await sendSupportMessage(message: message);

    setState(() {
      _isLoading = false;
      _feedback = result;
      if (result?.startsWith('Support message sent') == true) {
        _messageController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(224, 236, 255, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
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
            // Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: const [
                        Text(
                          'Contact Support',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Need help? Send us a message and we’ll get back to you soon.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Email/Phone Field (Static)
                  TextField(
                    controller: TextEditingController(text: '06658765569'),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Email / Phone Number',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  // Message Field
                  TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tell us what’s wrong?',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 30),
                  // Send Button
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSend,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Send',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (_feedback != null) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        _feedback!,
                        style: TextStyle(
                          color: _feedback!.startsWith('Support')
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
