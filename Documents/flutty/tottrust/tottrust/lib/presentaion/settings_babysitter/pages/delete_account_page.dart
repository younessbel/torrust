import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({Key? key}) : super(key: key);

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  // Fixed naming - using lowercase to match your existing code
  bool _isloading = false;

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Final Confirmation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: const Text(
            'This action cannot be undone. Your account and all associated data will be permanently deleted.\n\nAre you absolutely sure you want to proceed?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete Forever',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isloading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        _showErrorSnackBar(
            'Authentication token not found. Please login again.');
        setState(() {
          _isloading = false;
        });
        return;
      }

      final response = await http.delete(
        Uri.parse('http://192.168.8.102:4000/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Clear all stored data
        await prefs.clear();

        _showSuccessSnackBar(
            responseData['message'] ?? 'Account deleted successfully');

        // Navigate to login/welcome screen after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // Navigate to login screen and clear all previous routes
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login', // Replace with your login route
              (Route<dynamic> route) => false,
            );
          }
        });
      } else {
        _showErrorSnackBar(
            responseData['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      _showErrorSnackBar(
          'Network error. Please check your connection and try again.');
      debugPrint('Error deleting account: $e');
    } finally {
      setState(() {
        _isloading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FD), // Light blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.blue.shade900,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.blue.shade900,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),

              // Main Title
              const Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Warning Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Deleting your account is permanent. All your data will be removed. Are you sure?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 60),

              // Delete Account Button
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27.5),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B6B),
                      const Color(0xFFE53E3E),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isloading ? null : _showDeleteConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27.5),
                    ),
                  ),
                  child: _isloading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Delete My Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Additional Warning Text
              Text(
                'This action cannot be undone',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
