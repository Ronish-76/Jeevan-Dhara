import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/blood_bank/blood_bank_page.dart';
import 'package:jeevandhara/screens/donor/donor_page.dart';
import 'package:jeevandhara/screens/hospital/hospital_page.dart';
import 'package:jeevandhara/screens/main_screen.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Select your role',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildRoleButton(context, 'assets/images/Requester_logo.png', 'Requester', const MainScreen()),
                _buildRoleButton(context, 'assets/images/Donor_logo.png', 'Donor', const DonorPage()),
                _buildRoleButton(context, 'assets/images/Hospital_logo.png', 'Hospital', const HospitalPage()),
                _buildRoleButton(context, 'assets/images/Blood_bank_logo.png', 'Blood Bank', const BloodBankPage()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String imagePath, String role, Widget page, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: isSelected ? Colors.red : Colors.grey[300]!,
                width: 2.0,
              ),
              color: isSelected ? Colors.red.withOpacity(0.1) : Colors.white,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              imagePath,
              height: 40.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            role,
            style: TextStyle(
              color: isSelected ? Colors.red : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
