// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tottrust/core/config/theme/widgets.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  String _errorMessage = '';
  Future<List<AcceptedRequest>>? _futureRequests;
  List<Map<String, dynamic>> babysittingRequests = [];

  @override
  void initState() {
    super.initState();
    // Initialize the requests future and fetch data
    _futureRequests = fetchAcceptedRequests();
    fetchBabysittingRequests();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _futureRequests = fetchAcceptedRequests();
    });
    await fetchBabysittingRequests();
  }

  // Function to fetch babysitting requests from API with retry logic
  Future<void> fetchBabysittingRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    int maxRetries = 3;
    int currentTry = 0;

    while (currentTry < maxRetries) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');

        if (token == null) {
          setState(() {
            _errorMessage = 'Authentication required. Please login again.';
            _isLoading = false;
          });
          return;
        }

        print('Fetching babysitting requests... Attempt ${currentTry + 1}');

        final response = await http.get(
          Uri.parse('http://192.168.8.102:4000/requests'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ).timeout(
          const Duration(seconds: 15), // Reduced timeout per attempt
          onTimeout: () {
            throw TimeoutException(
                'Connection timed out on attempt ${currentTry + 1}');
          },
        );

        print('API Response Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data == null || !data.containsKey('requests')) {
            throw FormatException('Invalid response format from server');
          }

          final List<dynamic> requests = data['requests'] as List;
          print('Fetched ${requests.length} requests');

          final List<Map<String, dynamic>> fetchedRequests =
              requests.map<Map<String, dynamic>>((request) {
            return {
              'id': request['_id'],
              'mother': request['mother'],
              'date': request['child']['babysittingDate']['date'].toString(),
              'startTime': request['child']['babysittingDate']['time'],
              'endTime': _calculateEndTime(
                  request['child']['babysittingDate']['time'],
                  request['child']['message']),
              'status': request['status'],
              'childrenCount': 1,
              'specialInstructions': request['child']['message'] ?? '',
              'childName': request['child']['name'],
              'childAge': request['child']['age'],
            };
          }).toList();

          setState(() {
            babysittingRequests = fetchedRequests;
            _isLoading = false;
            _errorMessage = '';
          });
          return; // Success - exit the retry loop
        } else if (response.statusCode == 401) {
          setState(() {
            _errorMessage = 'Authentication failed. Please login again.';
            _isLoading = false;
          });
          return; // Don't retry on auth failure
        } else {
          throw Exception(
              'Failed to load requests. Server returned ${response.statusCode}');
        }
      } catch (error) {
        print('Error on attempt ${currentTry + 1}: $error');
        currentTry++;

        if (currentTry >= maxRetries) {
          print('All retry attempts failed');
          setState(() {
            _errorMessage = error is TimeoutException
                ? 'Connection timed out. Please check your internet connection and try again.'
                : 'Failed to load requests. Please try again.';
            _isLoading = false;
          });
        } else {
          // Wait before retrying
          await Future.delayed(Duration(seconds: 2 * currentTry));
          continue;
        }
      }
    }
  }

  // Function to accept a babysitting request
  Future<void> acceptRequest(String requestId) async {
    // Implement API call to accept request
    // For now, just update the UI
    setState(() {
      // Remove the request from the list
      babysittingRequests.removeWhere((request) => request['id'] == requestId);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request accepted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Function to decline a babysitting request
  Future<void> declineRequest(String requestId) async {
    // Implement API call to decline request
    // For now, just update the UI
    setState(() {
      // Remove the request from the list
      babysittingRequests.removeWhere((request) => request['id'] == requestId);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request declined'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  // Helper method to calculate end time from start time and message
  String _calculateEndTime(String startTime, String message) {
    // Extract hours from message (assuming format like "... for 3 hours.")
    final RegExp hourRegex = RegExp(r'for (\d+) hours');
    final match = hourRegex.firstMatch(message);
    int hoursToAdd = 3; // Default to 3 hours if not specified

    if (match != null) {
      hoursToAdd = int.parse(match.group(1) ?? '3');
    }

    // Parse start time
    final List<String> timeParts = startTime.split(':');
    int startHour = int.parse(timeParts[0]);

    // Calculate end hour
    int endHour = (startHour + hoursToAdd) % 24;

    // Format end time
    return '${endHour.toString().padLeft(2, '0')}:00';
  }

  Future<void> refuseBabysittingRequest(String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      throw Exception('No access token – please log in again.');
    }

    final url =
        Uri.parse('http://192.168.8.102:4000/requests/$requestId/refuse');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw Exception('Request timed out'),
    );

    if (response.statusCode == 200) {
      // Optionally parse message:
      final body = jsonDecode(response.body);
      print('Refuse success: ${body['message']}');
    } else {
      final body = jsonDecode(response.body);
      throw Exception('Failed to refuse: ${body['error'] ?? 'Unknown error'}');
    }
  }

  Future<void> acceptBabysittingRequest(String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception("Access token not found. Please log in again.");
    }

    final url =
        Uri.parse('http://192.168.8.102:4000/requests/$requestId/accept');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Success: ${data['message']}");
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed: ${error['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print("Error accepting request: $e");
      rethrow;
    }
  }

  Future<void> _loadAcceptedRequests() async {
    try {
      // Get instance of SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Get the acceptedRequests string from storage
      final String? requestsJson = prefs.getString('acceptedRequests');

      if (requestsJson != null) {
        // Decode the JSON string to a List
        final List<dynamic> requests = json.decode(requestsJson);
        print('Found Accepted Requests in local storage:');
        print(const JsonEncoder.withIndent('  ')
            .convert(requests)); // Pretty print the JSON

        // You can also iterate through each request if you want
        for (var request in requests) {
          print('\nRequest Details:');
          print('ID: ${request['_id']}');
          print('Child Name: ${request['childName']}');
          print('Child Age: ${request['childAge']}');
          print('Date: ${request['babysittingDate']['date']}');
        }
      } else {
        print('No accepted requests found in local storage');
      }
    } catch (e) {
      print('Error loading accepted requests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildRequestsSection(),
                  const SizedBox(height: 20),
                  _buildUpcomingBookingsSection(),
                  const SizedBox(height: 10),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header with blue background and logo
  Widget _buildHeader() {
    return Stack(
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
            icon: Icon(Icons.arrow_back, color: Colors.blue.shade900, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.child_care,
              size: 50,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // Requests section
  Widget _buildRequestsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 15),
          child: Text(
            "Requests From Parents",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color.fromRGBO(83, 83, 83, 1)),
          ),
        ),
        _isLoading
            ? Container(
                height: 205,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF508CD4)),
                ),
              )
            : _errorMessage.isNotEmpty
                ? Container(
                    height: 205,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: fetchBabysittingRequests,
                            child: Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF508CD4),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : babysittingRequests.isEmpty
                    ? Container(
                        height: 205,
                        child: Center(
                          child: Text(
                            'No pending requests',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 210,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: babysittingRequests.length,
                          itemBuilder: (context, index) {
                            final request = babysittingRequests[index];
                            print("req: $request");
                            return RequestCard(
                              name: request['mother']['fullname'] ?? 'Unknown',
                              time: request['startTime'] ?? '',
                              description: request['specialInstructions'] ?? '',
                              onAccept: () async {
                                try {
                                  await acceptBabysittingRequest(request['id']);

                                  setState(() {
                                    babysittingRequests.removeWhere(
                                        (r) => r['id'] == request['id']);
                                  });
                                  await Future.delayed(
                                      Duration(milliseconds: 300));

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Request accepted successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              onDecline: () async {
                                try {
                                  await refuseBabysittingRequest(request['id']);
                                  setState(() {
                                    babysittingRequests.removeWhere(
                                        (r) => r['id'] == request['id']);
                                  });
                                  await Future.delayed(
                                      Duration(milliseconds: 300));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Request declined'),
                                      backgroundColor: Colors.grey,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
      ],
    );
  }

  // Upcoming bookings section
  Widget _buildUpcomingBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 15),
          child: Text(
            "Upcoming Bookings",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color.fromRGBO(83, 83, 83, 1),
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: FutureBuilder<List<AcceptedRequest>>(
            future: _futureRequests,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No upcoming bookings',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              final requests = snapshot.data!;

              return ListView.builder(
                itemCount: requests.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  final r = requests[i];
                  return Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: upcomingBook(
                        name: r.childName,
                        description: r.message,
                        date: DateFormat('dd/MM/yyyy').format(r.date),
                        time:
                            '${r.time.hour.toString().padLeft(2, '0')}:${r.time.minute.toString().padLeft(2, '0')}',
                        img: "img"),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}

Future<List<AcceptedRequest>> fetchAcceptedRequests() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token == null) {
    throw Exception('Access token not found. Please log in.');
  }

  final response = await http.get(
    Uri.parse('http://192.168.8.102:4000/requests/accepted'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  ).timeout(
    const Duration(seconds: 20),
    onTimeout: () => throw Exception('Connection timed out'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body)['acceptedRequests'] as List;
    print('dada: $data');
    return data
        .map((json) => AcceptedRequest.fromJson(json as Map<String, dynamic>))
        .toList();
  } else if (response.statusCode == 403) {
    throw Exception('Access denied: not a babysitter');
  } else {
    final err = json.decode(response.body);
    throw Exception('Error fetching accepted requests: ${err['message']}');
  }
}

class AcceptedRequest {
  final String id;
  final String motherId;
  final String motherName;
  final String motherPhone;
  final String babysitterId;
  final String babysitterName;
  final String babysitterPhone;
  final DateTime date;
  final TimeOfDay time;
  final String childName;
  final int childAge;
  final String message;

  AcceptedRequest({
    required this.id,
    required this.motherId,
    required this.motherName,
    required this.motherPhone,
    required this.babysitterId,
    required this.babysitterName,
    required this.babysitterPhone,
    required this.date,
    required this.time,
    required this.childName,
    required this.childAge,
    required this.message,
  });

  static DateTime _parseDate(String dateStr) {
    try {
      // First try to parse as ISO date
      return DateTime.parse(dateStr);
    } catch (e) {
      try {
        // If that fails, try DD/MM/YYYY format
        if (dateStr.contains('/')) {
          final parts = dateStr.split('/');
          if (parts.length >= 2) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year =
                parts.length > 2 ? int.parse(parts[2]) : DateTime.now().year;
            return DateTime(year, month, day);
          }
        }
        // If all else fails, return current date
        print('Warning: Could not parse date "$dateStr", using current date');
        return DateTime.now();
      } catch (e2) {
        print('Error parsing date "$dateStr": $e2');
        return DateTime.now();
      }
    }
  }

  static TimeOfDay _parseTime(dynamic timeData) {
    try {
      if (timeData is String) {
        if (timeData.contains(':')) {
          final timeParts = timeData.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
          return TimeOfDay(hour: hour, minute: minute);
        } else {
          // If it's just a number as string
          final hour = int.parse(timeData);
          return TimeOfDay(hour: hour, minute: 0);
        }
      } else if (timeData is int) {
        return TimeOfDay(hour: timeData, minute: 0);
      } else {
        print('Warning: Unknown time format "$timeData", using 12:00');
        return const TimeOfDay(hour: 12, minute: 0);
      }
    } catch (e) {
      print('Error parsing time "$timeData": $e');
      return const TimeOfDay(hour: 12, minute: 0);
    }
  }

  factory AcceptedRequest.fromJson(Map<String, dynamic> json) {
    try {
      // Handle the date and time from babysittingDate
      final dateStr = json['child']['babysittingDate']['date'];
      final parsedDate = _parseDate(dateStr);

      // Handle time which might come as integers or strings
      final timeData = json['child']['babysittingDate']['time'];
      final parsedTime = _parseTime(timeData);

      return AcceptedRequest(
        id: json['_id'] ?? '',
        motherId: json['mother']?['_id'] ?? '',
        motherName: json['mother']?['fullname'] ?? 'Unknown',
        motherPhone: json['mother']?['phone_number'] ?? 'No phone',
        babysitterId: json['babysitter']?['_id'] ?? '',
        babysitterName: json['babysitter']?['fullname'] ?? 'Unknown',
        babysitterPhone: json['babysitter']?['phone_number'] ?? 'No phone',
        date: parsedDate,
        time: parsedTime,
        childName: json['child']?['name'] ?? 'Unknown',
        childAge: json['child']?['age'] ?? 0,
        message: json['child']?['message'] ?? '',
      );
    } catch (e) {
      print('Error parsing AcceptedRequest: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class RequestCard extends StatelessWidget {
  final String name;
  final String description;
  final String time;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const RequestCard({
    Key? key,
    required this.name,
    required this.description,
    required this.time,
    this.onAccept,
    this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 5, bottom: 5, right: 5),
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Color(0xFF4A90E2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Name
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF4A90E2),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),

            // Age (extracted from description or default)
            Text(
              _extractAge(description),
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4A90E2),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),

            // Date row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Color(0xFFE74C3C),
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  _extractDate(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  color: Color(0xFF666666),
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onAccept,
                  child: Text(
                    'Accept',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(55, 95, 155, 1),
                    backgroundColor: Color.fromRGBO(195, 233, 255, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                ),
                ElevatedButton(
                  onPressed: onDecline,
                  child: Text(
                    'Decline',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(155, 55, 75, 1),
                    backgroundColor: Color.fromRGBO(239, 221, 222, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _extractAge(String description) {
    // Try to extract age from description, otherwise return default
    final ageRegex = RegExp(r'(\d+)\s*years?\s*old', caseSensitive: false);
    final match = ageRegex.firstMatch(description);
    if (match != null) {
      return '${match.group(1)} years old';
    }

    // Try to extract age range
    final rangeRegex =
        RegExp(r'(\d+)-(\d+)\s*years?\s*old', caseSensitive: false);
    final rangeMatch = rangeRegex.firstMatch(description);
    if (rangeMatch != null) {
      return '${rangeMatch.group(1)}-${rangeMatch.group(2)} years old';
    }

    return '0-3 years old'; // Default
  }

  String _extractDate() {
    // For now, return current date formatted as "Month Day"
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[now.month - 1]} ${now.day}';
  }

  String _formatTime(String time) {
    // Convert time to format like "5:00 PM-8:00 PM"
    if (time.isEmpty) return '5:00 PM-8:00 PM';

    try {
      // If time is in 24-hour format, convert to 12-hour
      if (time.contains(':')) {
        final parts = time.split(':');
        int hour = int.parse(parts[0]);
        int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

        String period = hour >= 12 ? 'PM' : 'AM';
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;

        String endTime = '${hour + 3}:${minute.toString().padLeft(2, '0')} PM';
        if (hour + 3 > 12) {
          endTime =
              '${(hour + 3) - 12}:${minute.toString().padLeft(2, '0')} PM';
        }

        return '${hour}:${minute.toString().padLeft(2, '0')} $period-$endTime';
      }
    } catch (e) {
      // If parsing fails, return default
    }

    return '5:00 PM-8:00 PM';
  }
}

class UpcomingBookingCard extends StatelessWidget {
  final String name;
  final String description;
  final String date;
  final String time;

  const UpcomingBookingCard({
    Key? key,
    required this.name,
    required this.description,
    required this.date,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(55, 95, 155, 1),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '$date at $time',
            style: TextStyle(
              fontSize: 12,
              color: Color.fromRGBO(138, 138, 138, 1),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(138, 138, 138, 1),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
