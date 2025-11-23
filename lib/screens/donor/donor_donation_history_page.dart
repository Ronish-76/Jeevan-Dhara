import 'package:flutter/material.dart';

class DonorDonationHistoryPage extends StatefulWidget {
  const DonorDonationHistoryPage({super.key});

  @override
  State<DonorDonationHistoryPage> createState() =>
      _DonorDonationHistoryPageState();
}

class _DonorDonationHistoryPageState extends State<DonorDonationHistoryPage> {
  String _selectedYear = '2024';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('My Donation History'),
      ),
      body: Column(
        children: [
          _buildStatisticsHeader(),
          _buildAchievementBanner(),
          _buildYearFilter(),
          Expanded(child: _buildDonationList()),
        ],
      ),
    );
  }

  Widget _buildStatisticsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.white,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: '12',
            label: 'Donations',
            icon: Icons.bloodtype_outlined,
          ),
          _StatItem(value: '18', label: 'Units', icon: Icons.favorite_border),
          _StatItem(
            value: 'June 15',
            label: 'Next Eligible',
            icon: Icons.calendar_today_outlined,
            isDate: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.military_tech_outlined,
            color: Color(0xFFD32F2F),
            size: 32,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lifesaver Hero',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD32F2F),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You\'ve saved 36+ lives!',
                  style: TextStyle(color: Colors.black87, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearFilter() {
    final years = ['2024', '2023', '2022', 'All'];
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
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
        ),
      ),
    );
  }

  Widget _buildDonationList() {
    // Sample Data
    final donations = {
      '2024': [
        {
          'hospital': 'Bir Hospital, Kathmandu',
          'date': 'March 15, 2024',
          'units': 2,
          'group': 'A+',
        },
        {
          'hospital': 'Civil Hospital, Kathmandu',
          'date': 'January 02, 2024',
          'units': 1,
          'group': 'A+',
        },
      ],
      '2023': [
        {
          'hospital': 'Grande Hospital, Kathmandu',
          'date': 'October 20, 2023',
          'units': 1,
          'group': 'A+',
        },
      ],
    };

    final filteredDonations =
        (_selectedYear == 'All'
                ? donations.values.expand((x) => x)
                : donations[_selectedYear] ?? [])
            .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredDonations.length,
      itemBuilder: (context, index) {
        final donation = filteredDonations[index];
        return _buildTimelineTile(
          donation,
          index == 0,
          index == filteredDonations.length - 1,
        );
      },
    );
  }

  Widget _buildTimelineTile(
    Map<String, dynamic> donation,
    bool isFirst,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimelineIndicator(isFirst, isLast, donation['date'] as String),
          const SizedBox(width: 16),
          Expanded(child: _buildDonationCard(donation)),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator(bool isFirst, bool isLast, String date) {
    return Column(
      children: [
        if (!isFirst)
          Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD32F2F).withOpacity(0.8),
          ),
          child: Center(
            child: Text(
              date.substring(0, 3),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (!isLast)
          Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
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
                  Text(
                    donation['hospital'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    donation['date'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${donation['units']} Unit${donation['units'] > 1 ? 's' : ''}',
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD32F2F)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    donation['group'],
                    style: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
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

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    this.isDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD32F2F), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isDate ? 16 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
