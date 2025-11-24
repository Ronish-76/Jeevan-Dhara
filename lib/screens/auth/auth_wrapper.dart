// lib/screens/auth/auth_wrapper.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';
import 'package:jeevandhara/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

// Import the *MainScreen* for each role that has a bottom navigation bar.
import 'package:jeevandhara/screens/donor/donor_main_screen.dart';
import 'package:jeevandhara/screens/hospital/hospital_main_screen.dart';
import 'package:jeevandhara/screens/blood_bank/blood_bank_main_screen.dart';
import 'package:jeevandhara/screens/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();

    // This StreamBuilder is the core of the wrapper. It rebuilds only
    // when the user's login state changes (login or logout).
    return StreamBuilder<User?>(
      stream: authViewModel.userStream,
      builder: (context, snapshot) {
        // While Firebase is checking the auth token, show a loading spinner.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If the stream has a User object, the user is logged in.
        if (snapshot.hasData) {
          final user = snapshot.data!;

          // Use a FutureBuilder to fetch the user's entire profile from Firestore.
          return FutureBuilder<Map<String, dynamic>?>(
            future: authViewModel.getUserProfile(user.uid),
            builder: (context, profileSnapshot) {
              // While fetching the profile, show a loading spinner.
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // If the profile doesn't exist or there was an error, something is wrong.
              // For safety, log the user out and send them to the login screen.
              if (profileSnapshot.hasError || !profileSnapshot.hasData) {
                // You could add a call to authViewModel.logout() here for extra safety.
                return const LoginScreen();
              }

              final profileData = profileSnapshot.data!;
              final role = profileData['role'] as String?;

              // Navigate to the correct main screen based on the fetched role.
              switch (role) {
                case 'donor':
                // For donors, we navigate to DonorMainScreen which contains the BottomNavBar.
                  return DonorMainScreen(user: user);

                case 'hospital':
                // FIX 2: Navigate to HospitalMainScreen instead of HospitalHomePage.
                  return HospitalMainScreen(user: user);

                case 'bloodBank':
                // FIX 3: Navigate to BloodBankMainScreen instead of BloodBankHomePage.
                // For blood banks, extract the facility details from the profile.
                  final facilityId = profileData['facilityId'] as String? ?? 'default_id';
                  final facilityName = profileData['facilityName'] as String? ?? 'Default Blood Bank';

                  // Pass all required arguments to the BloodBankMainScreen.
                  return BloodBankMainScreen(
                    user: user,
                    facilityId: facilityId,
                    facilityName: facilityName,
                  );

                case 'requester':
                  return MainScreen(user: user);

                default:
                // If the role in Firestore is invalid or missing, go to login.
                  return const LoginScreen();
              }
            },
          );
        }

        // If the stream has no user object, the user is logged out.
        return const LoginScreen();
      },
    );
  }
}
