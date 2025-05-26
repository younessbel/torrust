import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.8.102:4000';

  // Login method for babysitters
  static Future<Map<String, dynamic>> loginBabysitter(
      String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/babysitter'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': identifier,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print("Response Data: $responseData");
        // Save user information to shared preferences
        final prefs = await SharedPreferences.getInstance();
        final userInfo = responseData['information'];
        print("userInfo: $userInfo");
        // Store basic user information
        await prefs.setString('userId', userInfo['_id']);
        await prefs.setString('email', userInfo['email']);
        await prefs.setString('fullname', userInfo['fullname']);
        await prefs.setString('phone_number', userInfo['phone_number']);

        // Store tokens
        await prefs.setString('access', responseData['access']);
        await prefs.setString('refreshToken', userInfo['refreshToken']);

        // Store profile photo
        if (userInfo['profilePhoto'] != null) {
          await prefs.setString('profilePhoto', userInfo['profilePhoto']);
        }

        // Store favorite babysitters as JSON string
        if (userInfo['favorite_babysitters'] != null) {
          await prefs.setString('favorite_babysitters',
              jsonEncode(userInfo['favorite_babysitters']));
        }

        // Store preferred age groups if present
        if (userInfo['preferred_age_groups'] != null) {
          await prefs.setString('preferred_age_groups',
              jsonEncode(userInfo['preferred_age_groups']));
        }

        print('✅ Stored user information:');
        print('👤 User ID: ${userInfo['_id']}');
        print('📧 Email: ${userInfo['email']}');
        print('📱 Phone: ${userInfo['phone_number']}');
        print(
            '💟 Favorites: ${userInfo['favorite_babysitters']?.length ?? 0} babysitters');

        return {
          'success': true,
          'message': responseData['message'],
          'accessToken': responseData['access'],
          'refreshToken': userInfo['refreshToken'],
          'userId': userInfo['_id'],
          'email': userInfo['email'],
          'fullname': userInfo['fullname'],
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Login failed: ${response.statusCode}',
          'statusCode': response.statusCode,
          'responseBody': responseData,
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Error: ${error.toString()}',
        'error': error.toString(),
      };
    }
  }

  // Get the current user's token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // Get the refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  // Get the profile picture URL
  static Future<String?> getProfilePictureUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profilePictureUrl');
  }

  static Future<String?> getwmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  // Refresh the access token using the refresh token
  static Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await prefs.setString('accessToken', responseData['access']);
        print('trrtr');
        // Save accepted requests
        print("dsdss ${responseData['information']['acceptedRequests']}");
        if (responseData['information']['acceptedRequests'] != null) {
          await prefs.setString('acceptedRequests',
              json.encode(responseData['information']['acceptedRequests']));
        }
        return true;
      } else {
        // If refresh token is invalid, clear all tokens
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  // Logout - clear all tokens
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This will remove all stored preferences
  }

  // Add getters for the new fields
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fullname');
  }

  static Future<List<String>> getFavoriteBabysitters() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorite_babysitters');
    if (favoritesJson != null) {
      final List<dynamic> favorites = jsonDecode(favoritesJson);
      return favorites.cast<String>();
    }
    return [];
  }

  static Future<String?> getProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profilePhoto');
  }
}
