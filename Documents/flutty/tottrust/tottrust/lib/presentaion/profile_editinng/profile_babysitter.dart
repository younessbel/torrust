// ignore_for_file: public_member_api_docs, sort_constructors_first
import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:tottrust/common/helper/navigation/app_navigation.dart";
import "package:tottrust/presentaion/settings_babysitter/pages/settings_page.dart";

// Add this service class for API calls
class BabysitterService {
  static const String baseUrl =
      'http://192.168.8.102:4000'; // Replace with your actual API URL

  static Future<Map<String, dynamic>> updateBabysitterProfile({
    required String fullname,
    required int age,
    required String prefLocation,
    required String exp,
    required String ageGrps,
    String? profilePhoto,
    required String bio,
    required String authToken,
  }) async {
    print("🚀 Starting profile update API call");
    print("📝 Data to send:");
    print("  - fullname: $fullname");
    print("  - age: $age");
    print("  - pref_location: $prefLocation");
    print("  - exp: $exp");
    print("  - age_grps: $ageGrps");
    print("  - bio: $bio");
    print(
        "  - profilePhoto: ${profilePhoto != null ? 'Image provided' : 'No image'}");

    try {
      final url = Uri.parse('$baseUrl/updateBabysitterProfile');
      print("🌐 API URL: $url");

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };
      print("🔐 Headers set with auth token");

      final body = json.encode({
        'fullname': fullname,
        'age': age,
        'pref_location': prefLocation,
        'exp': exp,
        'age_grps': ageGrps,
        'profilePhoto': profilePhoto,
        'bio': bio,
      });
      print("📦 Request body prepared");

      print("⏳ Sending PUT request...");
      final response = await http.put(
        url,
        headers: headers,
        body: body,
      );

      print("📨 Response received:");
      print("  - Status Code: ${response.statusCode}");
      print("  - Response Body: ${response.body}");

      if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Babysitter not found',
        };
      }

      if (response.statusCode != 200) {
        print("❌ Profile update failed with status: ${response.statusCode}");
        final errorResponse = json.decode(response.body);
        return {
          'success': false,
          'message': errorResponse['message'] ?? 'Failed to update profile',
          'error': errorResponse['error']
        };
      }

      final responseData = json.decode(response.body);
      print("✅ Profile update successful!");
      return {
        'success': true,
        'message': responseData['message'] ?? 'Profile updated successfully',
        'babysitter': responseData['babysitter'],
      };
    } catch (e) {
      print("💥 API call error: ${e.toString()}");
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}

class ProfilePageEditingBaby extends StatefulWidget {
  final int initialAge;
  final String initialBio;
  final String initialLocation;
  final String initialName;
  final String initialProfilePhoto;

  const ProfilePageEditingBaby({
    Key? key,
    required this.initialAge,
    this.initialBio = "Add a short bio about yourself",
    required this.initialLocation,
    required this.initialName,
    required this.initialProfilePhoto,
    required String profilePhoto,
  }) : super(key: key);

  @override
  State<ProfilePageEditingBaby> createState() => _ProfilePageEditingBabyState();
}

class _ProfilePageEditingBabyState extends State<ProfilePageEditingBaby> {
  final TextEditingController bioController = TextEditingController();

  // Add state variables for dropdown selections
  String? babysittingExperience;
  String? ageGroup;
  String? region;

  // Add loading state
  bool _isLoading = false;

  late int age;
  late String bio;
  late String location;
  late String name;
  bool isEditingBio = false;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    age = widget.initialAge;
    bio = widget.initialBio;
    location = widget.initialLocation;
    name = widget.initialName;
    print("🎯 ProfilePageEditingBaby initialized");
    print("📋 Initial data:");
    print("  - Name: $name");
    print("  - Age: $age");
    print("  - Location: $location");
    print("  - Bio: $bio");

    bioController.text = bio;

    // Initialize dropdown values
    _initializeDropdownValues();
  }

  void _initializeDropdownValues() {
    print("🔧 Initializing dropdown values...");
    // Set default values or load from existing data
    babysittingExperience = "0"; // Changed to match dropdown options
    ageGroup = "0-3";

    // Convert location to title case and remove any numeric prefix
    String normalizedLocation = location.isNotEmpty
        ? location
            .split('-')
            .last
            .trim()
            .split(' ')
            .map((word) =>
                word[0].toUpperCase() + word.substring(1).toLowerCase())
            .join(' ')
        : "Relizane";

    // Find matching region from the list
    region = normalizedLocation;
    print("✅ Dropdown values initialized with region: $region");
  }

  Future<void> chooseImage() async {
    print("📷 Opening image picker...");
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print("🖼️ Image selected: ${pickedFile.path}");
      setState(() {
        imageFile = File(pickedFile.path);
      });
      print("✅ Image updated in state");
    } else {
      print("❌ No image selected");
    }
  }

  // Convert image to base64 string for API
  Future<String?> _convertImageToBase64() async {
    if (imageFile == null) {
      print("📷 No image to convert");
      return null;
    }

    try {
      print("🔄 Converting image to base64...");
      final bytes = await imageFile!.readAsBytes();
      final base64String = base64Encode(bytes);
      print("✅ Image converted to base64 (length: ${base64String.length})");
      return base64String;
    } catch (e) {
      print("❌ Error converting image to base64: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    print("💾 Starting profile save process...");

    // Validate required fields
    if (name.trim().isEmpty) {
      print("❌ Validation failed: Name is empty");
      _showSnackBar('Please enter your name', Colors.red);
      return;
    }

    if (age <= 0) {
      print("❌ Validation failed: Invalid age");
      _showSnackBar('Please enter a valid age', Colors.red);
      return;
    }

    if (babysittingExperience == null || ageGroup == null || region == null) {
      print("❌ Validation failed: Missing dropdown selections");
      _showSnackBar('Please complete all profile fields', Colors.red);
      return;
    }

    print("✅ Validation passed");

    setState(() {
      _isLoading = true;
    });
    print("⏳ Loading state set to true");

    try {
      // Convert image to base64 if available
      final profilePhotoBase64 = await _convertImageToBase64();

      final prefs = await SharedPreferences.getInstance();
      String? authTokenNullable = prefs.getString('accessToken');
      String authToken = authTokenNullable ?? '';
      print("🔐 Auth token retrieved");

      // Make API call
      print("🌐 Making API call to update profile...");
      final result = await BabysitterService.updateBabysitterProfile(
        fullname: name.trim(),
        age: age,
        prefLocation: region!,
        exp: babysittingExperience!,
        ageGrps: ageGroup!,
        profilePhoto: profilePhotoBase64,
        bio: bio.trim(),
        authToken: authToken,
      );

      print("📊 API call result received:");
      print("  - Success: ${result['success']}");
      print("  - Message: ${result['message']}");

      if (result['success']) {
        print("🎉 Profile update successful!");
        _showSnackBar(result['message'], Colors.green);

        // Optional: Update local state with server response
        if (result['babysitter'] != null) {
          print("🔄 Updating local state with server data...");
          print("✅ Local state updated");
        }

        // Optional: Navigate back or to another screen
        // Navigator.pop(context);
      } else {
        print("❌ Profile update failed: ${result['message']}");
        _showSnackBar(result['message'], Colors.red);
      }
    } catch (e) {
      print("💥 Error during profile save: ${e.toString()}");
      _showSnackBar('Error saving profile: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
      print("✅ Loading state set to false");
    }
  }

  void _showSnackBar(String message, Color color) {
    print("📢 Showing snackbar: $message");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAdditionalFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildDropdownField(
          "Babysitting Experience",
          [
            "0",
            "4",
            "5",
            "I'm a mother",
          ],
          babysittingExperience,
          (newValue) {
            print("🔄 Babysitting experience changed to: $newValue");
            setState(() {
              babysittingExperience = newValue;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          "Age Group Preference",
          [
            "0-3",
            "4-8",
            "All ages",
          ],
          ageGroup,
          (newValue) {
            print("🔄 Age group changed to: $newValue");
            setState(() {
              ageGroup = newValue;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          "Region",
          [
            "Adrar",
            "Chlef",
            "Laghouat",
            "Oum El Bouaghi",
            "Batna",
            "Béjaïa",
            "Biskra",
            "Béchar",
            "Blida",
            "Bouira",
            "Tamanrasset",
            "Tébessa",
            "Tlemcen",
            "Tiaret",
            "Tizi Ouzou",
            "Alger",
            "Djelfa",
            "Jijel",
            "Sétif",
            "Saïda",
            "Skikda",
            "Sidi Bel Abbès",
            "Annaba",
            "Guelma",
            "Constantine",
            "Médéa",
            "Mostaganem",
            "M'Sila",
            "Mascara",
            "Ghardaïa",
            "Relizane",
            "El Bayadh",
            "Illizi",
            "Bordj Bou Arréridj",
            "Boumerdès",
            "El Tarf",
            "Tindouf",
            "Tissemsilt",
            "El Oued",
            "Khenchela",
            "Souk Ahras",
            "Tipaza",
            "Mila",
            "Aïn Defla",
            "Naâma",
            "Aïn Témouchent",
            "Timimoun",
            "Bordj Badji Mokhtar",
            "Ouled Djellal",
            "Béni Abbès",
            "In Salah",
            "In Guezzam",
            "Touggourt",
            "Djanet",
            "El M'Ghair",
            "El Menia",
          ],
          region,
          (newValue) {
            print("🔄 Region changed to: $newValue");
            setState(() {
              region = newValue;
              location = newValue!; // Update the main location as well
            });
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(195, 223, 255, 1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            underline: const SizedBox(),
            hint: const Text(
              "Select",
              style: TextStyle(color: Colors.black54),
            ),
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(224, 236, 255, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(Icons.settings,
                        color: Colors.blue.shade900, size: 28),
                    onPressed: () {
                      print("⚙️ Settings button pressed");
                      AppNavigator.push(context, SettingsPagetottrust());
                    },
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Colors.blue.shade900, size: 28),
                    onPressed: () {
                      print("⬅️ Back button pressed");
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildBioSection(),
                  const SizedBox(height: 16),
                  _buildAdditionalFields(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(195, 223, 255, 1),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProfileImage(),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditableRow(name, "Name"),
              _buildEditableRow("$age", "Age"),
              _buildEditableRow(location, "Location"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color.fromARGB(255, 239, 240, 241),
          backgroundImage: imageFile != null ? FileImage(imageFile!) : null,
          child: imageFile == null
              ? const Icon(Icons.person, size: 70, color: Colors.blue)
              : null,
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: InkWell(
            onTap: chooseImage,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableRow(String text, String field) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            print("✏️ Edit button pressed for field: $field");
            _showEditDialog(context, text, (updatedText) {
              print("💾 Saving updated text for $field: $updatedText");
              setState(() {
                if (field == "Name") {
                  name = updatedText;
                } else if (field == "Age") {
                  age = int.tryParse(updatedText) ?? age;
                } else if (field == "Location") {
                  location = updatedText;
                }
              });
              print("✅ Field $field updated successfully");
            });
          },
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bio",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Color.fromRGBO(195, 223, 255, 1),
          ),
          child: isEditingBio
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: bioController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter your bio",
                          hintStyle: TextStyle(color: Colors.black54),
                        ),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                        maxLines: null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.blue),
                      onPressed: () {
                        print("✅ Bio check button pressed");
                        print("📝 New bio: ${bioController.text}");
                        setState(() {
                          bio = bioController.text;
                          isEditingBio = false;
                        });
                        print("✅ Bio updated successfully");
                      },
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Text(
                        bio,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        print("✏️ Bio edit button pressed");
                        setState(() {
                          isEditingBio = true;
                        });
                      },
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: _isLoading ? Colors.grey : Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 5,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Save Changes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String currentText, Function(String) onSave) {
    print("📝 Showing edit dialog for: $currentText");
    final TextEditingController controller =
        TextEditingController(text: currentText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Edit", style: TextStyle(color: Colors.black)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "Enter new text",
              labelStyle: const TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Colors.blueAccent, width: 1.5),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("❌ Edit dialog cancelled");
                Navigator.of(context).pop();
              },
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                print("✅ Edit dialog confirmed with: ${controller.text}");
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    print("🗑️ ProfilePageEditingBaby disposed");
    bioController.dispose();
    super.dispose();
  }
}
