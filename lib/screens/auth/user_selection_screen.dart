// lib/screens/auth/user_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/auth/blood_bank_registration_screen.dart';
import 'package:jeevandhara/screens/auth/donor_registration_screen.dart';
import 'package:jeevandhara/screens/auth/hospital_registration_screen.dart';
import 'package:jeevandhara/screens/auth/requester_registration_screen.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // Added AppBar for easier back navigation
        title: const Text('Choose Your Role'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'I am registering as a...',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 40.0),
            Wrap(
              spacing: 20.0,
              runSpacing: 20.0,
              alignment: WrapAlignment.center,
              children: <Widget>[
                _buildRoleButton(
                  context,
                  'assets/images/Requester_logo.png',
                  'Requester',
                  // FIX: Removed 'const' as registration screens are now stateful.
                  RequesterRegistrationScreen(),
                ),
                _buildRoleButton(
                  context,
                  'assets/images/Donor_logo.png',
                  'Donor',
                  DonorRegistrationScreen(),
                ),
                _buildRoleButton(
                  context,
                  'assets/images/Hospital_logo.png',
                  'Hospital',
                  HospitalRegistrationScreen(),
                ),
                _buildRoleButton(
                  context,
                  'assets/images/Blood_bank_logo.png',
                  'Blood Bank',
                  BloodBankRegistrationScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
      BuildContext context,
      String imagePath,
      String role,
      Widget page,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Column(
        children: <Widget>[
          Container(
            width: 120,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(child: Image.asset(imagePath, height: 50.0)),
          ),
          const SizedBox(height: 12.0),
          Text(
            role,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
