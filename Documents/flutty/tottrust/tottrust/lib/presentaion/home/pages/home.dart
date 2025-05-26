import 'package:flutter/material.dart';
import 'package:tottrust/presentaion/baby_profile/baby_profile.dart';
import 'package:tottrust/presentaion/chat/screens/chat_home_screen.dart';
import 'package:tottrust/presentaion/home/pages/homepage.dart';
import 'package:tottrust/presentaion/profile/profile.dart';

class HomePages extends StatefulWidget {
  const HomePages({super.key});

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
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
    HomePage(),
    BabyProfileScreen(),
    ChatHomeScreen(
      userType: 'babysitter',
    ),
    ProfilePageBeforeEdittottrust(),
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
          color: Color.fromRGBO(195, 223, 255, 0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(
              color: Color(0xFFEFDDED),
              width: 2.5,
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
              icon: Icon(_selectedIndex == 1 ? Icons.add : Icons.add_outlined),
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
