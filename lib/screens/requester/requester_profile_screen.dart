import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';
import 'package:jeevandhara/screens/location_picker_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

class RequesterProfileScreen extends StatefulWidget {
  const RequesterProfileScreen({super.key});

  @override
  State<RequesterProfileScreen> createState() => _RequesterProfileScreenState();
}

class _RequesterProfileScreenState extends State<RequesterProfileScreen> {

  Future<void> _refreshProfile() async {
     final authProvider = Provider.of<AuthProvider>(context, listen: false);
     await authProvider.refreshUserProfile();
     setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
               // Language dialog removed from here as per request, moved to body
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: user == null
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      children: [
                        _buildProfileHeader(user),
                        _buildRequestStatistics(user.id!),
                        _buildInfoCard(
                          title: translate('personal_information'),
                          icon: Icons.person_outline,
                          details: {
                            translate('full_name'): user.fullName ?? '',
                            translate('email'): user.email ?? '',
                            translate('phone'): user.phone ?? '',
                          },
                        ),
                        _buildHospitalContactsCard(user),
                        _buildSettingsCard(context),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: () => _logout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              elevation: 0,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout),
                                const SizedBox(width: 8),
                                Text(
                                  translate('logout'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('change_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(translate('english')),
              onTap: () {
                changeLocale(context, 'en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(translate('nepali')),
              onTap: () {
                changeLocale(context, 'ne');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsCard(BuildContext context) {
    final currentLocale = LocalizedApp.of(context).delegate.currentLocale;
    final isNepali = currentLocale.languageCode == 'ne';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate('settings'), 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.language, color: Colors.grey, size: 20),
                  const SizedBox(width: 16),
                  Text(translate('language'), style: const TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  ToggleButtons(
                    isSelected: [!isNepali, isNepali],
                    onPressed: (int index) {
                       if (index == 0) {
                         changeLocale(context, 'en');
                       } else {
                         changeLocale(context, 'ne');
                       }
                    },
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey,
                    selectedColor: Colors.white,
                    fillColor: const Color(0xFFD32F2F),
                    constraints: const BoxConstraints(minHeight: 36, minWidth: 60),
                    children: const [
                      Text('English', style: TextStyle(fontSize: 12)),
                      Text('नेपाली', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showEditProfileDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    final hospitalNameController = TextEditingController(text: user?.hospital);
    final locationController = TextEditingController(
      text: user?.hospitalLocation ?? user?.location,
    );
    final phoneController = TextEditingController(text: user?.hospitalPhone);
    final formKey = GlobalKey<FormState>();

    // Variables to store coordinates if picked
    double? pickedLat = user?.latitude;
    double? pickedLng = user?.longitude;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Hospital Details'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Autocomplete<Map<String, dynamic>>(
                        initialValue: TextEditingValue(text: hospitalNameController.text),
                        optionsBuilder: (TextEditingValue textEditingValue) async {
                          if (textEditingValue.text.length < 2) {
                            return const Iterable<Map<String, dynamic>>.empty();
                          }
                          try {
                            final hospitals = await ApiService().searchHospitals(textEditingValue.text);
                            return hospitals.cast<Map<String, dynamic>>();
                          } catch (e) {
                            return const Iterable<Map<String, dynamic>>.empty();
                          }
                        },
                        displayStringForOption: (option) => option['hospitalName'] ?? '',
                        onSelected: (Map<String, dynamic> selection) {
                          hospitalNameController.text = selection['hospitalName'] ?? '';
                          
                          // Compose address from available fields
                          final address = selection['address'] ?? '';
                          final city = selection['city'] ?? '';
                          final district = selection['district'] ?? '';
                          final fullAddress = [address, city, district]
                              .where((s) => s.toString().isNotEmpty)
                              .join(', ');
                              
                          locationController.text = fullAddress.isNotEmpty 
                              ? fullAddress 
                              : (selection['address'] ?? '');
                              
                          phoneController.text = selection['phoneNumber'] ?? '';
                          
                          if (selection['latitude'] != null && selection['longitude'] != null) {
                             pickedLat = (selection['latitude'] as num).toDouble();
                             pickedLng = (selection['longitude'] as num).toDouble();
                          }
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Hospital Name',
                              suffixIcon: Icon(Icons.search),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                            onChanged: (value) {
                              hospitalNameController.text = value;
                            },
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: 250,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option['hospitalName'] ?? ''),
                                      subtitle: Text(option['address'] ?? ''),
                                      onTap: () {
                                        onSelected(option);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            labelText: 'Hospital Location',
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.map, color: Color(0xFFD32F2F)),
                        onPressed: () async {
                           final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LocationPickerScreen(),
                            ),
                          );
                          
                          if (result != null && result is Map) {
                             locationController.text = result['address'] ?? '';
                             pickedLat = result['latitude'];
                             pickedLng = result['longitude'];
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital Phone',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              bool isLoading = false;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          setState(() => isLoading = true);
                          try {
                            // Explicitly defining map type to avoid type inference issues
                            final Map<String, dynamic> updateData = {
                              'hospitalName': hospitalNameController.text,
                              'hospitalLocation': locationController.text,
                              'hospitalPhone': phoneController.text,
                              'location': locationController.text, // Also update base location
                            };
                            
                            // Add coordinates if available
                            if (pickedLat != null && pickedLng != null) {
                              updateData['latitude'] = pickedLat!;
                              updateData['longitude'] = pickedLng!;
                            }

                            final success = await authProvider.updateProfile(updateData);

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Profile updated successfully!',
                                  ),
                                ),
                              );
                            } else {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Update failed: ${authProvider.errorMessage}',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.only(top: 80, bottom: 30, left: 20, right: 20),
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
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 60, color: Color(0xFFD32F2F)),
          ),
          const SizedBox(height: 12),
          Text(
            user?.fullName ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Requester',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestStatistics(String userId) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService().getRequesterBloodRequests(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching stats'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '0',
                    translate('requests_made'),
                    Icons.add_alert_outlined,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    '0',
                    translate('requests_fulfilled'),
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
              ],
            ),
          );
        }

        final requests = (snapshot.data as List)
            .map((json) => BloodRequest.fromJson(json))
            .toList();

        final requestsMade = requests.length;
        final requestsFulfilled = requests
            .where((req) => req.status == 'fulfilled')
            .length;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  requestsMade.toString(),
                  translate('requests_made'),
                  Icons.add_alert_outlined,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  requestsFulfilled.toString(),
                  translate('requests_fulfilled'),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHospitalContactsCard(dynamic user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  color: Color(0xFFD32F2F),
                ),
                const SizedBox(width: 8),
                Text(
                  translate('hospital_contacts'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                  onPressed: _showEditProfileDialog,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildContactRow(
              Icons.business,
              translate('hospital'),
              user?.hospital ?? translate('not_set'),
            ),
            const SizedBox(height: 16),
            _buildContactRow(
              Icons.location_on_outlined,
              translate('location'),
              user?.hospitalLocation ?? user?.location ?? translate('add_location'),
            ),
            const SizedBox(height: 16),
            _buildContactRow(
              Icons.phone_outlined,
              translate('phone'),
              user?.hospitalPhone ?? translate('add_phone'),
            ),
             if (user?.latitude != null && user?.longitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _buildContactRow(
                  Icons.gps_fixed,
                  translate('coordinates'),
                  '${user!.latitude!.toStringAsFixed(4)}, ${user!.longitude!.toStringAsFixed(4)}',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return InkWell(
      onTap: _showEditProfileDialog,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFFD32F2F)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Map<String, String> details,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFD32F2F)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...details.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(color: Color(0xFF666666)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
