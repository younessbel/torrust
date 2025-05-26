import "dart:io";

import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

class ProfilePage_parent extends StatefulWidget {
  const ProfilePage_parent({super.key});

  @override
  State<ProfilePage_parent> createState() => _ProfilePage_parentState();
}

class _ProfilePage_parentState extends State<ProfilePage_parent> {
  String firstDropdownValue = "I'm Babysitting for 0-3 years";
  String secondDropdownValue = "0-3 years old";
  String thirdDropdownValue = "At My Home";
  String bio = "Add a short bio about yourself";
  bool isEditingBio = false;
  File? imageFile;

  final TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bioController.text = bio;
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
                  decoration: BoxDecoration(
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
              _buildEditableRow("Manel EL-Ghali", "Name"),
              _buildEditableRow("32 years old", "Age"),
              _buildEditableRow("Algiers, Algeria", "Location"),
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
            _showEditDialog(context, text, (updatedText) {
              setState(() {
                // Update the field here
              });
            });
          },
        ),
      ],
    );
  }

  Widget _buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Preferences",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        _buildDropdown(
          value: firstDropdownValue,
          items: [
            "I'm Babysitting for 0-3 years",
            "I'm Babysitting for +3 years",
            "I'm a mother",
          ],
          onChanged: (value) {
            setState(() {
              firstDropdownValue = value!;
            });
          },
        ),
        const SizedBox(height: 8),
        _buildDropdown(
          value: secondDropdownValue,
          items: [
            "0-3 years old",
            "4-8 years old",
            "All ages",
          ],
          onChanged: (value) {
            setState(() {
              secondDropdownValue = value!;
            });
          },
        ),
        const SizedBox(height: 8),
        _buildDropdown(
          value: thirdDropdownValue,
          items: [
            "At My Home",
            "At Client's Home",
            "Both Options",
          ],
          onChanged: (value) {
            setState(() {
              thirdDropdownValue = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(195, 223, 255, 1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color.fromRGBO(195, 223, 255, 1),
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Center(child: Text(item)),
                  ))
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
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
                        setState(() {
                          bio = bioController.text;
                          isEditingBio = false;
                        });
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
        onPressed: () {
          // Handle save changes logic here
          print("Changes saved!");
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 5,
        ),
        child: const Text(
          "Save Changes",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String currentText, Function(String) onSave) {
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
                Navigator.of(context).pop();
              },
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
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
}
