import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AuthService {
  static const String baseUrl =
      'http://192.168.8.102:4000'; // Change to your actual API URL

  // Register mother with profile photo
  static Future<Map<String, dynamic>> registerMother({
    required String fullname,
    required String phoneNumber,
    required String email,
    required String password,
    File? profilePhoto,
    required String pref_location,
    required String preferred_age_groups,
  }) async {
    print('AuthService: Starting mother registration');
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/register_mother'),
      );
      print('AuthService: Created request to $baseUrl/register_mother');

      // Add text fields
      request.fields['fullname'] = fullname;
      request.fields['phone_number'] = phoneNumber;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['confirmPassword'] = password;
      request.fields['pref_location'] = pref_location;
      request.fields['preferred_age_groups'] = preferred_age_groups;
      print('AuthService: Request fields:');
      request.fields.forEach((key, value) {
        if (key != 'password' && key != 'confirmPassword') {
          print('$key: $value');
        }
      });

      // Add profile photo if available
      if (profilePhoto != null) {
        print('AuthService: Adding profile photo');
        final fileExtension = profilePhoto.path.split('.').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePhoto',
            profilePhoto.path,
            contentType: MediaType('image', fileExtension),
          ),
        );
        print('AuthService: Profile photo added successfully');
      }

      print('AuthService: Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print(
          'AuthService: Received response with status code: ${response.statusCode}');

      // Parse response
      final responseData = json.decode(response.body);
      print('AuthService: Response body: $responseData');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('AuthService: Registration successful');
        return {
          'success': true,
          'message': responseData['message'] ?? 'Registration successful',
          'data': responseData,
        };
      } else {
        print(
            'AuthService: Registration failed with status ${response.statusCode}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('AuthService: Error during registration: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
