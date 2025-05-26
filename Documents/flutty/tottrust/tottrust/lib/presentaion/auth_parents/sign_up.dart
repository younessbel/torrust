import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tottrust/common/helper/navigation/app_navigation.dart';
import 'package:tottrust/presentaion/auth_parents/services/auth_service.dart';
import 'package:tottrust/presentaion/homepgaeformother/homy.dart';

class SignUpMother extends StatefulWidget {
  const SignUpMother({super.key});

  @override
  _SignUpMotherState createState() => _SignUpMotherState();
}

class _SignUpMotherState extends State<SignUpMother> {
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedLocation;
  String? _selectedAgeGroup;
  bool _agreeToTerms = false;

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

  final List<String> _ageGroups = [
    '0-3',
    '4-6',
    '7-10',
    '11-14',
  ];

  Future<void> chooseImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _registerMother() async {
    print('Starting mother registration process...');

    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }
    print('Form validation successful');

    if (!_agreeToTerms) {
      print('Terms and conditions not accepted');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the Terms & Conditions")),
      );
      return;
    }
    print('Terms and conditions accepted');

    if (_selectedLocation == null) {
      print('Location not selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your location")),
      );
      return;
    }
    print('Selected location: $_selectedLocation');

    if (_selectedAgeGroup == null) {
      print('Age group not selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select preferred age group")),
      );
      return;
    }
    print('Selected age group: $_selectedAgeGroup');

    setState(() {
      _isLoading = true;
    });
    print('Set loading state to true');

    try {
      print('Attempting to register with:');
      print('Name: ${_nameController.text}');
      print('Phone: ${_phoneController.text}');
      print('Email: ${_emailController.text}');
      print('Location: $_selectedLocation');
      print('Age Group: $_selectedAgeGroup');
      print('Profile photo attached: ${_imageFile != null}');

      final result = await AuthService.registerMother(
        fullname: _nameController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
        profilePhoto: _imageFile,
        pref_location: _selectedLocation!,
        preferred_age_groups: _selectedAgeGroup!,
      );
      print('Received registration response: $result');

      setState(() {
        _isLoading = false;
      });
      print('Set loading state to false');

      if (result['success']) {
        print('Registration successful, navigating to home screen');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        AppNavigator.pushReplacement(context, HomeScreen());
      } else {
        print('Registration failed: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      print('Registration error occurred: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCE9FC),
      body: SingleChildScrollView(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Create your Mother Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        color: Color(0xFF2D5F9A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : null,
                          child: _imageFile == null
                              ? Icon(Icons.person,
                                  size: 50, color: Colors.blue.shade700)
                              : null,
                        ),
                        GestureDetector(
                          onTap: chooseImage,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blue.shade700,
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, "Full Name", false,
                        (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter your full name";
                      }
                      if (RegExp(r'\d').hasMatch(value)) {
                        return "Name cannot contain numbers";
                      }
                      return null;
                    }),
                    const SizedBox(height: 10),
                    _buildTextField(_emailController, "Email", false, (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter your email";
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    }),
                    const SizedBox(height: 10),
                    _buildTextField(_phoneController, "Phone Number", false,
                        _validatePhone),
                    const SizedBox(height: 10),
                    _buildDropdownField(
                      value: _selectedLocation,
                      hint: "Location",
                      items: _locations,
                      onChanged: (val) =>
                          setState(() => _selectedLocation = val),
                    ),
                    const SizedBox(height: 10),
                    _buildDropdownField(
                      value: _selectedAgeGroup,
                      hint: "Preferred Age Group",
                      items: _ageGroups,
                      onChanged: (val) =>
                          setState(() => _selectedAgeGroup = val),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(_passwordController, "Password", true,
                        (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter a password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    }),
                    const SizedBox(height: 10),
                    _buildTextField(
                        _confirmPasswordController, "Confirm Password", true,
                        (value) {
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    }),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value!;
                            });
                          },
                        ),
                        const Text("I agree to the "),
                        const Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: const Color(0xFF65A1E9),
                          shadowColor: Colors.blue.withOpacity(0.3),
                          elevation: 6,
                        ),
                        onPressed: _isLoading ? null : _registerMother,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isObscure,
    String? Function(String?) validator,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC3C3C3)),
        filled: true,
        fillColor: Colors.white,
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
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      alignment: Alignment.center,
      hint: Text(
        hint,
        style: const TextStyle(
          color: Color(0xFFC3C3C3),
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      menuMaxHeight: 300,
      dropdownColor: Colors.white,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          alignment: Alignment.center,
          child: Text(
            item,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        alignLabelWithHint: true,
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
      ),
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }
}
