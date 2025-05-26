import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact.dart';
import '../models/message.dart';
import 'logger_service.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.8.102:4000';

  static Future<String?> getToken() async {
    LoggerService.logDebug(
        '🔑 Getting authentication token from SharedPreferences');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    LoggerService.logDebug(
        '🔑 Token status: ${token != null ? 'Found (${token.substring(0, 10)}...)' : 'Not found'}');
    return token;
  }

  static Future<String?> getCurrentUserId() async {
    LoggerService.logDebug('👤 Getting current user ID from SharedPreferences');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    LoggerService.logDebug(
        '👤 User ID status: ${userId != null ? 'Found ($userId)' : 'Not found'}');
    return userId;
  }

  static Future<void> setCurrentUserId(String userId) async {
    LoggerService.logDebug('👤 Setting current user ID: $userId');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);

    // Update the cached user ID in Message class
    Message.updateCachedUserId(userId);

    LoggerService.logSuccess('👤 User ID saved successfully');
  }

  static Future<void> setToken(String token) async {
    LoggerService.logDebug('🔑 Setting authentication token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    LoggerService.logSuccess('🔑 Token saved successfully');
  }

  static Future<Map<String, String>> getHeaders() async {
    LoggerService.logDebug('📋 Preparing HTTP headers');
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    LoggerService.logDebug('📋 Headers prepared: ${headers.keys.join(', ')}');
    return headers;
  }

  // Fetch contacts for mother - returns array of full mother objects
  static Future<List<Contact>> getMotherContacts() async {
    const url = '$baseUrl/mother/contacts';
    LoggerService.logInfo('👩 Fetching mother contacts');

    try {
      final headers = await getHeaders();
      LoggerService.logRequest('GET', url, headers, null);

      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      stopwatch.stop();

      LoggerService.logResponse(response.statusCode, url, response.body);
      LoggerService.logDebug(
          '⏱️ Request completed in ${stopwatch.elapsedMilliseconds}ms');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        LoggerService.logDebug('👩 Raw response data count: ${data.length}');
        LoggerService.logDebug('👩 Raw response: $data');

        List<Contact> contacts = [];

        // Convert each mother object to Contact with detailed error handling
        for (int i = 0; i < data.length; i++) {
          try {
            LoggerService.logDebug('👩 Processing num mother ${data.length}: ');
            print("data: $data");
            final motherData = data[i];
            print("motherData: $motherData");
            LoggerService.logDebug('👩 Processing mother $i: $motherData');

            // Validate required fields
            if (motherData == null) {
              LoggerService.logWarning(
                  '👩 Skipping null mother data at index $i');
              continue;
            }

            final id = motherData['_id']?.toString();
            final name = motherData['fullname']?.toString();

            if (id == null || id.isEmpty) {
              LoggerService.logWarning(
                  '👩 Skipping mother without ID at index $i');
              continue;
            }

            final contact = Contact.fromMother(motherData);
            contacts.add(contact);
            LoggerService.logDebug(
                '👩 Successfully added mother contact $i: ${contact.name} (${contact.id})');
          } catch (e, stackTrace) {
            LoggerService.logError(
                '👩 Failed to parse mother contact at index $i: $e',
                e,
                stackTrace);
            LoggerService.logDebug('👩 Problematic data: ${data[i]}');
            // Continue processing other contacts
          }
        }

        LoggerService.logSuccess(
            '👩 Successfully processed ${contacts.length} out of ${data.length} mother contacts');
        return contacts;
      } else {
        LoggerService.logError(
            '👩 Failed to load mother contacts - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load contacts - Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      LoggerService.logError(
          '👩 Error fetching mother contacts', e, stackTrace);
      throw Exception('Error fetching contacts: $e');
    }
  }

  // Fetch contacts for babysitter - returns array of full babysitter objects
  static Future<List<Contact>> getBabysitterContacts() async {
    const url = '$baseUrl/babysitter/contacts';
    LoggerService.logInfo('👶 Fetching babysitter contacts');

    try {
      final headers = await getHeaders();
      LoggerService.logRequest('GET', url, headers, null);

      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      stopwatch.stop();

      LoggerService.logResponse(response.statusCode, url, response.body);
      LoggerService.logDebug(
          '⏱️ Request completed in ${stopwatch.elapsedMilliseconds}ms');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        LoggerService.logDebug('👶 Raw response data count: ${data.length}');
        LoggerService.logDebug('👶 Raw response: $data');

        List<Contact> contacts = [];

        // Convert each babysitter object to Contact with detailed error handling
        for (int i = 0; i < data.length; i++) {
          try {
            final babysitterData = data[i];
            LoggerService.logDebug(
                '👶 Processing babysitter $i: $babysitterData');

            // Validate required fields
            if (babysitterData == null) {
              LoggerService.logWarning(
                  '👶 Skipping null babysitter data at index $i');
              continue;
            }

            final id = babysitterData['_id']?.toString();
            final name = babysitterData['fullname']?.toString();

            if (id == null || id.isEmpty) {
              LoggerService.logWarning(
                  '👶 Skipping babysitter without ID at index $i');
              continue;
            }

            final contact = Contact.fromBabysitter(babysitterData);
            contacts.add(contact);
            LoggerService.logDebug(
                '👶 Successfully added babysitter contact $i: ${contact.name} (${contact.id})');
          } catch (e, stackTrace) {
            LoggerService.logError(
                '👶 Failed to parse babysitter contact at index $i: $e',
                e,
                stackTrace);
            LoggerService.logDebug('👶 Problematic data: ${data[i]}');
            // Continue processing other contacts
          }
        }

        LoggerService.logSuccess(
            '👶 Successfully processed ${contacts.length} out of ${data.length} babysitter contacts');
        return contacts;
      } else {
        LoggerService.logError(
            '👶 Failed to load babysitter contacts - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load contacts - Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      LoggerService.logError(
          '👶 Error fetching babysitter contacts', e, stackTrace);
      throw Exception('Error fetching contacts: $e');
    }
  }

  // Helper method to populate contacts for testing
  static Future<void> populateMotherContacts() async {
    const url = '$baseUrl/mother/contacts/populate';
    LoggerService.logInfo('🔄 Populating mother contacts for testing');

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        LoggerService.logSuccess(
            '🔄 Contacts populated: ${data['count']} contacts');
      } else {
        LoggerService.logError(
            '🔄 Failed to populate contacts - Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      LoggerService.logError('🔄 Error populating contacts', e, stackTrace);
    }
  }

  // Load messages between two users using the correct endpoint format
  static Future<List<Message>> loadMessages(
      String currentUserId, String contactId) async {
    final url = '$baseUrl/messages/$currentUserId/$contactId';
    LoggerService.logInfo(
        '💬 Loading messages between $currentUserId and $contactId');

    try {
      final headers = await getHeaders();
      LoggerService.logRequest('GET', url, headers, null);

      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      stopwatch.stop();

      LoggerService.logResponse(response.statusCode, url, response.body);
      LoggerService.logDebug(
          '⏱️ Request completed in ${stopwatch.elapsedMilliseconds}ms');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final messages =
            data.map((messageData) => Message.fromJson(messageData)).toList();

        LoggerService.logSuccess(
            '💬 Successfully loaded ${messages.length} messages');

        return messages;
      } else {
        LoggerService.logError(
            '💬 Failed to load messages - Status: ${response.statusCode}');
        throw Exception(
            'Failed to load messages - Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      LoggerService.logError('💬 Error loading messages', e, stackTrace);
      throw Exception('Error loading messages: $e');
    }
  }

  // Get current user profile to set user ID
  static Future<void> getCurrentUserProfile() async {
    LoggerService.logInfo('👤 Getting current user profile to set user ID');

    try {
      final headers = await getHeaders();

      // Try mother endpoint first
      try {
        final motherResponse = await http.get(
          Uri.parse('$baseUrl/mother/profile'),
          headers: headers,
        );

        if (motherResponse.statusCode == 200) {
          final motherData = json.decode(motherResponse.body);
          final userId = motherData['_id'];
          if (userId != null) {
            await setCurrentUserId(userId);
            LoggerService.logSuccess(
                '👤 Set current user ID from mother profile: $userId');
            return;
          }
        }
      } catch (e) {
        LoggerService.logDebug(
            '👤 Mother profile not found, trying babysitter');
      }

      // Try babysitter endpoint
      try {
        final babysitterResponse = await http.get(
          Uri.parse('$baseUrl/babysitter/profile'),
          headers: headers,
        );

        if (babysitterResponse.statusCode == 200) {
          final babysitterData = json.decode(babysitterResponse.body);
          final userId = babysitterData['_id'];
          if (userId != null) {
            await setCurrentUserId(userId);
            LoggerService.logSuccess(
                '👤 Set current user ID from babysitter profile: $userId');
            return;
          }
        }
      } catch (e) {
        LoggerService.logDebug('👤 Babysitter profile not found');
      }

      LoggerService.logWarning(
          '👤 Could not get current user profile from either endpoint');
    } catch (e, stackTrace) {
      LoggerService.logError(
          '👤 Error getting current user profile', e, stackTrace);
    }
  }

  // Initialize user session
  static Future<void> initializeUserSession() async {
    LoggerService.logInfo('🎭 Initializing user session');

    // Initialize the Message class with current user ID
    await Message.initializeUserId();

    final currentUserId = await getCurrentUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      LoggerService.logInfo(
          '🎭 No current user ID found, attempting to get from profile');
      await getCurrentUserProfile();
    }

    final finalUserId = await getCurrentUserId();
    if (finalUserId == null || finalUserId.isEmpty) {
      LoggerService.logWarning('🎭 Still no user ID, creating temporary one');
      final tempUserId = 'temp-user-${DateTime.now().millisecondsSinceEpoch}';
      await setCurrentUserId(tempUserId);
      LoggerService.logSuccess('🎭 Created temporary user ID: $tempUserId');
    } else {
      LoggerService.logSuccess(
          '🎭 User session initialized with ID: $finalUserId');
    }
  }

  // Test API endpoints to help debug
  static Future<void> testApiEndpoints() async {
    LoggerService.logInfo('🧪 Testing API endpoints');

    final headers = await getHeaders();
    final testEndpoints = [
      '$baseUrl/mother/contacts',
      '$baseUrl/babysitter/contacts',
      '$baseUrl/mother/profile',
      '$baseUrl/babysitter/profile',
    ];

    for (String endpoint in testEndpoints) {
      try {
        final response = await http.get(Uri.parse(endpoint), headers: headers);
        LoggerService.logDebug('🧪 $endpoint: ${response.statusCode}');
        if (response.statusCode == 200) {
          final responseBody = response.body.length > 200
              ? '${response.body.substring(0, 200)}...'
              : response.body;
          LoggerService.logDebug('🧪 $endpoint response: $responseBody');
        }
      } catch (e) {
        LoggerService.logDebug('🧪 $endpoint: ERROR - $e');
      }
    }
  }
}
