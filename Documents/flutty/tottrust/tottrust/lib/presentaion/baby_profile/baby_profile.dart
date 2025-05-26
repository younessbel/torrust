import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _tokenController = TextEditingController();
  final _apiUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default API URL
    _apiUrlController.text = 'http://192.168.8.102:4000';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F4FD),
              Color(0xFFD6E9F8),
              Color(0xFFC4DDF3),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.settings,
                  size: 80,
                  color: Color(0xFF6B9BD8),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Setup Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B9BD8),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please configure your API settings:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B9BD8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // API URL Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _apiUrlController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B9BD8),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'API URL (e.g., http://192.168.8.102:4000)',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B9BD8),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // JWT Token Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _tokenController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B9BD8),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter JWT Token',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B9BD8),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_tokenController.text.trim().isNotEmpty &&
                          _apiUrlController.text.trim().isNotEmpty) {
                        // Save settings
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                            'accessToken', _tokenController.text.trim());
                        await prefs.setString(
                            'apiUrl', _apiUrlController.text.trim());

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BabyProfileScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please enter both API URL and JWT token'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B9BD8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BabysittingRequest {
  final String name;
  final int age;
  final String date;
  final String hours;
  final String message;

  BabysittingRequest({
    required this.name,
    required this.age,
    required this.date,
    required this.hours,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'babysittingDate': {
        'date': date,
        'time': hours,
      },
      'message': message,
    };
  }
}

class ApiService {
  static Future<Map<String, dynamic>> addChildOffline(
      BabysittingRequest request, String token) async {
    try {
      // Get API URL from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final baseUrl = prefs.getString('apiUrl') ?? 'http://192.168.8.102:4000';

      // Check if token is valid
      if (token.isEmpty || token.contains('your_jwt_token_here')) {
        return {
          'success': false,
          'message': 'Please provide a valid JWT token'
        };
      }

      final fullUrl = '$baseUrl/add-child-offline';
      print('Making request to: $fullUrl');
      print('Request body: ${jsonEncode(request.toJson())}');

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Child profile added successfully!'
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication failed. Please check your token.'
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': 'Invalid data. Please check all fields.'
        };
      } else {
        return {
          'success': false,
          'message': 'Server error (${response.statusCode}). Please try again.'
        };
      }
    } catch (e) {
      print('Network error: $e');
      if (e.toString().contains('SocketException')) {
        return {
          'success': false,
          'message':
              'Cannot connect to server. Check your internet connection and API URL.'
        };
      } else {
        return {'success': false, 'message': 'Network error: ${e.toString()}'};
      }
    }
  }
}

class BabyProfileScreen extends StatefulWidget {
  BabyProfileScreen();

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hoursController = TextEditingController();
  final _message = TextEditingController();

  int _selectedAge = 1;
  bool _isLoading = false;
  DateTime? _selectedDate;

  final List<int> _ageOptions = List.generate(18, (index) => index + 1);

  @override
  void dispose() {
    _nameController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B9BD8),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF6B9BD8),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void showMessagePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter your message"),
          content: TextField(
            controller: _message,
            decoration: InputDecoration(hintText: "Type your message here"),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Submit"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    final dateString =
        '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}';

    final request = BabysittingRequest(
      name: _nameController.text.trim(),
      age: _selectedAge,
      date: dateString,
      hours: _hoursController.text.trim(),
      message: "take Care", // Default message
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final result = await ApiService.addChildOffline(request, token);

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F4FD),
              Color(0xFFD6E9F8),
              Color(0xFFC4DDF3),
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header with back button and baby icon
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF6B9BD8),
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.child_care,
                          color: Color(0xFFFFB6C1),
                          size: 32,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44), // Balance the back button
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  'Fill the baby profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B9BD8),
                  ),
                ),

                const SizedBox(height: 40),

                // Form fields
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      children: [
                        // Full name field
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Full name',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the child\'s name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Age dropdown
                        _buildAgeDropdown(),

                        const SizedBox(height: 20),

                        // Date field
                        _buildDatePickerField(),

                        const SizedBox(height: 20),

                        // Hours field
                        _buildTextField(
                          controller: _hoursController,
                          hintText: 'Hours',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the hours';
                            }
                            return null;
                          },
                        ),

                        const Spacer(),

                        // Confirm button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B9BD8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 2,
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
                                    'Confirm',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF6B9BD8),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16,
            color: const Color(0xFF6B9BD8).withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAgeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: _selectedAge,
        decoration: InputDecoration(
          hintText: 'Age',
          hintStyle: TextStyle(
            fontSize: 16,
            color: const Color(0xFF6B9BD8).withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF6B9BD8),
        ),
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF6B9BD8),
        ),
        items: _ageOptions.map((age) {
          return DropdownMenuItem<int>(
            value: age,
            child: Text('$age year${age > 1 ? 's' : ''} old'),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedAge = value!;
          });
        },
      ),
    );
  }

  Widget _buildDatePickerField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDate == null
                      ? 'Date DD/MM'
                      : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate == null
                        ? const Color(0xFF6B9BD8).withOpacity(0.6)
                        : const Color(0xFF6B9BD8),
                  ),
                ),
              ),
              Icon(
                Icons.calendar_today,
                color: const Color(0xFF6B9BD8).withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
