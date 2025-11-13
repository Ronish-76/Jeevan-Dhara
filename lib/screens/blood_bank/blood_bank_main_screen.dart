import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/blood_bank/blood_bank_alerts_page.dart';
import 'package:jeevandhara/screens/blood_bank/blood_bank_home_page.dart';
import 'package:jeevandhara/screens/blood_bank/blood_bank_profile_page.dart';
import 'package:jeevandhara/screens/blood_bank/track_requests_page.dart';

class BloodBankMainScreen extends StatefulWidget {
  const BloodBankMainScreen({super.key});

  @override
  State<BloodBankMainScreen> createState() => _BloodBankMainScreenState();
}

class _BloodBankMainScreenState extends State<BloodBankMainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    BloodBankHomePage(),
    TrackRequestsPage(),
    BloodBankAlertsPage(),
    BloodBankProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'Requests'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Alerts'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
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
