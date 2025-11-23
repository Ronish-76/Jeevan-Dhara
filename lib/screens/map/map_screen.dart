import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jeevandhara/models/location_model.dart';
import 'package:jeevandhara/services/map_service.dart';
import 'package:jeevandhara/utils/maps_helper.dart';
import 'package:jeevandhara/widgets/marker_sheet.dart';
import 'package:shazzy_map/shazzy_map.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key, 
    required this.role,
    this.userId,
    this.userName,
    this.userPhone,
  });

  final UserRole role;
  final String? userId;
  final String? userName;
  final String? userPhone;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService _mapService = MapService();
  final ShazzyController _mapController = ShazzyController();

  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  List<LocationModel> _locations = [];
  List<ShazzyMarker> _markers = [];
  double _radiusKm = 10;
  String? _selectedBloodType;
  String? _selectedAvailability;

  static const LatLng _kathmanduCenter = LatLng(27.7172, 85.3240);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Location permission denied';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      setState(() => _currentPosition = position);

      // Camera update is handled by ShazzyMap initialPosition, 
      // but we can force it if needed once the map is ready.
      // For now, we just fetch locations.
      await _fetchLocations(position);
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to fetch locations: $e';
        _isLoading = false;
      });
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _fetchLocations(Position? position) async {
    if (position == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _mapService.getNearbyLocations(
        latitude: position.latitude,
        longitude: position.longitude,
        role: widget.role,
        radius: _radiusKm,
        bloodType: _selectedBloodType,
        availability: _selectedAvailability,
        limit: 25,
      );

      setState(() {
        _locations = results;
        _markers = _buildMarkers(results);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ShazzyMarker> _buildMarkers(List<LocationModel> locations) {
    return locations.map((location) {
      return ShazzyMarker(
        id: location.id,
        position: LatLng(location.latitude, location.longitude),
        title: location.name,
        snippet: MapsHelper.formatDistance(location.distance),
        type: _getMarkerType(location.type),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          location.type == LocationType.hospital
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueAzure,
        ),
        onTap: () => _showMarkerSheet(location),
      );
    }).toList();
  }

  ShazzyMarkerType _getMarkerType(LocationType type) {
    switch (type) {
      case LocationType.hospital:
        return ShazzyMarkerType.hospital;
      case LocationType.bloodBank:
        return ShazzyMarkerType.bloodBank;
      case LocationType.donor:
        return ShazzyMarkerType.donor;
      default:
        return ShazzyMarkerType.unknown;
    }
  }

  void _showMarkerSheet(LocationModel location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => MarkerSheet(
        location: location,
        role: widget.role,
        onPrimaryAction: () {
          Navigator.of(context).pop();
          _handlePrimaryAction(location);
        },
        onSecondaryAction: () {
          Navigator.of(context).pop();
          _handleSecondaryAction(location);
        },
      ),
    );
  }

  void _handlePrimaryAction(LocationModel location) async {
    if (widget.role == UserRole.patient) {
      await _requestBlood(location);
    } else {
      final action = switch (widget.role) {
        UserRole.donor => 'Accepted donation request at ${location.name}',
        UserRole.hospital => 'Inventory request sent to ${location.name}',
        UserRole.bloodBank => 'Viewing request queue for ${location.name}',
        _ => 'Action performed',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(action)));
    }
  }

  Future<void> _requestBlood(LocationModel location) async {
    if (widget.userId == null ||
        widget.userName == null ||
        widget.userPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to request blood')),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          _BloodRequestDialog(selectedBloodType: _selectedBloodType),
    );

    if (result != null) {
      try {
        setState(() => _isLoading = true);

        await _mapService.createRequestFromMap(
          requesterId: widget.userId!,
          requesterName: widget.userName!,
          requesterPhone: widget.userPhone!,
          bloodType: result['bloodType'] as String,
          quantity: result['quantity'] as int,
          urgency: result['urgency'] as String,
          locationId: location.id,
          latitude: _currentPosition?.latitude,
          longitude: _currentPosition?.longitude,
          address: location.displayAddress,
          reason: result['reason'] as String?,
        );

        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Blood request sent successfully to ${location.name}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to send request: $e')));
        }
      }
    }
  }

  void _handleSecondaryAction(LocationModel location) async {
    try {
      await MapsHelper.openGoogleMapsNavigation(
        latitude: location.latitude,
        longitude: location.longitude,
        label: location.name,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open navigation: $e')));
    }
  }

  LatLng get _currentLatLng => _currentPosition != null
      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
      : _kathmanduCenter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Map (Shazzy)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchLocations(_currentPosition),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.moveCamera(_currentLatLng, zoom: 15);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initialize,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            _buildFilterPanel(),
            Expanded(
              child: ShazzyMap(
                markers: _markers,
                controller: _mapController,
                initialPosition: _currentLatLng,
                showUserLocation: true,
              ),
            ),
          ],
        ),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildFilterPanel() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Search radius'),
                Text('${_radiusKm.toStringAsFixed(0)} km'),
              ],
            ),
            Slider(
              min: 1,
              max: 30,
              divisions: 29,
              value: _radiusKm,
              onChanged: (value) => setState(() => _radiusKm = value),
              label: '${_radiusKm.toStringAsFixed(0)} km',
              activeColor: const Color(0xFFD32F2F),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildBloodTypeDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _buildAvailabilityDropdown()),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _fetchLocations(_currentPosition),
                icon: const Icon(Icons.filter_alt),
                label: const Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodTypeDropdown() {
    const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    return DropdownButtonFormField<String?>(
      value: _selectedBloodType,
      decoration: const InputDecoration(
        labelText: 'Blood Type',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('Any')),
        ...bloodTypes.map(
          (type) => DropdownMenuItem<String?>(value: type, child: Text(type)),
        ),
      ],
      onChanged: (value) => setState(() => _selectedBloodType = value),
    );
  }

  Widget _buildAvailabilityDropdown() {
    const availabilityOptions = ['high', 'medium', 'low'];
    return DropdownButtonFormField<String?>(
      value: _selectedAvailability,
      decoration: const InputDecoration(
        labelText: 'Inventory',
        border: OutlineInputBorder(),
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
      onChanged: (value) => setState(() => _selectedAvailability = value),
    );
  }
}

class _BloodRequestDialog extends StatefulWidget {
  final String? selectedBloodType;

  const _BloodRequestDialog({this.selectedBloodType});

  @override
  State<_BloodRequestDialog> createState() => _BloodRequestDialogState();
}

class _BloodRequestDialogState extends State<_BloodRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _bloodType;
  int _quantity = 1;
  String _urgency = 'medium';
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloodType = widget.selectedBloodType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Blood'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _bloodType,
                decoration: const InputDecoration(labelText: 'Blood Type *'),
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
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Quantity (units) *',
                ),
                keyboardType: TextInputType.number,
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
              DropdownButtonFormField<String>(
                value: _urgency,
                decoration: const InputDecoration(labelText: 'Urgency *'),
                items: ['low', 'medium', 'high', 'critical']
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(u.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _urgency = value ?? 'medium'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
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
              });
            }
          },
          child: const Text('Request'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
