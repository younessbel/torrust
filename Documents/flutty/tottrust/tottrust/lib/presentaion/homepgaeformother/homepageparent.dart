import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tottrust/common/helper/navigation/app_navigation.dart';
import 'package:tottrust/presentaion/chat/screens/chat_screen.dart';
import 'package:tottrust/presentaion/homepgaeformother/widgets.dart';
import 'package:tottrust/presentaion/homepgaeformother/widgets/rating_popup.dart';

class RecommendedBabysittersPage extends StatefulWidget {
  const RecommendedBabysittersPage({Key? key}) : super(key: key);

  @override
  State<RecommendedBabysittersPage> createState() =>
      _RecommendedBabysittersPageState();
}

class _RecommendedBabysittersPageState
    extends State<RecommendedBabysittersPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _recommendedBabysitters = [];
  List<Map<String, dynamic>> _filteredBabysitters = [];
  String _errorMessage = '';
  List getAcceptedRequestsString = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Search controller and variables
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchRecommendedBabysitters();
    _loadAcceptedRequests();

    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterBabysitters();
    });
  }

  void _filterBabysitters() {
    if (_searchQuery.isEmpty) {
      _filteredBabysitters = List.from(_recommendedBabysitters);
    } else {
      _filteredBabysitters = _recommendedBabysitters.where((babysitter) {
        final name = (babysitter['fullname'] ?? '').toLowerCase();
        final location = (babysitter['pref_location'] ?? '').toLowerCase();
        final bio = (babysitter['bio'] ?? '').toLowerCase();

        return name.contains(_searchQuery) ||
            location.contains(_searchQuery) ||
            bio.contains(_searchQuery);
      }).toList();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filteredBabysitters = List.from(_recommendedBabysitters);
    });
  }

  Future<void> _loadAcceptedRequests() async {
    print('tring');

    try {
      print('tring');
      final requests = await getAcceptedRequests();
      setState(() {
        getAcceptedRequestsString = requests;
      });
      print('Accepted Requests loaded: $getAcceptedRequestsString');
    } catch (e) {
      print('Error loading accepted requests: $e');
    }
  }

  static Future<List<dynamic>> getAcceptedRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final String? requestsJson = prefs.getString('acceptedRequests');

    if (requestsJson != null) {
      return json.decode(requestsJson) as List<dynamic>;
    }
    return [];
  }

  Future<void> sendBabysittingRequest({
    required String token,
    required String babysitterId,
    required String childName,
    required int childAge,
    required String date,
    required String time,
    required String message,
  }) async {
    final url =
        Uri.parse('http://192.168.8.102:4000/send-request/$babysitterId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': childName,
          'age': childAge,
          'date': date,
          'time': time,
          'message': message,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ ${data['message']}');
      } else {
        final error = jsonDecode(response.body);
        print('❌ Error: ${error['message']}');
      }
    } catch (e) {
      print('❗ Exception: $e');
    }
  }

  Future<void> _fetchRecommendedBabysitters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'You need to login first';
        });
        return;
      }

      // Make API request
      final response = await http.get(
        Uri.parse('http://192.168.8.102:4000/recommended-babysitters'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _recommendedBabysitters =
              data.map((item) => item as Map<String, dynamic>).toList();
          _filteredBabysitters = List.from(_recommendedBabysitters);
          _isLoading = false;
        });
      } else {
        final error = json.decode(response.body);
        setState(() {
          _isLoading = false;
          _errorMessage =
              error['message'] ?? 'Failed to load recommended babysitters';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection error: $e';
      });
    }
  }

  Future<void> pickDateTime(
      BuildContext ctx, Map<String, dynamic> babysitter) async {
    final date = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(Duration(days: 90)), // Allow booking up to 90 days ahead
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF508CD4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay(hour: 14, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF508CD4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });

    // Show confirmation dialog
    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Babysitter: ${babysitter['fullname']}'),
              SizedBox(height: 8),
              Text('Date: ${DateFormat('MMM dd, yyyy').format(date)}'),
              Text('Time: ${time.format(context)}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF508CD4),
                foregroundColor: Colors.white,
              ),
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _sendRequest(babysitter);
              },
            ),
          ],
        );
      },
    );
  }

  String buildIsoDateTime(DateTime date, TimeOfDay time) {
    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return DateFormat("yyyy-MM-ddTHH:mm:ss").format(dt);
  }

  Future<void> _sendRequest(Map<String, dynamic> babysitter) async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select date and time first')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login first')),
      );
      return;
    }

    try {
      await sendBabysittingRequest(
        token: token,
        babysitterId: babysitter['_id'],
        childName: babysitter['fullname'],
        childAge: babysitter['age'],
        date: buildIsoDateTime(_selectedDate!, _selectedTime!),
        time: '${_selectedTime!.hour}:${_selectedTime!.minute}',
        message: 'Please take care of her for 3 hours.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSearchField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search babysitters by name, location...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(
            Icons.search,
            color: Color(0xFF508CD4),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        style: TextStyle(fontSize: 16),
        onChanged: (value) {
          // The listener will handle this
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with baby image (same as in homepageparent.dart)
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
          SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 8),
                Text(
                  'Recommended For You',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // Search Field
          _buildSearchField(),

          // Search Results Info
          if (_searchQuery.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    'Found ${_filteredBabysitters.length} result${_filteredBabysitters.length != 1 ? 's' : ''} for "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 8),

          // Main content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Color(0xFF508CD4)),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
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
              onPressed: _fetchRecommendedBabysitters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF508CD4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredBabysitters.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No babysitters found for "$_searchQuery"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF508CD4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Clear Search'),
            ),
          ],
        ),
      );
    }

    if (_recommendedBabysitters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No recommended babysitters found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try updating your preferences or location',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Grid of babysitters (now using filtered list)
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(8),
      shrinkWrap: true,
      itemCount: _filteredBabysitters.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final babysitter = _filteredBabysitters[index];
        return _buildBabysitterCard(babysitter);
      },
    );
  }

  Widget _buildBabysitterCard(Map<String, dynamic> babysitter) {
    // Get profile image URL
    String? profilePhoto = babysitter['profilePhoto'];

    // Get rating
    final double rating = (babysitter['avgRating'] ?? 0).toDouble();
    print('dscsd$babysitter');
    return tottrustCard(
      onTapedit: () async {
        // Show the rating popup when edit button is tapped
        showRatingPopup(
          context,
          babysitter,
          onRatingSubmitted: () {
            // Refresh the babysitters list after rating is submitted
            _fetchRecommendedBabysitters();
          },
        );
      },
      onTapmess: () async {
        AppNavigator.push(
            context,
            ChatScreen(
                contactId: babysitter['_id'], name: babysitter['fullname']));
      },
      onTapadd: () async {
        // Show date/time picker when the add button is tapped
        await pickDateTime(context, babysitter);
      },
      onTaplike: () async {
        const String url = 'http://192.168.8.102:4000/add-favorite-babysitter';
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('accessToken');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Adding to favorites...')),
          );

          final response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'babysitterId': babysitter['_id'],
            }),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${data['message']}'),
                backgroundColor: Colors.green,
              ),
            );
            print('Success: ${data['message']}');
            print('Updated Favorites: ${data['favorites']}');
          } else {
            final error = jsonDecode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${error['message']}'),
                backgroundColor: Colors.red,
              ),
            );
            print('Failed: ${error['message']}');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error occurred: $e'),
              backgroundColor: Colors.red,
            ),
          );
          print('Error: $e');
        }
      },
      onTapsave: () async {
        const String url = 'http://192.168.8.102:4000/save-babysitter';
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('accessToken');

          if (token == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: Access token not found.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saving babysitter...')),
          );

          final response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'babysitterId': babysitter['_id']}),
          );

          final data = jsonDecode(response.body);

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${data['message']}'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${response.statusCode} - ${data['message']}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error occurred: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      name: babysitter['fullname'] ?? 'Unknown',
      i: rating.toInt(),
      img: profilePhoto != null
          ? "http://192.168.8.102:4000/$profilePhoto"
          : 'assets/images/girl1.png',
      isFavorite: true,
      isSaved: false,
      isOnline: false,
    );
  }

  Future<void> saveBabysitter(int idd) async {
    final String apiUrl = 'http://192.168.8.102:4000/save-babysitter';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'babysitterId': idd}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Success: ${data['message']}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${response.statusCode}: ${data['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
