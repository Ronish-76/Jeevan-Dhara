import 'package:flutter/material.dart';

import '../../../models/location_model.dart';

class FacilityDetailsSheet {
  static Future<void> show(
    BuildContext context, {
    required LocationModel facility,
    VoidCallback? onNavigate,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facility.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  facility.displayAddress,
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 24),
                if (facility.contactNumber != null) ...[
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Contact'),
                    subtitle: Text(facility.contactNumber!),
                  ),
                ],
                if (facility.inventory != null && facility.inventory!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Available Blood Types',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: facility.inventory!.entries.map((entry) {
                      return Chip(
                        label: Text('${entry.key}: ${entry.value}'),
                        backgroundColor: entry.value < 5
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                      );
                    }).toList(),
                  ),
                ],
                if (onNavigate != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Icons.navigation),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

