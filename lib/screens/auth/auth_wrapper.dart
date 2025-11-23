import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';
import 'package:jeevandhara/screens/map/role_map_screen.dart';
import 'package:jeevandhara/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (authViewModel.currentUser == null) {
      return const LoginScreen();
    } else {
      final role = authViewModel.userRole;
      switch (role) {
        case 'patient':
          return const PatientMapScreen();
        case 'donor':
          return const DonorMapScreen();
        case 'hospital':
          return const HospitalMapScreen();
        case 'bloodBank':
          return const BloodBankMapScreen();
        default:
          // If role is unknown or not set, default to login
          return const LoginScreen();
      }
    }
  }
}
