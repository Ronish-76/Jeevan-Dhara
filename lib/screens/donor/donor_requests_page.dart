import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/screens/donor/donor_request_details_page.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorRequestsPage extends StatefulWidget {
  const DonorRequestsPage({super.key});

  @override
  State<DonorRequestsPage> createState() => _DonorRequestsPageState();
}

class _DonorRequestsPageState extends State<DonorRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BloodRequest> _requests = [];
  List<BloodRequest> _myDonations = [];
  List<BloodRequest> _hospitalRequests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isBloodGroupMatch(String? userGroup, String? requestGroup) {
    if (userGroup == null || requestGroup == null) return false;
    return userGroup.trim().toUpperCase() == requestGroup.trim().toUpperCase();
  }

  bool _isRequestedFromDonor(BloodRequest r) {
    // If 'requestedFrom' is not set, we assume it might be a legacy or user request which is usually for donors.
    // If it IS set, it MUST be 'donor' (case-insensitive).
    if (r.requestedFrom == null) return true; 
    return r.requestedFrom!.toLowerCase() == 'donor';
  }

  Future<void> _fetchRequests() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }
      final userBloodGroup = user.bloodGroup;

      // Use Future.wait to run independent fetches in parallel and handle errors gracefully
      final results = await Future.wait([
        ApiService().getAllBloodRequests().catchError((e) { debugPrint('Error fetching requests: $e'); return []; }),
        ApiService().getAllHospitalBloodRequests().catchError((e) { debugPrint('Error fetching hospital requests: $e'); return []; }),
        ApiService().getDonorDonationHistory(user.id!).catchError((e) { debugPrint('Error fetching history: $e'); return []; })
      ]);

      final allRequests = (results[0] as List).map((json) => BloodRequest.fromJson(json)).toList();
      final hospitalData = results[1] as List;
      final allHospitalRequests = hospitalData.map((json) => BloodRequest.fromJson(json)).toList();
      final historyRequests = (results[2] as List).map((json) => BloodRequest.fromJson(json)).toList();

      // Filter regular requests and extract hospital requests from main feed if any
      final nearbyRequests = <BloodRequest>[];
      final extractedHospitalRequests = <BloodRequest>[];
      
      for (var r in allRequests) {
        bool matchGroup = _isBloodGroupMatch(userBloodGroup, r.bloodGroup);
        bool isPending = r.status.toLowerCase() == 'pending';
        bool isForDonor = _isRequestedFromDonor(r);
        
        if (isPending && matchGroup && isForDonor) {
          if (r.isHospitalRequest) {
            extractedHospitalRequests.add(r);
          } else {
            nearbyRequests.add(r);
          }
        }
      }
      
      // Merge fetched hospital requests with extracted ones
      // Use a map to deduplicate by ID
      final Map<String, BloodRequest> uniqueHospitalRequests = {};
      
      for (var r in extractedHospitalRequests) {
        uniqueHospitalRequests[r.id] = r;
      }
      
      for (var r in allHospitalRequests) {
         bool matchGroup = _isBloodGroupMatch(userBloodGroup, r.bloodGroup);
         bool isPending = r.status.toLowerCase() == 'pending';
         bool isForDonor = _isRequestedFromDonor(r);
         
         if (isPending && matchGroup && isForDonor) {
           uniqueHospitalRequests[r.id] = r;
         }
      }
      
      var finalHospitalRequestsList = uniqueHospitalRequests.values.toList();

      // Enrichment step for hospital requests missing details
      // If hospitalName is missing but we have hospitalId, fetch details
      final Set<String> hospitalIdsToFetch = {};
      for (var req in finalHospitalRequestsList) {
        if ((req.hospitalName.isEmpty) && req.hospitalId != null) {
          hospitalIdsToFetch.add(req.hospitalId!);
        }
      }

      if (hospitalIdsToFetch.isNotEmpty) {
        final Map<String, Map<String, dynamic>> hospitalDetailsMap = {};
        
        await Future.wait(hospitalIdsToFetch.map((id) async {
          try {
            final details = await ApiService().getHospital(id);
            if (details != null) {
              hospitalDetailsMap[id] = details is Map<String, dynamic> ? details : Map<String, dynamic>.from(details as Map);
            }
          } catch (e) {
            debugPrint('Failed to fetch hospital details for $id: $e');
          }
        }));

        // Update requests with fetched details
        finalHospitalRequestsList = finalHospitalRequestsList.map((req) {
          if ((req.hospitalName.isEmpty) && req.hospitalId != null && hospitalDetailsMap.containsKey(req.hospitalId)) {
            final details = hospitalDetailsMap[req.hospitalId]!;
            
            String name = details['hospitalName'] ?? details['fullName'] ?? '';
            String loc = details['hospitalLocation'] ?? details['location'] ?? details['address'] ?? '';
            String phone = details['hospitalPhone'] ?? details['contactNumber'] ?? details['phoneNumber'] ?? '';
            
            // Handle lat/long types safely
            double? lat;
            if (details['latitude'] != null) {
               lat = (details['latitude'] is int) ? (details['latitude'] as int).toDouble() : details['latitude'];
            }
            double? lng;
            if (details['longitude'] != null) {
               lng = (details['longitude'] is int) ? (details['longitude'] as int).toDouble() : details['longitude'];
            }

            return req.copyWith(
              hospitalName: name,
              location: loc,
              contactNumber: phone,
              latitude: lat,
              longitude: lng,
            );
          }
          return req;
        }).toList();
      }

      // Combine and deduplicate my donations
      final Map<String, BloodRequest> myDonationsMap = {};
      
      for (var r in allRequests) {
        if (r.donorId == user.id && (r.status == 'accepted' || r.status == 'fulfilled' || r.status == 'completed')) {
          myDonationsMap[r.id] = r;
        }
      }
      
      for (var r in historyRequests) {
        myDonationsMap[r.id] = r;
      }
      
      final myDonations = myDonationsMap.values.toList();

      if (mounted) {
        setState(() {
          _requests = nearbyRequests;
          _hospitalRequests = finalHospitalRequestsList; // Fixed: using enriched list
          _myDonations = myDonations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // If an error occurs in the main flow, try to show what we have
        debugPrint('Error in _fetchRequests main flow: $e');
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} ${translate('days_ago')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${translate('hours_ago')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${translate('mins_ago')}';
    } else {
      return translate('just_now');
    }
  }

  Color _getUrgencyColor(bool isEmergency) {
    return isEmergency ? const Color(0xFFB71C1C) : const Color(0xFF2196F3);
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $urlString');
    }
  }

  Future<void> _launchMap(String location, double? lat, double? lng) async {
    String googleUrl;
    if (lat != null && lng != null) {
      googleUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    } else {
      googleUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}';
    }
    await _launchUrl(googleUrl);
  }

  Future<void> _launchCaller(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: Text(translate('blood_requests')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(text: translate('nearby_requests')),
            Tab(text: 'Hospital Requests'), // Translate if needed
            Tab(text: translate('my_donations')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestList(_requests, translate('no_matching_requests')),
          _buildRequestList(_hospitalRequests, 'No hospital requests found', isHospitalList: true),
          _buildRequestList(_myDonations, translate('you_havent_accepted'), isMyDonation: true),
        ],
      ),
    );
  }

  Widget _buildRequestList(List<BloodRequest> items, String emptyMessage, {bool isMyDonation = false, bool isHospitalList = false}) {
    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(isMyDonation ? Icons.check_circle_outline : Icons.location_on_outlined, color: isMyDonation ? Colors.green : Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  isMyDonation 
                    ? translate('accepted_completed_requests', args: {'count': items.length})
                    : translate('matching_requests', args: {'count': items.length}), 
                  style: const TextStyle(color: Colors.grey, fontSize: 12)
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty && _error != null 
                    ? ListView(children: [Center(child: Text('Error: $_error'))])
                    : items.isEmpty
                        ? ListView(children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(child: Text(emptyMessage)),
                            )
                          ])
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return _buildRequestCard(items[index], isMyDonation: isMyDonation, isHospitalRequest: isHospitalList);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BloodRequest request, {bool isMyDonation = false, bool isHospitalRequest = false}) {
    final urgencyColor = _getUrgencyColor(request.notifyViaEmergency);
    final isFulfilled = request.status == 'fulfilled' || request.status == 'completed';
    
    Color borderColor = urgencyColor;
    if (isMyDonation) {
      borderColor = isFulfilled ? Colors.blue : Colors.green;
    } else if (isHospitalRequest) {
      borderColor = Colors.purple; // Different color for hospital requests
    }
    
    Color badgeColor = Colors.green;
    String badgeText = translate('accepted').toUpperCase();
    if (isFulfilled) {
      badgeColor = Colors.blue;
      badgeText = translate('completed').toUpperCase();
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DonorRequestDetailsPage(request: request)),
        ).then((_) => _fetchRequests());
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      color: isMyDonation ? borderColor.withOpacity(0.1) : (isHospitalRequest ? Colors.purple.withOpacity(0.1) : urgencyColor.withOpacity(0.1))
                    ),
                    child: Center(
                      child: Text(
                        request.bloodGroup, 
                        style: TextStyle(
                          color: isMyDonation ? borderColor : (isHospitalRequest ? Colors.purple : urgencyColor), 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        )
                      )
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(request.patientName.isNotEmpty ? request.patientName : (request.hospitalName.isNotEmpty ? request.hospitalName : "Hospital Request"), 
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16), 
                                overflow: TextOverflow.ellipsis
                              ),
                            ),
                            if (request.notifyViaEmergency && !isMyDonation && !isHospitalRequest)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB71C1C),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  translate('emergency').toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                             if (isHospitalRequest && !isMyDonation)
                               Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'HOSPITAL',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                             if (isMyDonation)
                               Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  badgeText,
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (request.hospitalName.isNotEmpty)
                          Row(children: [const Icon(Icons.local_hospital_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(request.hospitalName, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis))]),
                        if (request.location.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(request.location, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                        ],
                        const SizedBox(height: 4),
                        Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(_getTimeAgo(request.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                      ],
                    ),
                  ),
                  
                  // Only show these buttons if it IS a hospital request and NOT my donation
                  if (isHospitalRequest && !isMyDonation) ...[
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          onPressed: () {
                            if (request.contactNumber.isNotEmpty) {
                              _launchCaller(request.contactNumber);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Contact number unavailable')),
                              );
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.directions, color: Colors.blue),
                          onPressed: () {
                            _launchMap(request.location, request.latitude, request.longitude);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    )
                  ] else if (!isMyDonation) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DonorRequestDetailsPage(request: request)),
                        ).then((_) => _fetchRequests());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        elevation: 2,
                      ),
                      child: Text(translate('accept'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ] else
                     const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
