import 'package:flutter/material.dart';
import 'package:jeevandhara/models/location_model.dart';

class MarkerSheet extends StatelessWidget {
  final LocationModel location;
  final UserRole role;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;

  const MarkerSheet({
    super.key,
    required this.location,
    required this.role,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(location.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(location.displayAddress),
          const SizedBox(height: 16),
          if (location.inventory != null && location.inventory!.isNotEmpty)
            _buildInventory(context),
          if (location.bloodTypesAvailable != null &&
              location.bloodTypesAvailable!.isNotEmpty)
            _buildBloodTypes(context),
          if (location.distance != null)
            Text('Distance: ${_formatDistance(location.distance!)}'),
          if (location.contactNumber != null)
            Text('Phone: ${location.contactNumber}'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(_secondaryActionText),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onPrimaryAction,
                child: Text(_primaryActionText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Inventory:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: location.inventory!.entries.map((entry) {
            return Chip(
              label: Text('${entry.key}: ${entry.value} units'),
              backgroundColor: Colors.red.shade100,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBloodTypes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Blood Types:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: location.bloodTypesAvailable!.map((type) {
            return Chip(
              label: Text(type),
              backgroundColor: Colors.blue.shade100,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String get _primaryActionText {
    switch (role) {
      case UserRole.patient:
        return 'Request Blood';
      case UserRole.donor:
        return 'Accept Request';
      case UserRole.hospital:
        return 'Request Inventory';
      case UserRole.bloodBank:
        return 'View Requests';
    }
  }

  String get _secondaryActionText {
    switch (role) {
      case UserRole.patient:
        return 'Get Directions';
      case UserRole.donor:
        return 'Navigate';
      case UserRole.hospital:
        return 'Track Delivery';
      case UserRole.bloodBank:
        return 'Track Donor';
    }
  }
}
