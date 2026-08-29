import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/google_maps_config.dart';
import '../../../../core/services/google_maps_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/widgets.dart';

/// Enterprise Google Maps Ambulance Tracking & Fleet Telemetry Dashboard
class AmbulanceTrackingDashboardScreen extends StatefulWidget {
  const AmbulanceTrackingDashboardScreen({super.key});

  @override
  State<AmbulanceTrackingDashboardScreen> createState() => _AmbulanceTrackingDashboardScreenState();
}

class _AmbulanceTrackingDashboardScreenState extends State<AmbulanceTrackingDashboardScreen>
    with SingleTickerProviderStateMixin {
  // Map Controller State
  GoogleMapController? _mapController;

  // Navigation & Filter State
  String _selectedFilter = 'All';
  final String _selectedCityFilter = 'All';
  final String _searchQuery = '';
  int _selectedAmbulanceIndex = 0;

  // Map Customization State
  bool _isDarkMap = true;
  bool _showTraffic = true;
  final bool _showSatellite = false;
  bool _isSimulatingMovement = false;

  Timer? _simulationTimer;
  double _simulatedProgress = 0.35; // Position along polyline route (0.0 to 1.0)

  // Real Tamil Nadu 108 Ambulance Fleet Telemetry Data
  final List<Map<String, dynamic>> _fleet = [
    {
      'id': 'TN-108-CBE-01',
      'type': '108 Advanced Life Support (ALS)',
      'city': 'Coimbatore',
      'status': 'En Route',
      'badgeColor': AppColors.esi1Critical,
      'driver': 'K. Karthik',
      'paramedic': 'S. Ramanan, EMT-P',
      'phone': '+91 94421 10801',
      'plate': 'TN-37-AM-1080',
      'speed': 64,
      'etaMinutes': 4,
      'distanceKm': 1.8,
      'destination': 'PSG Hospitals',
      'traumaBay': 'Trauma Bay 2',
      'pickupLocation': 'Avinashi Rd, Peelamedu, Coimbatore',
      'oxygen': 95,
      'fuel': 88,
      'defibrillatorReady': true,
      'ventilatorActive': true,
      'lat': 11.0220,
      'lng': 76.9850,
    },
    {
      'id': 'TN-108-CBE-02',
      'type': '108 Cardiac ALS Unit',
      'city': 'Coimbatore',
      'status': 'On Scene',
      'badgeColor': AppColors.esi2Emergent,
      'driver': 'M. Selvam',
      'paramedic': 'P. Lakshmi, RN',
      'phone': '+91 94421 10802',
      'plate': 'TN-38-AM-1081',
      'speed': 0,
      'etaMinutes': 7,
      'distanceKm': 3.2,
      'destination': 'KMCH (Kovai Medical Center)',
      'traumaBay': 'ICU Bay 4',
      'pickupLocation': 'Hope College Junction, Coimbatore',
      'oxygen': 90,
      'fuel': 78,
      'defibrillatorReady': true,
      'ventilatorActive': false,
      'lat': 11.0350,
      'lng': 77.0250,
    },
    {
      'id': 'TN-108-CBE-03',
      'type': '108 Ortho Polytrauma Care',
      'city': 'Coimbatore',
      'status': 'Available',
      'badgeColor': AppColors.esi4LessUrgent,
      'driver': 'R. Anand',
      'paramedic': 'T. Suresh, EMT-I',
      'phone': '+91 94421 10803',
      'plate': 'TN-37-AM-1082',
      'speed': 0,
      'etaMinutes': 0,
      'distanceKm': 0.0,
      'destination': 'Ganga Hospital',
      'traumaBay': 'N/A',
      'pickupLocation': 'Standby at Mettupalayam Rd Hub',
      'oxygen': 100,
      'fuel': 92,
      'defibrillatorReady': true,
      'ventilatorActive': false,
      'lat': 11.0180,
      'lng': 76.9520,
    },
    {
      'id': 'TN-108-TPR-01',
      'type': '108 Advanced Emergency Unit',
      'city': 'Tirupur',
      'status': 'En Route',
      'badgeColor': AppColors.esi1Critical,
      'driver': 'G. Prakash',
      'paramedic': 'K. Vimal, EMT-P',
      'phone': '+91 94421 10804',
      'plate': 'TN-39-AM-1083',
      'speed': 58,
      'etaMinutes': 5,
      'distanceKm': 2.1,
      'destination': 'Revathi Medical Center',
      'traumaBay': 'Trauma Room 1',
      'pickupLocation': 'Kumar Nagar, Avinashi Rd, Tirupur',
      'oxygen': 92,
      'fuel': 84,
      'defibrillatorReady': true,
      'ventilatorActive': true,
      'lat': 11.1150,
      'lng': 77.3380,
    },
    {
      'id': 'TN-108-TPR-02',
      'type': '108 Govt Emergency Express',
      'city': 'Tirupur',
      'status': 'On Scene',
      'badgeColor': AppColors.esi2Emergent,
      'driver': 'S. Kumar',
      'paramedic': 'N. Devi, RN',
      'phone': '+91 94421 10805',
      'plate': 'TN-39-AM-1084',
      'speed': 0,
      'etaMinutes': 6,
      'distanceKm': 1.9,
      'destination': 'Govt Head Quarters Hospital Tirupur',
      'traumaBay': 'Govt Casualty ER',
      'pickupLocation': 'Old Bus Stand Sector, Tirupur',
      'oxygen': 88,
      'fuel': 72,
      'defibrillatorReady': true,
      'ventilatorActive': false,
      'lat': 11.1080,
      'lng': 77.3450,
    },
    {
      'id': 'TN-108-MAA-01',
      'type': '108 Metro Critical Transport',
      'city': 'Chennai',
      'status': 'En Route',
      'badgeColor': AppColors.esi1Critical,
      'driver': 'V. Rajan',
      'paramedic': 'Dr. M. Deepa, MD',
      'phone': '+91 94421 10806',
      'plate': 'TN-01-AM-1085',
      'speed': 68,
      'etaMinutes': 3,
      'distanceKm': 1.4,
      'destination': 'Apollo Hospitals (Greams Rd)',
      'traumaBay': 'Cath Lab ER 1',
      'pickupLocation': 'Nungambakkam High Rd, Chennai',
      'oxygen': 96,
      'fuel': 90,
      'defibrillatorReady': true,
      'ventilatorActive': true,
      'lat': 13.0600,
      'lng': 80.2500,
    },
    {
      'id': 'TN-108-MAA-02',
      'type': '108 Apex Govt Hospital Unit',
      'city': 'Chennai',
      'status': 'Available',
      'badgeColor': AppColors.esi4LessUrgent,
      'driver': 'P. Mohan',
      'paramedic': 'R. Balan, EMT-B',
      'phone': '+91 94421 10807',
      'plate': 'TN-02-AM-1086',
      'speed': 0,
      'etaMinutes': 0,
      'distanceKm': 0.0,
      'destination': 'Rajiv Gandhi Govt General Hospital',
      'traumaBay': 'N/A',
      'pickupLocation': 'Central Station ER Standby Hub',
      'oxygen': 100,
      'fuel': 95,
      'defibrillatorReady': true,
      'ventilatorActive': false,
      'lat': 13.0820,
      'lng': 80.2750,
    },
  ];

  List<Map<String, dynamic>> get _filteredFleet {
    return _fleet.where((amb) {
      final matchesStatus = _selectedFilter == 'All' || amb['status'] == _selectedFilter;
      final matchesCity = _selectedCityFilter == 'All' || amb['city'] == _selectedCityFilter;
      final matchesQuery = _searchQuery.isEmpty ||
          amb['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          amb['driver'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          amb['destination'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesCity && matchesQuery;
    }).toList();
  }

  int get _countTotal => _fleet.length;
  int get _countEnRoute => _fleet.where((a) => a['status'] == 'En Route').length;
  int get _countOnScene => _fleet.where((a) => a['status'] == 'On Scene').length;
  int get _countAvailable => _fleet.where((a) => a['status'] == 'Available').length;

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _toggleSimulation() {
    setState(() => _isSimulatingMovement = !_isSimulatingMovement);
    if (_isSimulatingMovement) {
      _simulationTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
        if (!mounted) return;
        setState(() {
          _simulatedProgress += 0.04;
          if (_simulatedProgress > 0.95) {
            _simulatedProgress = 0.10;
          }
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ Live GPS Ambulance Simulation Running (2.5 sec polling)'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _simulationTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.go(RouteNames.home),
        ),
        title: Row(
          children: [
            const Icon(Icons.radar_rounded, color: AppColors.esi1Critical, size: 24),
            const SizedBox(width: 10),
            Text(
              'Tamil Nadu 108 Fleet Radar',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.neutral900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSimulatingMovement ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: _isSimulatingMovement ? AppColors.esi1Critical : AppColors.primary500,
            ),
            tooltip: _isSimulatingMovement ? 'Pause Movement Simulation' : 'Simulate GPS Telemetry',
            onPressed: _toggleSimulation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing 108 Fleet Radar...')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Prominent Active Fleet Counter Banner
            _buildFleetCounterHeader(isDark),

            // 2. Main Workspace Layout
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: _buildGoogleMapsCanvas(isDark),
                        ),
                        Expanded(
                          flex: 5,
                          child: _buildFleetTelemetryPanel(isDark),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildGoogleMapsCanvas(isDark),
                        ),
                        Expanded(
                          flex: 6,
                          child: _buildFleetTelemetryPanel(isDark),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. PROMINENT FLEET COUNTER HEADER
  Widget _buildFleetCounterHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.neutral200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary500,
                      AppColors.primary600,
                    ],
                  ),
                  borderRadius: AppTokens.borderRadiusLg,
                  boxShadow: AppTokens.shadowMd(isDark),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1.15, 1.15),
                              duration: 1000.ms,
                            ),
                        const Icon(
                          Icons.airport_shuttle_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACTIVE FLEET',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white70,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '$_countTotal',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Ambulances',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppTokens.spaceMd),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusKpiChip(
                        title: 'En Route',
                        count: _countEnRoute,
                        color: AppColors.esi1Critical,
                        icon: Icons.run_circle_outlined,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _buildStatusKpiChip(
                        title: 'On Scene',
                        count: _countOnScene,
                        color: AppColors.esi2Emergent,
                        icon: Icons.location_on_outlined,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _buildStatusKpiChip(
                        title: 'Available',
                        count: _countAvailable,
                        color: AppColors.esi4LessUrgent,
                        icon: Icons.check_circle_outline_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _buildMetricKpiChip(
                        title: 'Avg Response',
                        value: '3.4 mins',
                        color: AppColors.primaryAccent,
                        icon: Icons.timer_outlined,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusKpiChip({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color),
              ),
              Row(
                children: [
                  Text(
                    '$count',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Units', style: TextStyle(fontSize: 10, color: AppColors.neutral600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricKpiChip({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.neutral900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMapsCanvas(bool isDark) {
    final activeList = _filteredFleet;
    final safeIndex = _selectedAmbulanceIndex < activeList.length ? _selectedAmbulanceIndex : 0;
    final activeVehicle = activeList.isNotEmpty ? activeList[safeIndex] : _fleet.first;

    final LatLng centerPos = LatLng(activeVehicle['lat'], activeVehicle['lng']);
    final LatLng hospitalPos = GoogleMapsConfig.hospitalLocations[activeVehicle['destination']] ??
        LatLng(centerPos.latitude + 0.015, centerPos.longitude + 0.012);

    final Set<Marker> markers = {};

    for (int i = 0; i < activeList.length; i++) {
      final veh = activeList[i];
      final isSelected = i == safeIndex;

      double finalLat = veh['lat'];
      double finalLng = veh['lng'];

      if (isSelected && _isSimulatingMovement) {
        finalLat += (_simulatedProgress * 0.005);
        finalLng += (_simulatedProgress * 0.004);
      }

      markers.add(
        Marker(
          markerId: MarkerId(veh['id']),
          position: LatLng(finalLat, finalLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: '${veh['id']} (${veh['status']})',
            snippet: '${veh['driver']} • ${veh['speed']} km/h',
          ),
          onTap: () {
            setState(() => _selectedAmbulanceIndex = i);
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(finalLat, finalLng), 14.0),
            );
          },
        ),
      );
    }

    markers.add(
      Marker(
        markerId: const MarkerId('dest_hosp'),
        position: hospitalPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        infoWindow: InfoWindow(title: activeVehicle['destination'], snippet: activeVehicle['traumaBay']),
      ),
    );

    final List<LatLng> polylinePoints = GoogleMapsService.generatePolylineCoordinates(
      start: centerPos,
      end: hospitalPos,
    );

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: centerPos, zoom: 13.5),
          style: _isDarkMap ? GoogleMapsConfig.darkMapStyle : null,
          markers: markers,
          polylines: {
            Polyline(
              polylineId: const PolylineId('active_vehicle_route'),
              points: polylinePoints,
              color: AppColors.primary500,
              width: 5,
            ),
          },
          trafficEnabled: _showTraffic,
          mapType: _showSatellite ? MapType.satellite : MapType.normal,
          zoomControlsEnabled: false,
          onMapCreated: (controller) => _mapController = controller,
        ),

        Positioned(
          top: 14,
          right: 14,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'dashboard_fab_layer',
                backgroundColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
                foregroundColor: isDark ? Colors.white : AppColors.neutral900,
                onPressed: () => setState(() => _isDarkMap = !_isDarkMap),
                child: Icon(_isDarkMap ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'dashboard_fab_traffic',
                backgroundColor: _showTraffic ? AppColors.primary500 : (isDark ? AppColors.darkSurfaceCard : Colors.white),
                foregroundColor: _showTraffic ? Colors.white : (isDark ? Colors.white : AppColors.neutral900),
                onPressed: () => setState(() => _showTraffic = !_showTraffic),
                child: const Icon(Icons.traffic_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFleetTelemetryPanel(bool isDark) {
    final activeList = _filteredFleet;
    final safeIndex = _selectedAmbulanceIndex < activeList.length ? _selectedAmbulanceIndex : 0;

    return Container(
      color: isDark ? AppColors.darkCanvas : AppColors.neutral100,
      child: Column(
        children: [
          // Filter Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd, vertical: 10),
            color: isDark ? AppColors.darkSurfaceCard : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'En Route', 'On Scene', 'Available'].map((st) {
                        final isSel = st == _selectedFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(st, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            selected: isSel,
                            selectedColor: AppColors.primary500,
                            labelStyle: TextStyle(color: isSel ? Colors.white : (isDark ? Colors.white : AppColors.neutral900)),
                            onSelected: (val) {
                              if (val) setState(() => _selectedFilter = st);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Telemetry Content
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppTokens.spaceMd),
              itemCount: activeList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final amb = activeList[index];
                final isSelected = index == safeIndex;
                final statusColor = amb['badgeColor'] as Color;

                return Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary500.withValues(alpha: 0.12)
                        : (isDark ? AppColors.darkSurfaceCard : Colors.white),
                    borderRadius: AppTokens.borderRadiusLg,
                    border: Border.all(
                      color: isSelected ? AppColors.primary500 : (isDark ? AppColors.darkBorder : AppColors.neutral200),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () {
                      setState(() => _selectedAmbulanceIndex = index);
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(LatLng(amb['lat'], amb['lng']), 14.5),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withValues(alpha: 0.2),
                      child: Icon(Icons.airport_shuttle_rounded, color: statusColor),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(amb['id'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                        StatusBadge(label: amb['status'], type: StatusBadgeType.lessUrgent),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${amb['type']} • ${amb['city']}', style: const TextStyle(fontSize: 11)),
                        Text('Driver: ${amb['driver']} • ${amb['speed']} km/h', style: const TextStyle(fontSize: 11)),
                        if (amb['status'] == 'En Route')
                          Text('ETA: ${amb['etaMinutes']} mins to ${amb['destination']}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.esi1Critical)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
