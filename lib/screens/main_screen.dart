// lib/screens/main_screen.dart

import 'package:firebase_auth/firebase_auth.dart'; // FIX 1: Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:jeevandhara/models/location_model.dart';
import 'package:jeevandhara/screens/map/map_screen.dart';
import 'package:jeevandhara/screens/requester/requester_alerts_screen.dart';
import 'package:jeevandhara/screens/requester/requester_home_page.dart';
import 'package:jeevandhara/screens/requester/requester_profile_screen.dart';

class MainScreen extends StatefulWidget {
  // FIX 2: Add a field to accept the logged-in user.
  final User user;

  // FIX 3: Update the constructor to require the user.
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

<<<<<<< HEAD
  static const List<Widget> _widgetOptions = <Widget>[
    RequesterHomePage(),
    RequesterAlertsScreen(),
    RequesterProfileScreen(),
  ];
=======
  // FIX 4: The list is no longer static or const because it depends on the user object.
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Initialize the list of screens here, using the 'user' from the parent widget.
    _widgetOptions = <Widget>[
      // FIX 5: Pass the user object to the RequesterHomePage.
      RequesterHomePage(user: widget.user),
      MapScreen(role: UserRole.patient), // This is fine
      const RequesterAlertsScreen(),
      const RequesterProfileScreen(),
    ];
  }
>>>>>>> map-feature

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The rest of your build method is perfectly fine and needs no changes.
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
<<<<<<< HEAD
=======
                icon: Icon(Icons.search), // Changed from map to search
                label: 'Search',
              ),
              BottomNavigationBarItem(
>>>>>>> map-feature
                icon: Icon(Icons.notifications_none),
                label: 'Alerts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFFD32F2F),
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            showUnselectedLabels: true,
          ),
        ),
      ),
    );
  }
}
