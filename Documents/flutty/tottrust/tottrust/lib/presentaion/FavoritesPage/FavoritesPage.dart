import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tottrust/presentaion/homepgaeformother/widgets.dart';

class FavoritePages extends StatefulWidget {
  const FavoritePages({super.key});

  @override
  State<FavoritePages> createState() => _FavoritePagesState();
}

class _FavoritePagesState extends State<FavoritePages> {
  @override
  void initState() {
    fetchSavedBabysitters();
    fetchFavoriteBabysitters();
    super.initState();
  }

  List<dynamic> favoriteBabysitters = [];
  String message = '';
  bool isLoading = true;

  bool showFavorites = true; // Toggle between "Favorite" and "Saved"
  List<dynamic> savedBabysitters = [];
  Future<void> fetchSavedBabysitters() async {
    const String url = 'http://192.168.8.102:4000/saved-babysitters';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          savedBabysitters = data;
          message = 'Successfully fetched ${data.length} babysitter(s).';
        });
        print("data $data");
        setState(() {
          var message = 'Successfully fetched ${data.length} babysitter(s).';
        });
      } else {
        final error = jsonDecode(response.body);
        String message;
        setState(() =>
            message = 'Error ${response.statusCode}: ${error['message']}');
      }
    } catch (e) {
      String message;
      setState(() => message = 'Exception: $e');
    }
  }

  Future<void> fetchFavoriteBabysitters() async {
    const String apiUrl = 'http://192.168.8.102:4000/favorite-babysitters';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          favoriteBabysitters = data;
          message = 'Fetched ${data.length} favorite babysitters.';
          isLoading = false;
        });
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          message = 'Error ${response.statusCode}: ${error['message']}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter tottrusts based on the toggle
    final filteredtottrusts = savedBabysitters;
    final filteredtottrustsfavorite = favoriteBabysitters;

    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FF),
      body: Column(
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

          const SizedBox(height: 16),
          // Toggle Buttons for "Favorite" and "Saved"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToggleButton("Favorite", showFavorites, true),
                const SizedBox(width: 8),
                _buildToggleButton("Saved", !showFavorites, false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // tottrust Cards
          Expanded(
            child: filteredtottrusts.isEmpty
                ? const Center(
                    child: Text(
                      "No tottrusts found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: showFavorites
                        ? filteredtottrustsfavorite.length
                        : filteredtottrusts.length,
                    itemBuilder: (context, index) {
                      final tottrust = showFavorites
                          ? filteredtottrustsfavorite[index]
                          : filteredtottrusts[index];
                      return tottrustCard(
                        name: tottrust['fullname'],
                        i: 3,
                        img:
                            'http://192.168.8.102:4000/${tottrust['profilePhoto']}',
                        isFavorite: false,
                        isSaved: false,
                        isOnline: false,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, bool toggleValue) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showFavorites = toggleValue;
          });
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFDE8F1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.pink : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
