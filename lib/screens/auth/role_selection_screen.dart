// lib/screens/auth/role_selection_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeevandhara/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

// Import all the detailed registration screens
import 'donor_registration_screen.dart';
import 'hospital_registration_screen.dart';
import 'blood_bank_registration_screen.dart';
// Note: We don't need to import the RequesterRegistrationScreen if we complete it here.

class RoleSelectionScreen extends StatefulWidget {
  final User user;
  const RoleSelectionScreen({super.key, required this.user});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isLoading = false;

  Future<void> _selectRole(String role) async {
    final authViewModel = context.read<AuthViewModel>();

    // --- LOGIC FOR COMPLEX ROLES ---
    // If a role requires more information, navigate to its dedicated registration screen.
    // We can pass the initial data from the Google account to pre-fill the form.
    if (role == 'donor') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DonorRegistrationScreen(/* Pass initial data if the screen supports it */)));
      return;
    }
    if (role == 'hospital') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalRegistrationScreen()));
      return;
    }
    if (role == 'blood_bank') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => BloodBankRegistrationScreen()));
      return;
    }

    // --- LOGIC FOR SIMPLE ROLES (like 'requester') ---
    // If the role is simple, we can complete the registration right here.
    setState(() => _isLoading = true);
    try {
      await authViewModel.updateUserProfile(widget.user.uid, {'role': role});

      if (!mounted) return;

      // On success, show a message and pop back. The AuthWrapper will then detect
      // the role on its next check and navigate to the correct home screen.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ));

      // Pop all the way to the root, so the AuthWrapper re-evaluates.
      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.user.photoURL != null)
                CircleAvatar(backgroundImage: NetworkImage(widget.user.photoURL!), radius: 40),
              const SizedBox(height: 16),
              Text(
                'Welcome, ${widget.user.displayName ?? 'New User'}!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please select your primary role to continue.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // A more visually appealing list of roles
              _buildRoleButton(
                context: context,
                role: 'requester',
                title: 'I am a Requester',
                subtitle: 'Request blood for yourself or others.',
                icon: Icons.person_search,
              ),
              const SizedBox(height: 16),
              _buildRoleButton(
                context: context,
                role: 'donor',
                title: 'I am a Donor',
                subtitle: 'Donate blood and save lives.',
                icon: Icons.bloodtype,
              ),
              const SizedBox(height: 16),
              _buildRoleButton(
                context: context,
                role: 'hospital',
                title: 'I represent a Hospital',
                subtitle: 'Manage inventory and requests.',
                icon: Icons.local_hospital,
              ),
              const SizedBox(height: 16),
              _buildRoleButton(
                context: context,
                role: 'blood_bank',
                title: 'I represent a Blood Bank',
                subtitle: 'Manage donations and supply.',
                icon: Icons.home_work,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () => _selectRole(role),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          foregroundColor: const Color(0xFFD32F2F),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        icon: Icon(icon, size: 28),
        label: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
