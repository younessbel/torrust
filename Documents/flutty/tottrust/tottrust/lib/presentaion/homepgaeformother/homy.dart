import 'package:flutter/material.dart';
import 'package:tottrust/presentaion/FavoritesPage/FavoritesPage.dart';
import 'package:tottrust/presentaion/chat/screens/chat_home_screen.dart';
import 'package:tottrust/presentaion/homepgaeformother/homepageparent.dart';
import 'package:tottrust/presentaion/profile_editinng/profile_parent.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    RecommendedBabysittersPage(),
    const FavoritePages(),
    ChatHomeScreen(
      userType: 'mother',
    ),
    ProfilePageBeforeEdittottrustm(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE7F0FF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(
              color: Color(0xFF4B7FD6),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF4B7FD6),
          unselectedItemColor: Color(0xFF4B7FD6),
          iconSize: 28,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon:
                  Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 1
                  ? Icons.favorite
                  : Icons.favorite_outline),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 2
                  ? Icons.chat_bubble
                  : Icons.chat_bubble_outline),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                  _selectedIndex == 3 ? Icons.person : Icons.person_outline),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
