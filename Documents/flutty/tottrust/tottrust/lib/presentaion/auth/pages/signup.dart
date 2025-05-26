import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tottrust/common/helper/navigation/app_navigation.dart';
import 'package:tottrust/presentaion/auth/pages/babysitter_service.dart';
import 'package:tottrust/presentaion/auth/pages/debug_service.dart';
import 'package:tottrust/presentaion/home/pages/home.dart';

class Signuppp extends StatefulWidget {
  const Signuppp({super.key});

  @override
  _SignupppState createState() => _SignupppState();
}

class _SignupppState extends State<Signuppp> {
  final _formKey = GlobalKey<FormState>();

  File? _imageFile;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _nationalIdController = TextEditingController();

  String? _selectedLocation;
  String? _selectedExperience;
  String? _selectedAgeGroup;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Map experience text to numeric value for the API
  Map<String, String> _experienceValues = {
    'No experience': '0',
    '1-2 years': '1',
    '3-5 years': '3',
    '5+ years': '5'
  };

  final List<String> _locations = [
    'Adrar',
    'Chlef',
    'Laghouat',
    'Oum El Bouaghi',
    'Batna',
    'Bejaia',
    'Biskra',
    'Bechar',
    'Blida',
    'Bouira',
    'Tamanrasset',
    'Tebessa',
    'Tlemcen',
    'Tiaret',
    'Tizi Ouzou',
    'Algiers',
    'Djelfa',
    'Jijel',
    'Setif',
    'Saïda',
    'Skikda',
    'Sidi Bel Abbes',
    'Annaba',
    'Guelma',
    'Constantine',
    'Medea',
    'Mostaganem',
    'Msila',
    'Mascara',
    'Ouargla',
    'Oran',
    'El Bayadh',
    'Illizi',
    'Bordj Bou Arreridj',
    'Boumerdes',
    'El Tarf',
    'Tindouf',
    'Tissemsilt',
    'El Oued',
    'Khenchela',
    'Souk Ahras',
    'Tipaza',
    'Mila',
    'Aïn Defla',
    'Naama',
    'Aïn Temouchent',
    'Ghardaia',
    'Relizane',
    'Timimoun',
    'Bordj Badji Mokhtar',
    'Ouled Djellal',
    'Béni Abbès',
    'In Salah',
    'In Guezzam',
    'Touggourt',
    'Djanet',
    'El MGhaier',
    'El Meniaa',
  ];
  final List<String> _experiences = [
    'No experience',
    '1-2 years',
    '3-5 years',
    '5+ years'
  ];
  final List<String> _ageGroups = ['0-3', '3-5', '6-10', '11+'];

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final fileExtension = picked.path.split('.').last.toLowerCase();
      if (fileExtension == 'jpg' ||
          fileExtension == 'jpeg' ||
          fileExtension == 'png') {
        setState(() {
          _imageFile = File(picked.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Only JPEG, JPG, or PNG files are allowed!")),
        );
      }
    }
  }

  Future<void> _registerBabysitter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the Terms & Conditions")),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a location")),
      );
      return;
    }

    if (_selectedExperience == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your experience level")),
      );
      return;
    }

    if (_selectedAgeGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an age group")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      DebugService.logInfo('Signup', 'Attempting to register babysitter');

      final result = await BabysitterService.registerBabysitter(
        fullname: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone_number: _phoneController.text.trim(),
        age: _ageController.text.trim(),
        pref_location: _selectedLocation!,
        exp: _experienceValues[_selectedExperience!] ?? '0',
        age_grps: [_selectedAgeGroup!],
        national_card_number: _nationalIdController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        profilePhoto: _imageFile,
      );

      if (result['success']) {
        // Registration successful, now login
        DebugService.logInfo(
            'Signup', 'Registration successful, attempting login');

        final loginResult = await BabysitterService.loginBabysitter(
          _phoneController.text.trim(), // Using phone as identifier
          _passwordController.text,
        );

        if (loginResult['success']) {
          DebugService.logInfo('Signup', 'Login successful');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Registration and login successful!")),
            );

            // Navigate to home page
            AppNavigator.push(context, const HomePages());
          }
        } else {
          setState(() {
            _errorMessage =
                'Registration successful but login failed: ${loginResult['message']}';
          });
          DebugService.logError('Signup',
              'Login failed after registration: ${loginResult['message']}');
        }
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
        DebugService.logError(
            'Signup', 'Registration failed: ${result['message']}');
      }
    } catch (error, stackTrace) {
      setState(() {
        _errorMessage = 'Error: ${error.toString()}';
      });
      DebugService.logError('Signup', error, stackTrace);
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
      backgroundColor: const Color(0xFFDCE9FC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Create your Babysitter Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, color: Color(0xFF2D5F9A)),
                    ),
                    const SizedBox(height: 20),

                    // Error message if registration fails
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 20),
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

                    _buildImagePicker(),
                    const SizedBox(height: 20),
                    _buildTextField(
                        _nameController, "Full Name", false, _validateName),
                    _buildTextField(
                        _emailController, "Email", false, _validateEmail),
                    _buildTextField(_phoneController, "Phone Number", false,
                        _validatePhone),
                    _buildTextField(
                        _ageController, "Age", false, _validateNumber),
                    _buildDropdown(_selectedLocation, "Location", _locations,
                        (v) => setState(() => _selectedLocation = v)),
                    _buildDropdown(
                        _selectedExperience,
                        "Experience",
                        _experiences,
                        (v) => setState(() => _selectedExperience = v)),
                    _buildDropdown(_selectedAgeGroup, "Age Group", _ageGroups,
                        (v) => setState(() => _selectedAgeGroup = v)),
                    _buildTextField(_nationalIdController, "National ID Number",
                        false, _validateNumber),
                    _buildTextField(_passwordController, "Password", true,
                        _validatePassword),
                    _buildTextField(_confirmPasswordController,
                        "Confirm Password", true, _validateConfirmPassword),
                    _buildTermsCheck(),
                    const SizedBox(height: 10),
                    _buildSubmitButton(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
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
            icon: Icon(Icons.arrow_back, color: Colors.blue.shade900, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
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
    );
  }

  Widget _buildImagePicker() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
          child: _imageFile == null
              ? Icon(Icons.person, size: 50, color: Colors.blue.shade700)
              : null,
        ),
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade700,
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      bool obscure, String? Function(String?) validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFA8D0FF), width: 3),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String? value, String hint, List<String> items,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButtonFormField<String>(
          value: value,
          hint: Center(
            child: Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFC3C3C3),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          isExpanded: true,
          alignment: Alignment.center,
          onChanged: onChanged,
          menuMaxHeight: 300,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    alignment: Alignment.center,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        item,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ))
              .toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFA8D0FF), width: 3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheck() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) => setState(() => _agreeToTerms = value!),
        ),
        const Text("I agree to the "),
        const Text("Terms & Conditions",
            style: TextStyle(decoration: TextDecoration.underline)),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: const Color(0xFF65A1E9),
        ),
        onPressed: _isLoading ? null : _registerBabysitter,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Sign Up',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Enter your full name";
    if (RegExp(r'\d').hasMatch(value)) return "Name cannot contain numbers";
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return "Enter your email";
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
      return "Enter a valid email";
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return "This field is required";
    if (!RegExp(r'^\d+$').hasMatch(value)) return "Only numbers are allowed";
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6)
      return "Password must be at least 6 characters";
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return "Enter your phone number";
    if (!RegExp(r'^(05|06|07)\d{8}$').hasMatch(value)) {
      return "not valid, must start with 05, 06, or 07 ";
    }
    return null;
  }

  String? _validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) return "Enter your national ID";
    if (!RegExp(r'^\d{18}$').hasMatch(value)) {
      return "National ID must contain exactly 18 digits.";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return "Passwords do not match";
    return null;
  }
}
