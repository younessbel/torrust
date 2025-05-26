import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:tottrust/common/helper/navigation/app_navigation.dart";
import "package:tottrust/presentaion/settings_babysitter/pages/settings_page.dart";

class ProfilePageBeforeEdittottrust extends StatefulWidget {
  const ProfilePageBeforeEdittottrust({super.key});

  @override
  State<ProfilePageBeforeEdittottrust> createState() =>
      _ProfilePageBeforeEdittottrustState();
}

class _ProfilePageBeforeEdittottrustState
    extends State<ProfilePageBeforeEdittottrust> {
  late TextEditingController fullnameController;
  late TextEditingController ageController;
  late TextEditingController locationController;
  late TextEditingController bioController;
  late TextEditingController experienceController;

  int experience = 3;
  bool isLoading = false;
  bool isUploadingImage = false;

  List<String> ageGroups = ["0-3"];
  String fullname = "Sarah Doe";
  String savedString = "No value found";
  String phoneNumber = "1234567890";
  String email = "";
  String nationalCardNumber = "1234567890123456";
  String age = "25";
  String prefLocation = "Adrar";
  String value = "No value found";
  String bio =
      "Loving and experienced babysitter with a passion for child development.";
  String profileImageUrl =
      "https://i.pravatar.cc/150?img=3"; // Network image URL

  String selectedAgeGroup = "0-3";
  String selectedLocation = "Adrar";

  List<String> ageGroupOptions = ["0-3", "4-7", "8-12"];

  // 58 Wilayas of Algeria
  List<String> locationOptions = [
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
    "Ouargla",
    "Oran",
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
    "Ghardaïa",
    "Relizane",
    "Timimoun",
    "Bordj Badji Mokhtar",
    "Ouled Djellal",
    "Béni Abbès",
    "In Salah",
    "In Guezzam",
    "Touggourt",
    "Djanet",
    "El M'Ghair",
    "El Meniaa"
  ];

  File? imageFile;

  @override
  void initState() {
    super.initState();
    fullnameController = TextEditingController(text: fullname);
    ageController = TextEditingController(text: age);
    locationController = TextEditingController(text: prefLocation);
    bioController = TextEditingController(text: bio);
    experienceController = TextEditingController(text: experience.toString());
    _loadUserData();
  }

  Future<Map<String, String?>> getUserDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('userId'),
      'email': prefs.getString('email'),
      'age': prefs.getString('age'),
      'pref_location': prefs.getString('pref_location'),
      'national_card_number': prefs.getString('national_card_number'),
      'fullname': prefs.getString('fullname'),
      'phone_number': prefs.getString('phone_number'),
      'access': prefs.getString('accessToken'),
      'refreshToken': prefs.getString('refreshToken'),
      'exp': prefs.getString('exp'),
      'photo': prefs.getString('photo'),
      'bio': prefs.getString('bio'),
    };
  }

  void _loadUserData() async {
    Map<String, String?> userData = await getUserDataFromPrefs();

    if (mounted) {
      setState(() {
        if (userData['fullname'] != null && userData['fullname']!.isNotEmpty) {
          fullname = userData['fullname']!;
          fullnameController.text = fullname;
        }
        if (userData['age'] != null && userData['age']!.isNotEmpty) {
          age = userData['age']!;
          ageController.text = age;
        }
        if (userData['pref_location'] != null &&
            userData['pref_location']!.isNotEmpty) {
          prefLocation = userData['pref_location']!;
          locationController.text = prefLocation;
          if (locationOptions.contains(prefLocation)) {
            selectedLocation = prefLocation;
          } else {
            selectedLocation = "Adrar";
          }
        }
        if (userData['email'] != null && userData['email']!.isNotEmpty) {
          email = userData['email']!;
        }
        if (userData['exp'] != null && userData['exp']!.isNotEmpty) {
          experience = int.tryParse(userData['exp']!) ?? 3;
          experienceController.text = experience.toString();
        }
        if (userData['bio'] != null && userData['bio']!.isNotEmpty) {
          bio = userData['bio']!;
          bioController.text = bio;
        }
        if (userData['photo'] != null && userData['photo']!.isNotEmpty) {
          profileImageUrl = userData['photo']!;
          print('profileImageUrl: $profileImageUrl');
        }
      });
    }
  }

  @override
  void dispose() {
    fullnameController.dispose();
    ageController.dispose();
    locationController.dispose();
    bioController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  Future<void> chooseImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  // Show popup dialog to edit full name
  Future<void> _showEditNameDialog() async {
    TextEditingController tempController =
        TextEditingController(text: fullname);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Full Name'),
          content: TextField(
            controller: tempController,
            decoration: const InputDecoration(
              labelText: "Full Name",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (tempController.text.trim().isNotEmpty) {
                  setState(() {
                    fullname = tempController.text.trim();
                    fullnameController.text = fullname;
                  });
                  Navigator.of(context).pop();
                } else {
                  _showErrorSnackBar('Please enter a valid name');
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Show popup dialog to edit age
  Future<void> _showEditAgeDialog() async {
    TextEditingController tempController = TextEditingController(text: age);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Age'),
          content: TextField(
            controller: tempController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Age",
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final ageValue = int.tryParse(tempController.text);
                if (ageValue != null && ageValue >= 18 && ageValue <= 65) {
                  setState(() {
                    age = tempController.text;
                    ageController.text = age;
                  });
                  Navigator.of(context).pop();
                } else {
                  _showErrorSnackBar('Please enter a valid age (18-65)');
                }
              },
            ),
          ],
        );
      },
    );
  }

  bool _validateInputs() {
    if (fullnameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your full name');
      return false;
    }

    final ageValue = int.tryParse(ageController.text);
    if (ageValue == null || ageValue < 18 || ageValue > 65) {
      _showErrorSnackBar('Please enter a valid age (18-65)');
      return false;
    }

    if (locationController.text.trim().isEmpty) {
      _showErrorSnackBar('Please select your wilaya');
      return false;
    }

    final expValue = int.tryParse(experienceController.text);
    if (expValue == null || expValue < 0) {
      _showErrorSnackBar('Please enter valid experience (0 or more years)');
      return false;
    }

    if (bioController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your bio');
      return false;
    }

    return true;
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

  Future<void> updateProfile() async {
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      const url = 'http://192.168.8.102:4000/updateBabysitterProfile';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        _showErrorSnackBar(
            'Authentication token not found. Please login again.');
        setState(() {
          isLoading = false;
        });
        return;
      }

      experience = int.tryParse(experienceController.text) ?? 3;

      final body = {
        "fullname": fullnameController.text.trim(),
        "age": int.tryParse(ageController.text) ?? 25,
        "pref_location": locationController.text.trim(),
        "exp": experience,
        "age_grps": ageGroups,
        "profilePhoto": profileImageUrl,
        "bio": bioController.text.trim()
      };

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await _saveUpdatedDataToPrefs(responseData['babysitter']);
        _showSuccessSnackBar('Profile updated successfully!');
      } else if (response.statusCode == 401) {
        _showErrorSnackBar('Authentication failed. Please login again.');
      } else if (response.statusCode == 404) {
        _showErrorSnackBar('Babysitter profile not found.');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to update profile';
        _showErrorSnackBar('Error: $errorMessage');
      }
    } catch (e) {
      debugPrint("❌ Error updating profile: $e");
      _showErrorSnackBar(
          'Network error. Please check your connection and try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveUpdatedDataToPrefs(
      Map<String, dynamic> babysitterData) async {
    final prefs = await SharedPreferences.getInstance();

    if (babysitterData['fullname'] != null) {
      await prefs.setString('fullname', babysitterData['fullname']);
    }
    if (babysitterData['age'] != null) {
      await prefs.setString('age', babysitterData['age'].toString());
    }
    if (babysitterData['pref_location'] != null) {
      await prefs.setString('pref_location', babysitterData['pref_location']);
    }
    if (babysitterData['exp'] != null) {
      await prefs.setString('exp', babysitterData['exp'].toString());
    }
    if (babysitterData['bio'] != null) {
      await prefs.setString('bio', babysitterData['bio']);
    }
    if (babysitterData['profilePhoto'] != null) {
      await prefs.setString('photo', babysitterData['profilePhoto']);
    }
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
              "Select Wilaya",
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
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildExperienceSection(),
                  const SizedBox(height: 16),
                  _buildPreferences(),
                  const SizedBox(height: 16),
                  _buildBioSection(),
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
            icon: Icon(Icons.settings, color: Colors.blue.shade900, size: 28),
            onPressed: () {
              AppNavigator.push(context, const SettingsPagetottrust());
            },
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.blue.shade900, size: 28),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
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
          // Enhanced profile image with add icon and network loading
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue.shade300,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: imageFile != null
                      ? Image.file(
                          imageFile!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          profileImageUrl.replaceAll(
                              'localhost', '192.168.8.102'),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                ),
              ),
              // Add icon overlay
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: chooseImage,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isUploadingImage
                        ? const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Simple Clickable Full Name
                GestureDetector(
                  onTap: _showEditNameDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fullname,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Simple Clickable Age
                GestureDetector(
                  onTap: _showEditAgeDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$age years old",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Change Photo Button
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Experience",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 8),
        TextField(
          controller: experienceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Years of Experience",
            border: OutlineInputBorder(),
            suffixText: "years",
          ),
          onChanged: (value) {
            experience = int.tryParse(value) ?? 3;
          },
        ),
      ],
    );
  }

  Widget _buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Preferences",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 8),
        _buildDropdownField(
          "Age Group",
          ageGroupOptions,
          selectedAgeGroup,
          (value) {
            if (value != null) {
              setState(() {
                selectedAgeGroup = value;
                ageGroups = [selectedAgeGroup];
              });
            }
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          "Preferred Wilaya",
          locationOptions,
          selectedLocation,
          (value) {
            if (value != null) {
              setState(() {
                selectedLocation = value;
                locationController.text = selectedLocation;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Bio",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 8),
        TextField(
          controller: bioController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Enter your bio",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : updateProfile,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: isLoading ? Colors.grey : Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 5,
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text("Updating...",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              )
            : const Text("Save Changes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
