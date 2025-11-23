// lib/screens/blood_bank/blood_bank_main_screen.dart

import 'package:firebase_auth/firebase_auth.dart'; // FIX1: Import Firebase Auth to recognize the User type.
import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/blood_bank/blood_bank_alerts_page.dart';
import 'package:jeevandhara/screens/blood_bank/blood_bank_home_page.dart';
import 'package:jeevandhara/screens/blood_bank/blood_bank_profile_page.dart';
import 'package:jeevandhara/screens/blood_bank/track_requests_page.dart';

class BloodBankMainScreen extends StatefulWidget {
  // FIX 2: Add a field to accept the logged-in user object.
  final User user;
  final String facilityId;
  final String facilityName;

  // FIX 3: Update the constructor to require the user object.
  const BloodBankMainScreen({
    super.key,
    required this.user,
    required this.facilityId,
    required this.facilityName,
  });

  @override
  State<BloodBankMainScreen> createState() => _BloodBankMainScreenState();
}

class _BloodBankMainScreenState extends State<BloodBankMainScreen> {
  int _selectedIndex = 0;

  // FIX 4: Update the _widgetOptions getter to include the user object.
  List<Widget> get _widgetOptions => <Widget>[
    BloodBankHomePage(
      // Pass all required parameters down to the home page.
      user: widget.user,
      facilityId: widget.facilityId,
      facilityName: widget.facilityName,
    ),
    const TrackRequestsPage(),
    const BloodBankAlertsPage(),
    const BloodBankProfilePage(),
  ];

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
