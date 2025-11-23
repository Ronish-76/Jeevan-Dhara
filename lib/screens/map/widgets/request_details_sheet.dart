import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../models/blood_request_model.dart';

import '../../../models/location_model.dart';

class RequestDetailsSheet {
  static Future<void> show(
    BuildContext context, {
    required BloodRequestModel request,
    UserRole? role,
    VoidCallback? onRespond,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.bloodType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: request.status == 'pending'
                            ? Colors.orange.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.status.toUpperCase(),
                        style: TextStyle(
                          color: request.status == 'pending'
                              ? Colors.orange.shade900
                              : Colors.green.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${request.units} units needed',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Requested by: ${request.requesterName}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 24),
                if (request.requesterContact.isNotEmpty) ...[
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Contact'),
                    subtitle: Text(request.requesterContact),
                    trailing: IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () => launchUrlString(
                        'tel:${request.requesterContact}',
                      ),
                    ),
                  ),
                ],
                if (request.notes != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Notes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(request.notes!),
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
                if (onRespond != null && role != null && role != UserRole.patient) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: onRespond,
                    icon: const Icon(Icons.bloodtype),
                    label: const Text('Respond to Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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

