import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/hospital/hospital_alerts_page.dart';
import 'package:jeevandhara/screens/hospital/hospital_home_page.dart';
import 'package:jeevandhara/screens/hospital/hospital_profile_page.dart';
// HospitalRequestsPage import removed

class HospitalMainScreen extends StatefulWidget {
  const HospitalMainScreen({super.key});

  @override
  State<HospitalMainScreen> createState() => _HospitalMainScreenState();
}

class _HospitalMainScreenState extends State<HospitalMainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HospitalHomePage(),
    // HospitalRequestsPage removed
    HospitalAlertsPage(),
    HospitalProfilePage(),
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
              // Requests item removed
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
