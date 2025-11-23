// lib/screens/donor/donor_home_page.dart

import 'package:firebase_auth/firebase_auth.dart'; // FIX: Import Firebase Auth to recognize the User type.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/blood_request_model.dart';
import '../../viewmodels/auth_viewmodel.dart'; // Import AuthViewModel for logout
import '../../viewmodels/donor_viewmodel.dart';
import '../map/donor_request_map_screen.dart';

class DonorHomePage extends StatefulWidget {
  // FIX #1: Add a field to accept the logged-in user object.
  final User user;

  // FIX #2: Update the constructor to require the user object.
  const DonorHomePage({super.key, required this.user});

  @override
  State<DonorHomePage> createState() => _DonorHomePageState();
}

class _DonorHomePageState extends State<DonorHomePage> {
  @override
  void initState() {
    super.initState();
    // Load initial data when the screen is first built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonorViewModel>().loadUrgentRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final donorViewModel = context.watch<DonorViewModel>();
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        onRefresh: () => context.read<DonorViewModel>().loadUrgentRequests(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Pass the user object to the header to display dynamic data.
              _buildDonorHeader(widget.user),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildUrgentRequests(donorViewModel),
            ],
          ),
        ),
      ),
    );
  }

  // FIX #3: The header now takes the User object as a parameter.
  Widget _buildDonorHeader(User user) {
    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jeevan Dhara',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Logout button for user convenience
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  context.read<AuthViewModel>().logout();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // FIX #4: Display the user's actual display name or email.
          Text(
            'Welcome, ${user.displayName ?? user.email ?? 'Donor'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Thank you for being a lifesaver!',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Blood Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionCard(
                Icons.map_outlined,
                'View Map',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonorRequestMapScreen(
                        // FIX #5: Use the actual user data here.
                        donorId: widget.user.uid,
                        donorName: widget.user.displayName ?? 'Donor',
                        donorBloodType: 'O+', // This would come from your user profile in Firestore
                      ),
                    ),
                  );
                },
              ),
              _buildActionCard(Icons.bloodtype_outlined, 'Recent Requests'),
              _buildActionCard(
                Icons.arrow_forward_ios,
                'View All',
                isOutlined: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // _buildActionCard is fine, no changes needed.
  Widget _buildActionCard(
      IconData icon,
      String label, {
        bool isOutlined = false,
        VoidCallback? onTap,
      }) {
    // ... code is correct ...
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: isOutlined ? Colors.transparent : const Color(0xFFFFEBEE),
          child: Container(
            height: 100,
            decoration: isOutlined
                ? BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
            )
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFFD32F2F), size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _buildUrgentRequests is fine, no changes needed.
  Widget _buildUrgentRequests(DonorViewModel provider) {
    // ... code is correct ...
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Urgent Requests Nearby',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD32F2F),
                ),
              ),
              IconButton(
                onPressed: () =>
                    provider.loadUrgentRequests(useLocation: false),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (provider.isLoading && provider.urgentRequests.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (provider.urgentRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No urgent requests right now. Keep notifications on for updates.',
              ),
            )
          else
            ...provider.urgentRequests
                .take(4)
                .map((request) => _buildRequestCard(request, provider)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BloodRequestModel request, DonorViewModel provider) {
    final urgencyColor = request.urgency == 'critical'
        ? const Color(0xFFB71C1C)
        : const Color(0xFFD32F2F);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFFFEBEE),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD32F2F),
                  ),
                  child: Center(
                    child: Text(
                      // FIX #6: Use the correct property name from the model.
                      request.bloodGroup,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              request.locationName ?? 'Shared location',
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: urgencyColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.urgency?.toUpperCase() ?? request.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleRespond(context, provider, request),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('I Can Help'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FIX #7: Add the missing _handleRespond and _promptResponderDetails methods.
  Future<void> _handleRespond(
      BuildContext context,
      DonorViewModel provider,
      BloodRequestModel request,
      ) async {
    final details = await _promptResponderDetails(context);
    if (details == null) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Submitting response...')));
    try {
      await provider.respondToRequest(
        request: request,
        responderName: details['name']!,
        responderContact: details['contact'],
        notes: details['notes'],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Thanks! Request updated.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<Map<String, String?>?> _promptResponderDetails(BuildContext context) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<Map<String, String?>?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Responder Details'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact (optional)',
                ),
              ),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.of(ctx).pop({
                'name': nameController.text.trim(),
                'contact': contactController.text.trim().isEmpty
                    ? null
                    : contactController.text.trim(),
                'notes': notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              });
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
