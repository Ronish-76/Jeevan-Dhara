import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog for creating blood request (Patient)
class BloodRequestDialog extends StatefulWidget {
  final String? selectedBloodType;
  final String? selectedUrgency;
  final String? initialLocationName;

  const BloodRequestDialog({
    super.key,
    this.selectedBloodType,
    this.selectedUrgency,
    this.initialLocationName,
  });

  @override
  State<BloodRequestDialog> createState() => _BloodRequestDialogState();
}

class _BloodRequestDialogState extends State<BloodRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _bloodType;
  int _quantity = 1;
  String _urgency = 'medium';
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloodType = widget.selectedBloodType;
    _urgency = widget.selectedUrgency ?? 'medium';
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bloodtype, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Request Blood',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (widget.initialLocationName != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(
                        0.3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.initialLocationName!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Blood Type
                DropdownButtonFormField<String>(
                  value: _bloodType,
                  decoration: InputDecoration(
                    labelText: 'Blood Type *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  ),
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _bloodType = value),
                  validator: (value) =>
                      value == null ? 'Please select blood type' : null,
                ),
                const SizedBox(height: 16),
                // Quantity
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity (units) *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: '1',
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter quantity';
                    final qty = int.tryParse(value);
                    if (qty == null || qty < 1)
                      return 'Quantity must be at least 1';
                    return null;
                  },
                  onSaved: (value) => _quantity = int.parse(value ?? '1'),
                ),
                const SizedBox(height: 16),
                // Urgency
                DropdownButtonFormField<String>(
                  value: _urgency,
                  decoration: InputDecoration(
                    labelText: 'Urgency *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  ),
                  items: [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(
                      value: 'critical',
                      child: Text('Critical'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _urgency = value ?? 'medium'),
                ),
                const SizedBox(height: 16),
                // Reason
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Additional Notes (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Navigator.of(context).pop({
                            'bloodType': _bloodType,
                            'quantity': _quantity,
                            'urgency': _urgency,
                            'reason': _reasonController.text.isEmpty
                                ? null
                                : _reasonController.text,
                            'notes': _notesController.text.isEmpty
                                ? null
                                : _notesController.text,
                          });
                        }
                      },
                      child: const Text('Request'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog for accepting request (Donor)
class AcceptRequestDialog extends StatefulWidget {
  final String requesterName;
  final String bloodType;
  final int quantity;
  final String urgency;
  final double? distance;

  const AcceptRequestDialog({
    super.key,
    required this.requesterName,
    required this.bloodType,
    required this.quantity,
    required this.urgency,
    this.distance,
  });

  @override
  State<AcceptRequestDialog> createState() => _AcceptRequestDialogState();
}

class _AcceptRequestDialogState extends State<AcceptRequestDialog> {
  final _notesController = TextEditingController();
  String? _selectedLocationId;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color urgencyColor;
    IconData urgencyIcon;
    switch (widget.urgency) {
      case 'critical':
        urgencyColor = Colors.red;
        urgencyIcon = Icons.emergency;
        break;
      case 'high':
        urgencyColor = Colors.orange;
        urgencyIcon = Icons.priority_high;
        break;
      case 'medium':
        urgencyColor = Colors.yellow.shade700;
        urgencyIcon = Icons.warning;
        break;
      default:
        urgencyColor = Colors.blue;
        urgencyIcon = Icons.info;
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: urgencyColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(urgencyIcon, color: urgencyColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accept Request',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.requesterName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Request details
              _buildDetailCard(
                context,
                Icons.bloodtype,
                'Blood Type',
                widget.bloodType,
              ),
              const SizedBox(height: 12),
              _buildDetailCard(
                context,
                Icons.inventory,
                'Quantity',
                '${widget.quantity} units',
              ),
              const SizedBox(height: 12),
              _buildDetailCard(
                context,
                urgencyIcon,
                'Urgency',
                widget.urgency.toUpperCase(),
                color: urgencyColor,
              ),
              if (widget.distance != null) ...[
                const SizedBox(height: 12),
                _buildDetailCard(
                  context,
                  Icons.straighten,
                  'Distance',
                  widget.distance! < 1
                      ? '${(widget.distance! * 1000).toStringAsFixed(0)} m'
                      : '${widget.distance!.toStringAsFixed(1)} km',
                ),
              ],
              const SizedBox(height: 24),
              // Notes
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'e.g., ETA, special instructions',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop({
                        'notes': _notesController.text.isEmpty
                            ? null
                            : _notesController.text,
                        'locationId': _selectedLocationId,
                      });
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Accept'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? theme.colorScheme.primaryContainer).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? theme.colorScheme.primaryContainer).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? theme.colorScheme.primary),
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
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for dispatch/manage supply (Blood Bank/Hospital)
class DispatchDialog extends StatefulWidget {
  final String destinationName;
  final String? bloodType;
  final int? quantity;
  final double? distance;

  const DispatchDialog({
    super.key,
    required this.destinationName,
    this.bloodType,
    this.quantity,
    this.distance,
  });

  @override
  State<DispatchDialog> createState() => _DispatchDialogState();
}

class _DispatchDialogState extends State<DispatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  int? _quantity;
  String? _bloodType;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
    _bloodType = widget.bloodType;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dispatch Supply',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.destinationName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.distance != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Distance: ${widget.distance! < 1 ? "${(widget.distance! * 1000).toStringAsFixed(0)} m" : "${widget.distance!.toStringAsFixed(1)} km"}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (_bloodType == null)
                  DropdownButtonFormField<String>(
                    value: _bloodType,
                    decoration: InputDecoration(
                      labelText: 'Blood Type *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    ),
                    items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _bloodType = value),
                    validator: (value) =>
                        value == null ? 'Please select blood type' : null,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bloodtype, color: Colors.red),
                        const SizedBox(width: 12),
                        Text(
                          'Blood Type: $_bloodType',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_bloodType != null) const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantity (units) *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: _quantity?.toString(),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter quantity';
                    final qty = int.tryParse(value);
                    if (qty == null || qty < 1)
                      return 'Quantity must be at least 1';
                    return null;
                  },
                  onSaved: (value) => _quantity = int.parse(value ?? '1'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Navigator.of(context).pop({
                            'bloodType': _bloodType ?? widget.bloodType,
                            'quantity': _quantity,
                            'notes': _notesController.text.isEmpty
                                ? null
                                : _notesController.text,
                          });
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Dispatch'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
