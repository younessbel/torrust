import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      'http://192.168.8.102:4000'; // Change to your actual API URL

  // Login mother
  static Future<Map<String, dynamic>> loginMother({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/mother'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': identifier,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);
      print("responseData: $responseData");
      print("response.statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        print('herein 200');

        // Save tokens to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', responseData['access'] ?? '');
        await prefs.setString('email', responseData['information']['email']);
        await prefs.setString('userId', responseData['information']['_id']);
        await prefs.setString('bio', responseData['information']['bio'] ?? '');
        await prefs.setString('preferedloc',
            responseData['information']['pref_location'].toString() ?? '');
        await prefs.setString(
            'fullname', responseData['information']['fullname']);
        await prefs.setString(
            'preferencs',
            responseData['information']['preferred_age_groups'].toString() ??
                '');
        await prefs.setString(
            'phone_number', responseData['information']['phone_number']);
        await prefs.setString(
            'photo', responseData['information']['profilePhoto'] ?? '');
        await prefs.setString('refreshToken', responseData['refresh'] ?? '');

        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userId');
    await prefs.remove('profilePictureUrl');
    await prefs.remove('acceptedRequests');
  }

  // Get accepted requests from local storage
  static Future<List<dynamic>> getAcceptedRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final String? requestsJson = prefs.getString('acceptedRequests');
    if (requestsJson != null) {
      return json.decode(requestsJson) as List<dynamic>;
    }
    return [];
  }

  // Save accepted requests to local storage
  static Future<void> updateAcceptedRequests(List<dynamic> requests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('acceptedRequests', json.encode(requests));
    print('Updated accepted requests in storage: $requests');
  }

  // Add a new accepted request
  static Future<void> addAcceptedRequest(Map<String, dynamic> request) async {
    final requests = await getAcceptedRequests();
    requests.add(request);
    await updateAcceptedRequests(requests);
  }

  // Remove an accepted request by ID
  static Future<void> removeAcceptedRequest(String requestId) async {
    final requests = await getAcceptedRequests();
    requests.removeWhere((request) => request['_id'] == requestId);
    await updateAcceptedRequests(requests);
  }
}
