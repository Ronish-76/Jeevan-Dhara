import 'package:flutter/material.dart';

class BloodBankPage extends StatelessWidget {
  const BloodBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Bank Portal'),
        backgroundColor: const Color(0xFFD32F2F),
      ),
      body: const Center(
        child: Text(
          'Blood Bank Functionality Coming Soon',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
