import 'package:flutter/material.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/screens/donor/donor_blood_bank_screen.dart';
import 'package:jeevandhara/screens/donor/donor_hospitals_screen.dart';
import 'package:jeevandhara/screens/donor/donor_donation_history_page.dart';
import 'package:jeevandhara/screens/donor/donor_request_details_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_translate/flutter_translate.dart';

class DonorHomePage extends StatefulWidget {
  const DonorHomePage({super.key});

  @override
  State<DonorHomePage> createState() => _DonorHomePageState();
}

class _DonorHomePageState extends State<DonorHomePage> {
  late Future<List<BloodRequest>> _requestsFuture;
  late Future<List<BloodRequest>> _historyFuture;
  int _totalDonations = 0;
  int _totalUnits = 0;
  DateTime? _historyLastDonationDate;

  @override
  void initState() {
    super.initState();
    _refreshRequests();
    _refreshHistory();
  }

  Future<void> _refreshRequests() async {
    setState(() {
      _requestsFuture = _fetchRequests();
    });
  }

  Future<void> _refreshHistory() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      setState(() {
        _historyFuture = _fetchHistory(user.id!);
      });
    } else {
      setState(() {
        _historyFuture = Future.value([]);
      });
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _refreshRequests(),
      _refreshHistory(),
    ]);
  }

  Future<List<BloodRequest>> _fetchRequests() async {
    try {
      final data = await ApiService().getAllBloodRequests();
      return (data as List).map((e) => BloodRequest.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching requests: $e');
      return [];
    }
  }

  Future<List<BloodRequest>> _fetchHistory(String userId) async {
    try {
      final data = await ApiService().getDonorDonationHistory(userId);
      final requests = (data as List).map((e) => BloodRequest.fromJson(e)).toList();
      
      // Calculate stats
      int units = 0;
      int donationsCount = 0;
      DateTime? latestDate;

      for (var req in requests) {
        // Only count fulfilled requests as donations
        if (req.status == 'fulfilled') {
          units += req.units;
          donationsCount++;
          if (latestDate == null || req.createdAt.isAfter(latestDate)) {
            latestDate = req.createdAt;
          }
        }
      }
      
      // Update stats if mounted
      if (mounted) {
        setState(() {
          _totalDonations = donationsCount;
          _totalUnits = units;
          _historyLastDonationDate = latestDate;
        });
      }
      
      return requests;
    } catch (e) {
      debugPrint('Error fetching history: $e');
      return [];
    }
  }

  DateTime? get _effectiveLastDonationDate {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    DateTime? userDate = user?.lastDonationDate;
    
    if (_historyLastDonationDate != null) {
      if (userDate == null || _historyLastDonationDate!.isAfter(userDate)) {
        return _historyLastDonationDate;
      }
    }
    return userDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildDonorHeader(context),
              _buildEligibilityBanner(context),
              const SizedBox(height: 24),
              _buildStatsSection(), // Moved to top
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildUrgentRequestsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonorHeader(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
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
              Text(
                translate('app_name'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user?.bloodGroup ?? translate('n_a'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${translate('welcome')}, ${user?.fullName ?? translate('donor')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            translate('thank_you_lifesaver'),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEligibilityBanner(BuildContext context) {
    final lastDonation = _effectiveLastDonationDate;
    if (lastDonation == null) return const SizedBox.shrink();

    final nextEligibleDate = lastDonation.add(
      const Duration(days: 90),
    );
    if (DateTime.now().isAfter(nextEligibleDate))
      return const SizedBox.shrink();

    final difference = nextEligibleDate.difference(DateTime.now());
    final daysRemaining = difference.inDays;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  translate('waiting_period_active'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  translate('you_can_donate_again_in', args: {'days': daysRemaining}),
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            translate('quick_actions'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildActionCard(
                Icons.home_work_outlined, 
                translate('nearby_blood_banks'),
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DonorBloodBankScreen()), 
                  );
                }
              ),
              const SizedBox(width: 16),
              _buildActionCard(
                Icons.local_hospital, 
                translate('nearby_hospitals'),
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DonorHospitalsScreen()), 
                  );
                }
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String label, {
    bool isOutlined = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Widget _buildStatsSection() {
    // Use effective last donation date instead of just user profile data
    final lastDonation = _effectiveLastDonationDate;
    
    String eligibilityStatus = translate("eligible");
    String eligibilitySubtext = translate("status");
    Color statusColor = Colors.green; // Default eligible color

    if (lastDonation != null) {
      final nextEligibleDate = lastDonation.add(const Duration(days: 90));
      final now = DateTime.now();
      
      if (now.isBefore(nextEligibleDate)) {
        final difference = nextEligibleDate.difference(now);
        final daysRemaining = difference.inDays;
        
        int displayDays = daysRemaining;
        if (displayDays < 0) displayDays = 0; 
        
        // If less than 24 hours remaining but still future
        if (displayDays == 0 && now.isBefore(nextEligibleDate)) {
           displayDays = 1; 
        }
        
        eligibilityStatus = "$displayDays ${translate('days')}";
        eligibilitySubtext = translate("remaining");
        statusColor = Colors.orange; // Ineligible color
      } else {
         // If 3 months have passed
         eligibilityStatus = translate("eligible");
         eligibilitySubtext = translate("status");
         statusColor = Colors.green;
      }
    } else {
      // No last donation date means never donated
      eligibilityStatus = translate("eligible");
      eligibilitySubtext = translate("status");
      statusColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(value: '$_totalDonations', label: translate('donations'), icon: Icons.bloodtype_outlined),
              _buildStatItem(value: '$_totalUnits', label: translate('units'), icon: Icons.favorite_border),
              _buildStatItem(
                value: eligibilityStatus, 
                label: eligibilitySubtext, 
                icon: Icons.calendar_today_outlined, 
                isDate: true,
                valueColor: statusColor
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({required String value, required String label, required IconData icon, bool isDate = false, Color? valueColor}) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD32F2F), size: 24),
        const SizedBox(height: 8),
        Text(
          value, 
          style: TextStyle(
            fontSize: isDate ? 16 : 20, 
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black // Use custom color if provided
          )
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildUrgentRequestsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                translate('urgent_requests_nearby'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD32F2F),
                ),
              ),
              IconButton(onPressed: _refreshRequests, icon: const Icon(Icons.refresh, color: Color(0xFFD32F2F))),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<BloodRequest>>(
            future: _requestsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              
              final requests = snapshot.data;
              if (requests == null || requests.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(child: Text(translate('no_urgent_requests'))),
                );
              }

              // Filter only pending requests for urgent section
              final pendingRequests = requests.where((r) => r.status == 'pending').toList();

              if (pendingRequests.isEmpty) {
                 return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(child: Text(translate('no_urgent_requests'))),
                );
              }

              return Column(
                children: pendingRequests.map((request) => _buildRequestCard(request)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BloodRequest request) {
    final isUrgent = request.notifyViaEmergency;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonorRequestDetailsPage(request: request),
          ),
        ).then((_) => _refreshRequests()); // Refresh on return in case status changed
      },
      child: Card(
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
                          request.patientName,
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
                                request.hospitalName,
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
                      color: isUrgent
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFEF6C00), // Orange for standard
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isUrgent ? translate('urgent') : translate('request'),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonorRequestDetailsPage(request: request),
                      ),
                    ).then((_) => _refreshRequests());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(translate('i_can_help')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
