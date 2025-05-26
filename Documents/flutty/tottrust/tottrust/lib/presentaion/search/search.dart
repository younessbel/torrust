import 'package:tottrust/presentaion/home/pages/widgets/acc.dart';
import 'package:flutter/material.dart';

// Add a simple in-memory database for demonstration
class SearchDatabase {
  static List<Map<String, String>> _data = [
    {
      'name': 'Sunset Yoga',
      'description': 'A peaceful outdoor yoga session during sunset.',
      'date': '2025-06-10',
    },
    {
      'name': 'Tech Spark 2025',
      'description':
          'An innovation meetup for young developers and entrepreneurs.',
      'date': '2025-07-03',
    },
    {
      'name': 'Jazz Under the Stars',
      'description': 'Live jazz concert in the open air with local bands.',
      'date': '2025-08-14',
    },
    {
      'name': 'Green Earth Cleanup',
      'description':
          'Community event focused on park cleaning and planting trees.',
      'date': '2025-09-22',
    },
    {
      'name': 'Foodie Fiesta',
      'description':
          'A weekend of global cuisine, cooking demos, and food trucks.',
      'date': '2025-10-05',
    },
  ];

  static List<Map<String, String>> search(String query) {
    return _data
        .where((item) =>
            item['name']!.toLowerCase().contains(query.toLowerCase()) ||
            item['description']!.toLowerCase().contains(query.toLowerCase()) ||
            item['date']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = [];

  void _onSearchChanged(String query) {
    setState(() {
      _searchResults = query.isEmpty ? [] : SearchDatabase.search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              cursorColor: Colors.black,
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                    color: Colors.black), // Change hint text color to black
                fillColor: Colors.white,
                focusColor: Colors.white,
                prefixIconColor: Colors.black,
                hoverColor: Colors.black,
                prefixIcon: Icon(Icons.search,
                    color: Colors.black), // Change icon color to black
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: acc(
                            name: result['name'] ?? 'name',
                            description: result['description'] ?? 'description',
                            date: result['date'] ?? 'date'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
