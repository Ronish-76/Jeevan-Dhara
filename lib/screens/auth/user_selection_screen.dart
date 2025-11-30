import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/auth/blood_bank_registration_screen.dart';
import 'package:jeevandhara/screens/auth/donor_registration_screen.dart';
import 'package:jeevandhara/screens/auth/hospital_registration_screen.dart';
import 'package:jeevandhara/screens/auth/requester_registration_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              translate('register_as'),
              style: const TextStyle(
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
                _buildRoleButton(context, 'assets/images/Requester_logo.png', translate('requester'), const RequesterRegistrationScreen()),
                _buildRoleButton(context, 'assets/images/Donor_logo.png', translate('donor'), const DonorRegistrationScreen()),
                _buildRoleButton(context, 'assets/images/Hospital_logo.png', translate('hospital'), const HospitalRegistrationScreen()),
                _buildRoleButton(context, 'assets/images/Blood_bank_logo.png', translate('blood_bank'), const BloodBankRegistrationScreen()),
              ],
            ),
          ],
        ),
      ),
    );  
  }

  Widget _buildRoleButton(BuildContext context, String imagePath, String role, Widget page, {bool isSelected = false}) {
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
              color: isSelected ? const Color(0xFFD32F2F).withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: isSelected ? const Color(0xFFD32F2F).withOpacity(0.8) : Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                height: 50.0,
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            role,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? const Color(0xFFD32F2F) : const Color(0xFF333333),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
