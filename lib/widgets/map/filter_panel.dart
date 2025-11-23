import 'package:flutter/material.dart';

class FilterPanel extends StatelessWidget {
  final double radius;
  final ValueChanged<double> onRadiusChanged;
  final String? selectedBloodType;
  final ValueChanged<String?> onBloodTypeChanged;
  final String? selectedAvailability;
  final ValueChanged<String?> onAvailabilityChanged;
  final VoidCallback onApplyFilters;
  final bool showAvailabilityFilter;

  const FilterPanel({
    super.key,
    required this.radius,
    required this.onRadiusChanged,
    this.selectedBloodType,
    required this.onBloodTypeChanged,
    this.selectedAvailability,
    required this.onAvailabilityChanged,
    required this.onApplyFilters,
    this.showAvailabilityFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Filters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Radius filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Search Radius', style: theme.textTheme.bodyMedium),
                Chip(
                  label: Text('${radius.toStringAsFixed(0)} km'),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            Slider(
              min: 1,
              max: 30,
              divisions: 29,
              value: radius,
              onChanged: onRadiusChanged,
              label: '${radius.toStringAsFixed(0)} km',
              activeColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            // Blood type and availability filters
            Row(
              children: [
                Expanded(
                  child: _buildBloodTypeDropdown(context, theme, isDark),
                ),
                if (showAvailabilityFilter) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAvailabilityDropdown(context, theme, isDark),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onApplyFilters,
                icon: const Icon(Icons.search),
                label: const Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodTypeDropdown(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    return DropdownButtonFormField<String?>(
      value: selectedBloodType,
      decoration: InputDecoration(
        labelText: 'Blood Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
      ),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('Any')),
        ...bloodTypes.map(
          (type) => DropdownMenuItem<String?>(value: type, child: Text(type)),
        ),
      ],
      onChanged: onBloodTypeChanged,
    );
  }

  Widget _buildAvailabilityDropdown(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    const availabilityOptions = ['high', 'medium', 'low'];
    return DropdownButtonFormField<String?>(
      value: selectedAvailability,
      decoration: InputDecoration(
        labelText: 'Inventory',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
      ),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('Any')),
        ...availabilityOptions.map(
          (option) => DropdownMenuItem<String?>(
            value: option,
            child: Text(option.toUpperCase()),
          ),
        ),
      ],
      onChanged: onAvailabilityChanged,
    );
  }
}
