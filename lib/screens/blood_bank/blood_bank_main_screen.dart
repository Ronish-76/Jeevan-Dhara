import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/blood_bank/blood_bank_alerts_page.dart';
import 'package:jeevandhara/screens/blood_bank/blood_bank_home_page.dart';
import 'package:jeevandhara/screens/blood_bank/blood_bank_profile_page.dart';
import 'package:flutter_translate/flutter_translate.dart';

class BloodBankMainScreen extends StatefulWidget {
  const BloodBankMainScreen({super.key});

  @override
  State<BloodBankMainScreen> createState() => _BloodBankMainScreenState();
}

class _BloodBankMainScreenState extends State<BloodBankMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    const BloodBankHomePage(),
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
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: const Icon(Icons.home), label: translate('home')),
              BottomNavigationBarItem(icon: const Icon(Icons.notifications_none), label: translate('alerts')),
              BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: translate('profile')),
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
