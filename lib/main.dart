import 'dart:async';
import 'package:jeevandhara/screens/blood_bank/blood_bank_main_screen.dart';
import 'package:jeevandhara/screens/hospital/hospital_main_screen.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';

import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';
import 'package:jeevandhara/screens/main_screen.dart';
import 'package:jeevandhara/screens/donor/donor_main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeevan Dhara',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Artificial delay for splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.tryAutoLogin();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      final user = authProvider.user;
      if (user?.userType == 'requester') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (user?.userType == 'donor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DonorMainScreen()),
        );
      } else if (user?.userType == 'hospital') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HospitalMainScreen()),
        );
      } else if (user?.userType == 'blood_bank') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BloodBankMainScreen()),
        );
      } else {
        // Fallback to login if user type is unknown
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/jeevan_dhara_logo.png',
              height: 150.0,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Jeevan Dhara',
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12.0),
            const Text(
              'Connecting donors , saving lives',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
