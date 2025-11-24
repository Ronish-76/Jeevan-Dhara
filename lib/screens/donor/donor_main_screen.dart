import 'package:firebase_auth/firebase_auth.dart'; // FIX1: Import Firebase Auth to recognize the User type.
import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/donor/donor_alerts_page.dart';
import 'package:jeevandhara/screens/donor/donor_home_page.dart';
import 'package:jeevandhara/screens/donor/donor_profile_page.dart';
import 'package:jeevandhara/screens/donor/donor_requests_page.dart';

class DonorMainScreen extends StatefulWidget {
  // FIX 2: Add a field to accept the logged-in user.
  final User user;

  // FIX 3: Update the constructor to require the user.
  const DonorMainScreen({super.key, required this.user});

  @override
  State<DonorMainScreen> createState() => _DonorMainScreenState();
}

class _DonorMainScreenState extends State<DonorMainScreen> {
  int _selectedIndex = 0;

  // FIX 4: The list of widgets is no longer static or const because it depends on the user.
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Initialize the list inside initState using the user from the parent widget.
    _widgetOptions = <Widget>[
      // FIX 5: Pass the user object to the DonorHomePage.
      DonorHomePage(user: widget.user),
      const DonorRequestsPage(),
      const DonorAlertsPage(),
      const DonorProfilePage(),
    ];
  }

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
                icon: Icon(Icons.list_alt_outlined),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
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
