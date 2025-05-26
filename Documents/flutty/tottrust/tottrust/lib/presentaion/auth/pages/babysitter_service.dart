import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BabysitterService {
  static const String baseUrl = 'http://192.168.8.102:4000';

  // Register a new babysitter
  static Future<Map<String, dynamic>> registerBabysitter({
    required String fullname,
    required String email,
    required String phone_number,
    required String age,
    required String pref_location,
    required String exp,
    required List<String> age_grps,
    required String national_card_number,
    required String password,
    required String confirmPassword,
    File? profilePhoto,
  }) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/register_babysitter'));

      // Add text fields
      request.fields['fullname'] = fullname;
      request.fields['email'] = email;
      request.fields['phone_number'] = phone_number;
      request.fields['age'] = age;
      request.fields['pref_location'] = pref_location;
      request.fields['exp'] = exp;
      request.fields['age_grps'] = jsonEncode(age_grps);
      request.fields['national_card_number'] = national_card_number;
      request.fields['password'] = password;
      request.fields['confirmPassword'] = confirmPassword;

      // Add profile photo if available
      if (profilePhoto != null) {
        final fileExtension =
            extension(profilePhoto.path).toLowerCase().replaceAll('.', '');
        final mimeType = 'image/$fileExtension';

        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePhoto',
            profilePhoto.path,
            contentType: MediaType('image', fileExtension),
          ),
        );
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Parse response
      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Registration successful',
          'profilePictureUrl': responseData['profilePicture'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ??
              'Registration failed: ${response.statusCode}',
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

  // Login babysitter
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
      print(responseData);
      if (response.statusCode == 200) {
        // Save tokens to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', responseData['access']);
        await prefs.setString('fullname', responseData['information']['fullname']);
        await prefs.setString('phone_number', responseData['information']['phone_number']);
        await prefs.setString('age', responseData['information']['age']);
        await prefs.setString('email', responseData['information']['email']);
        await prefs.setString('pref_location', responseData['information']['pref_location']);
        await prefs.setString('exp', responseData['information']['exp']);
        await prefs.setString('age_grps', responseData['information']['age_grps']);
    

        await prefs.setString('refreshToken', responseData['refresh']);
        await prefs.setString('ido', responseData['information']['_id']);

        // Save profile picture URL if available
        if (responseData['profilePicture'] != null) {
          await prefs.setString(
              'profilePictureUrl', responseData['profilePicture']);
        }
        print('object');
        // Print and save accepted requests
        if (responseData['information']['acceptedRequests'] != null) {
          // Print the accepted requests
          print('Accepted Requests from response:');
          print(const JsonEncoder.withIndent('  ')
              .convert(responseData['information']['acceptedRequests']));

          // Save to local storage
          await prefs.setString('acceptedRequests',
              json.encode(responseData['information']['acceptedRequests']));

          // Verify the save
          final savedRequests = prefs.getString('acceptedRequests');
          print('\nVerifying saved requests in local storage:');
          if (savedRequests != null) {
            print(const JsonEncoder.withIndent('  ')
                .convert(json.decode(savedRequests)));
          }
        } else {
          print('No accepted requests found in the response');
        }

        return {
          'success': true,
          'message': responseData['message'],
          'accessToken': responseData['access'],
          'refreshToken': responseData['refresh'],
          'profilePictureUrl': responseData['profilePicture'],
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

  // Logout - clear all tokens
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('profilePictureUrl');
  }
}
