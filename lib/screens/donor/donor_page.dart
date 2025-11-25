import 'package:flutter/material.dart';

class DonorPage extends StatelessWidget {
  const DonorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Page'),
      ),
      body: const Center(
        child: Text('This is the Donor Page'),
      ),
    );
  }
}
