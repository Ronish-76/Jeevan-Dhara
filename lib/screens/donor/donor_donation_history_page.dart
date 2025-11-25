import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:intl/intl.dart';

class DonorDonationHistoryPage extends StatefulWidget {
  const DonorDonationHistoryPage({super.key});

  @override
  State<DonorDonationHistoryPage> createState() => _DonorDonationHistoryPageState();
}

class _DonorDonationHistoryPageState extends State<DonorDonationHistoryPage> {
  String _selectedYear = 'All'; // Default to All
  late Future<List<BloodRequest>> _historyFuture;
  int _totalDonations = 0;
  int _totalUnits = 0;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _historyFuture = _fetchHistory(user.id!);
    } else {
      _historyFuture = Future.error('User not logged in');
    }
  }

  Future<List<BloodRequest>> _fetchHistory(String userId) async {
    try {
      final data = await ApiService().getDonorDonationHistory(userId);
      final requests = (data as List).map((e) => BloodRequest.fromJson(e)).toList();
      
      // Calculate stats
      int units = 0;
      for (var req in requests) {
        units += req.units;
      }
      
      // Update stats if mounted
      if (mounted) {
        setState(() {
          _totalDonations = requests.length;
          _totalUnits = units;
        });
      }
      
      return requests;
    } catch (e) {
      debugPrint('Error fetching history: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('My Donation History'),
      ),
      body: FutureBuilder<List<BloodRequest>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final history = snapshot.data ?? [];
          
          return Column(
            children: [
              _buildStatisticsHeader(),
              _buildAchievementBanner(),
              _buildYearFilter(),
              Expanded(
                child: history.isEmpty 
                    ? const Center(child: Text("No donation history found yet."))
                    : _buildDonationList(history),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsHeader() {
    final user = Provider.of<AuthProvider>(context).user;
    String nextEligible = "Now";
    if (user?.lastDonationDate != null) {
      final nextDate = user!.lastDonationDate!.add(const Duration(days: 90));
      if (nextDate.isAfter(DateTime.now())) {
        nextEligible = DateFormat('MMM d').format(nextDate);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '$_totalDonations', label: 'Donations', icon: Icons.bloodtype_outlined),
          _StatItem(value: '$_totalUnits', label: 'Units', icon: Icons.favorite_border),
          _StatItem(value: nextEligible, label: 'Next Eligible', icon: Icons.calendar_today_outlined, isDate: true),
        ],
      ),
    );
  }

  Widget _buildAchievementBanner() {
    // Simple logic: 1 donation = 3 lives potentially saved
    final livesSaved = _totalDonations * 3;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.military_tech_outlined, color: Color(0xFFD32F2F), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lifesaver Hero', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
                const SizedBox(height: 4),
                Text('You\'ve saved $livesSaved+ lives!', style: const TextStyle(color: Colors.black87, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearFilter() {
    final currentYear = DateTime.now().year;
    final years = ['All', '$currentYear', '${currentYear - 1}', '${currentYear - 2}'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 35,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: years.length,
          itemBuilder: (context, index) {
            final year = years[index];
            final isSelected = _selectedYear == year;
            return ChoiceChip(
              label: Text(year),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedYear = year);
              },
              selectedColor: const Color(0xFFD32F2F),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade300)),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
        ),
      ),
    );
  }

  Widget _buildDonationList(List<BloodRequest> history) {
    // Filter by year
    final filteredHistory = _selectedYear == 'All' 
        ? history 
        : history.where((req) => req.createdAt.year.toString() == _selectedYear).toList();

    if (filteredHistory.isEmpty) {
       return const Center(child: Text("No donations in this period."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredHistory.length,
      itemBuilder: (context, index) {
        final request = filteredHistory[index];
        return _buildTimelineTile(request, index == 0, index == filteredHistory.length - 1);
      },
    );
  }

  Widget _buildTimelineTile(BloodRequest request, bool isFirst, bool isLast) {
    final dateStr = DateFormat('MMM d').format(request.createdAt);
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimelineIndicator(isFirst, isLast, dateStr),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDonationCard(request),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator(bool isFirst, bool isLast, String date) {
    return Column(
      children: [
        if (!isFirst) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
        Container(
          width: 35, // Widened for date
          height: 35,
          decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFD32F2F).withOpacity(0.8)),
          child: Center(child: Text(date, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
        ),
        if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildDonationCard(BloodRequest request) {
    final dateFull = DateFormat('MMMM d, yyyy').format(request.createdAt);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFFAFAFA),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.hospitalName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(dateFull, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(12)),
                      child: const Text('Completed', style: TextStyle(color: Colors.white, fontSize: 10))),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${request.units} Unit${request.units > 1 ? 's' : ''}'),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD32F2F)), borderRadius: BorderRadius.circular(12)),
                  child: Text(request.bloodGroup, style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value; 
  final String label; 
  final IconData icon;
  final bool isDate;

  const _StatItem({required this.value, required this.label, required this.icon, this.isDate = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD32F2F), size: 24),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: isDate ? 16 : 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
