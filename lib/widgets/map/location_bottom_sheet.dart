import 'package:flutter/material.dart';
import 'package:jeevandhara/models/location_model.dart';
import 'package:jeevandhara/utils/maps_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationBottomSheet extends StatelessWidget {
  final LocationModel location;
  final UserRole role;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final VoidCallback? onTertiaryAction;

  const LocationBottomSheet({
    super.key,
    required this.location,
    required this.role,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.onTertiaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getIconColor(
                              location.type,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            location.type == LocationType.hospital
                                ? Icons.local_hospital
                                : Icons.water_drop,
                            color: _getIconColor(location.type),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location.displayAddress,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.grey[600]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Details
                    _buildDetailRow(
                      context,
                      Icons.phone,
                      'Contact',
                      location.contactNumber ?? 'Not available',
                      onTap: location.contactNumber != null
                          ? () =>
                                _makePhoneCall(context, location.contactNumber!)
                          : null,
                    ),
                    if (location.email != null)
                      _buildDetailRow(
                        context,
                        Icons.email,
                        'Email',
                        location.email!,
                      ),
                    if (location.distance != null)
                      _buildDetailRow(
                        context,
                        Icons.straighten,
                        'Distance',
                        MapsHelper.formatDistance(location.distance),
                      ),
                    const SizedBox(height: 16),
                    // Inventory
                    if (location.inventory != null &&
                        location.inventory!.isNotEmpty)
                      _buildInventorySection(context, theme),
                    // Blood types available
                    if (location.bloodTypesAvailable != null &&
                        location.bloodTypesAvailable!.isNotEmpty)
                      _buildBloodTypesSection(context, theme),
                    // Services
                    if (location.services != null &&
                        location.services!.isNotEmpty)
                      _buildServicesSection(context, theme),
                    const SizedBox(height: 20),
                    // Action buttons
                    _buildActionButtons(context, theme, isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildInventorySection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Inventory',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: location.inventory!.entries.map((entry) {
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                child: Text(
                  entry.value.toString(),
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              label: Text(entry.key),
              backgroundColor: Colors.red.shade50,
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBloodTypesSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Blood Types',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: location.bloodTypesAvailable!.map((type) {
            return Chip(
              label: Text(type),
              backgroundColor: Colors.blue.shade50,
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildServicesSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: location.services!.map((service) {
            return Chip(
              label: Text(service),
              backgroundColor: Colors.green.shade50,
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    final actions = _getRoleActions(role);

    return Column(
      children: [
        if (onPrimaryAction != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPrimaryAction,
              icon: Icon(actions.primaryIcon),
              label: Text(actions.primaryLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (onSecondaryAction != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSecondaryAction,
                  icon: Icon(actions.secondaryIcon),
                  label: Text(actions.secondaryLabel),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (onSecondaryAction != null && onTertiaryAction != null)
              const SizedBox(width: 12),
            if (onTertiaryAction != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTertiaryAction,
                  icon: Icon(actions.tertiaryIcon),
                  label: Text(actions.tertiaryLabel),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Color _getIconColor(LocationType type) {
    switch (type) {
      case LocationType.hospital:
        return Colors.red;
      case LocationType.bloodBank:
        return Colors.blue;
      case LocationType.donor:
        return Colors.green;
    }
  }

  void _makePhoneCall(BuildContext context, String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make phone call')),
        );
      }
    }
  }

  _RoleActions _getRoleActions(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return _RoleActions(
          primaryIcon: Icons.bloodtype,
          primaryLabel: 'Request Blood',
          secondaryIcon: Icons.directions,
          secondaryLabel: 'Directions',
          tertiaryIcon: Icons.info,
          tertiaryLabel: 'Details',
        );
      case UserRole.donor:
        return _RoleActions(
          primaryIcon: Icons.check_circle,
          primaryLabel: 'Accept Request',
          secondaryIcon: Icons.navigation,
          secondaryLabel: 'Navigate',
          tertiaryIcon: Icons.info,
          tertiaryLabel: 'Info',
        );
      case UserRole.hospital:
        return _RoleActions(
          primaryIcon: Icons.inventory,
          primaryLabel: 'Request Inventory',
          secondaryIcon: Icons.route,
          secondaryLabel: 'Track Route',
          tertiaryIcon: Icons.phone,
          tertiaryLabel: 'Contact',
        );
      case UserRole.bloodBank:
        return _RoleActions(
          primaryIcon: Icons.list_alt,
          primaryLabel: 'View Requests',
          secondaryIcon: Icons.local_shipping,
          secondaryLabel: 'Dispatch',
          tertiaryIcon: Icons.info,
          tertiaryLabel: 'Details',
        );
    }
  }
}

class _RoleActions {
  final IconData primaryIcon;
  final String primaryLabel;
  final IconData secondaryIcon;
  final String secondaryLabel;
  final IconData tertiaryIcon;
  final String tertiaryLabel;

  _RoleActions({
    required this.primaryIcon,
    required this.primaryLabel,
    required this.secondaryIcon,
    required this.secondaryLabel,
    required this.tertiaryIcon,
    required this.tertiaryLabel,
  });
}
