import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:image_picker/image_picker.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:tottrust/common/helper/navigation/app_navigation.dart";
import "package:tottrust/presentaion/settings_babysitter/pages/settings_page.dart";

class ProfilePageBeforeEdittottrustm extends StatefulWidget {
  const ProfilePageBeforeEdittottrustm({super.key});

  @override
  State<ProfilePageBeforeEdittottrustm> createState() =>
      _ProfilePageBeforeEdittottrustmState();
}

class _ProfilePageBeforeEdittottrustmState
    extends State<ProfilePageBeforeEdittottrustm> {
  // Declare all TextEditingController variables
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

    // Initialize all controllers
    fullnameController = TextEditingController(text: "Sarah Doe");
    ageController = TextEditingController(text: "25");
    locationController = TextEditingController(text: selectedLocation);
    bioController = TextEditingController(
      text:
          "Loving and experienced babysitter with a passion for child development.",
    );
    experienceController = TextEditingController(text: experience.toString());

    // Load user data after controllers are initialized
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

  @override
  void dispose() {
    // Dispose all controllers
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

  String convertImageToBase64(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes);
  }

  Future<Map<String, dynamic>> updateMotherProfile({
    required String token,
    required String fullname,
    required String prefLocation,
    required String preferredAgeGroups,
    required String bio,
    required String profilePhoto,
  }) async {
    final url = Uri.parse('http://192.168.8.102:4000/updateMotherProfile');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'fullname': fullname,
      'pref_location': prefLocation,
      'preferred_age_groups': preferredAgeGroups,
      'bio': bio,
      'profilePhoto': profilePhoto,
    });

    print('🔻 SENDING REQUEST TO: $url');
    print('📩 Headers: $headers');
    print('📤 Body: $body');

    final response = await http.put(
      url,
      headers: headers,
      body: body,
    );

    print('✅ Status Code: ${response.statusCode}');
    print('📨 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
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

  Widget _buildDropdownField(String label, List<String> options,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
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
              AppNavigator.push(context, SettingsPagetottrust());
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
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: imageFile != null
                ? FileImage(imageFile!)
                : NetworkImage(profileImageUrl) as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: fullnameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Age"),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: chooseImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Change Profile Photo"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Preferences",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildDropdownField("Age Group", ageGroupOptions, selectedAgeGroup,
            (value) {
          if (value != null) {
            setState(() {
              selectedAgeGroup = value;
              ageGroups = [selectedAgeGroup];
            });
          }
        }),
        const SizedBox(height: 16),
        _buildDropdownField(
            "Preferred Location", locationOptions, selectedLocation, (value) {
          if (value != null) {
            setState(() {
              selectedLocation = value;
              locationController.text = selectedLocation;
            });
          }
        }),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Bio",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        onPressed: isLoading
            ? null
            : () async {
                setState(() {
                  isLoading = true;
                });

                try {
                  final prefs = await SharedPreferences.getInstance();
                  final userToken = prefs.getString('accessToken') ?? '';

                  String base64Image = "";
                  if (imageFile != null) {
                    base64Image = convertImageToBase64(imageFile!);
                  }

                  final response = await updateMotherProfile(
                    token: userToken,
                    fullname: fullnameController.text.trim(),
                    prefLocation: selectedLocation,
                    preferredAgeGroups: selectedAgeGroup,
                    bio: bioController.text.trim(),
                    profilePhoto: base64Image,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(response['message'] ?? 'Profile updated')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Save Changes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
