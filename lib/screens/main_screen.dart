import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/requester/requester_alerts_screen.dart';
import 'package:jeevandhara/screens/requester/requester_home_page.dart';
import 'package:jeevandhara/screens/requester/requester_my_requests_screen.dart';
import 'package:jeevandhara/screens/requester/requester_profile_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Removed const to ensure rebuild on every build() call for translation
  List<Widget> get _widgetOptions => [
    RequesterHomePage(),
    RequesterMyRequestsScreen(),
    RequesterAlertsScreen(),
    RequesterProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This ensures the widget rebuilds when locale changes
    var localizationDelegate = LocalizedApp.of(context).delegate;
    
    return Scaffold(
      // Re-generating the widgets list on every build ensures they get the new locale
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
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: const Icon(Icons.home), label: translate('home')),
              BottomNavigationBarItem(
                icon: const Icon(Icons.list_alt_outlined),
                label: translate('requests'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.notifications_none),
                label: translate('alerts'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                label: translate('profile'),
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
