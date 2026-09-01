import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/google_maps_config.dart';
import '../../../../core/services/google_maps_service.dart';
import '../../../../core/theme/app_colors.dart';
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
  String _selectedCityFilter = 'All';
  String _searchQuery = '';
  int _selectedAmbulanceIndex = 0;

  // Map Customization State
  bool _isDarkMap = true;
  bool _showTraffic = true;
  bool _showSatellite = false;
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
      'fuel': 75,
      'defibrillatorReady': true,
      'ventilatorActive': false,
      'lat': 11.1040,
      'lng': 77.3450,
    },
    {
      'id': 'TN-108-CHE-01',
      'type': '108 Heart & Emergency ALS',
      'city': 'Chennai',
      'status': 'En Route',
      'badgeColor': AppColors.esi1Critical,
      'driver': 'V. Vijay',
      'paramedic': 'R. Dinesh, EMT-P',
      'phone': '+91 94421 10806',
      'plate': 'TN-01-AM-1085',
      'speed': 62,
      'etaMinutes': 6,
      'distanceKm': 2.5,
      'destination': 'Apollo Hospitals (Greams Rd)',
      'traumaBay': 'Cardiac ER Bay 1',
      'pickupLocation': 'Nungambakkam High Rd, Chennai',
      'oxygen': 96,
      'fuel': 90,
      'defibrillatorReady': true,
      'ventilatorActive': true,
      'lat': 13.0580,
      'lng': 77.2480,
    },
    {
      'id': 'TN-108-CHE-02',
      'type': '108 Apex Regional Trauma Unit',
      'city': 'Chennai',
      'status': 'En Route',
      'badgeColor': AppColors.esi1Critical,
      'driver': 'K. Loganathan',
      'paramedic': 'M. Kavitha, RN',
      'phone': '+91 94421 10807',
      'plate': 'TN-07-AM-1086',
      'speed': 55,
      'etaMinutes': 8,
      'distanceKm': 3.4,
      'destination': 'Rajiv Gandhi Govt General Hospital',
      'traumaBay': 'Level 1 Trauma Bay A',
      'pickupLocation': 'Chennai Central Terminal Area',
      'oxygen': 91,
      'fuel': 82,
      'defibrillatorReady': true,
      'ventilatorActive': true,
      'lat': 13.0780,
      'lng': 80.2720,
    },
    {
      'id': 'TN-108-CHE-03',
      'type': '108 Ortho Emergency ALS',
      'city': 'Chennai',
      'status': 'Available',
      'badgeColor': AppColors.esi4LessUrgent,
      'driver': 'P. Murugan',
      'paramedic': 'S. Balaji, EMT-I',
      'phone': '+91 94421 10808',
      'plate': 'TN-09-AM-1087',
      'speed': 0,
      'etaMinutes': 0,
      'distanceKm': 0.0,
      'destination': 'MIOT International',
      'traumaBay': 'N/A',
      'pickupLocation': 'Standby at Kathipara Junction, Guindy',
      'oxygen': 98,
      'fuel': 94,
      'defibrillatorReady': true,
      'ventilatorActive': false,
      'lat': 13.0200,
      'lng': 80.1750,
    },
  ];

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _toggleSimulation() {
    if (_isSimulatingMovement) {
      _simulationTimer?.cancel();
      setState(() => _isSimulatingMovement = false);
    } else {
      setState(() => _isSimulatingMovement = true);
      _simulationTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
        if (!mounted) return;
        setState(() {
          _simulatedProgress += 0.02;
          if (_simulatedProgress > 0.95) {
            _simulatedProgress = 0.05;
          }
        });
      });
    }
  }

  List<Map<String, dynamic>> get _filteredFleet {
    return _fleet.where((amb) {
      final matchesFilter = _selectedFilter == 'All' || amb['status'] == _selectedFilter;
      final matchesSearch = amb['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          amb['driver'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          amb['destination'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  int get _countTotal => _fleet.length;
  int get _countEnRoute => _fleet.where((a) => a['status'] == 'En Route').length;
  int get _countAvailable => _fleet.where((a) => a['status'] == 'Available').length;
  int get _countOnScene => _fleet.where((a) => a['status'] == 'On Scene').length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || _isDarkMap;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.neutral100,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go(RouteNames.home),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ambulance Tracking & Fleet Dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.esi4LessUrgent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Google Maps GPS • Live Telemetry Stream',
                  style: TextStyle(fontSize: 11, color: AppColors.neutral600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSimulatingMovement ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              color: _isSimulatingMovement ? AppColors.esi1Critical : AppColors.primary500,
              size: 26,
            ),
            tooltip: _isSimulatingMovement ? 'Pause Live Movement' : 'Simulate GPS Path Movement',
            onPressed: _toggleSimulation,
          ),
          IconButton(
            icon: Icon(_isDarkMap ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 22),
            tooltip: 'Toggle Map Theme',
            onPressed: () => setState(() => _isDarkMap = !_isDarkMap),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP PROMINENT COUNTER & FLEET KPI BAR (WITH AMBULANCE ICONS)
            _buildFleetCounterHeader(isDark),

            // 2. MAIN SPLIT VIEW (MAPS CANVAS & FLEET TELEMETRY MATRIX)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    // Desktop / Wide Screen Split View
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildGoogleMapsCanvas(isDark),
                        ),
                        Expanded(
                          flex: 5,
                          child: _buildFleetTelemetryPanel(isDark),
                        ),
                      ],
                    );
                  } else {
                    // Mobile / Narrow Screen Column View
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

  // ==========================================
  // 1. PROMINENT FLEET COUNTER HEADER (AMBULANCE ICONS)
  // ==========================================
  Widget _buildFleetCounterHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.neutral200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Main Active Fleet Counter Box with Pulsing Ambulance Icon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary500,
                      AppColors.primary600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Ambulances',
                              style: TextStyle(
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

              const SizedBox(width: 16),

              // KPI Status Counter Pills
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
        borderRadius: BorderRadius.circular(14),
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
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
              ),
              Row(
                children: [
                  Text(
                    '$count',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.airport_shuttle, size: 14, color: AppColors.neutral600),
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
        color: isDark ? AppColors.darkCanvas : AppColors.neutral100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.neutral200),
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
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.neutral600),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.neutral900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. GOOGLE MAPS & POLYLINE ROUTE PATH CANVAS
  // ==========================================
  Widget _buildGoogleMapsCanvas(bool isDark) {
    final selectedAmb = _fleet[_selectedAmbulanceIndex];

    final markers = GoogleMapsService.buildFleetMarkers(
      fleet: _fleet,
      selectedIndex: _selectedAmbulanceIndex,
      onMarkerTap: (index, unitId) {
        setState(() {
          _selectedAmbulanceIndex = index;
        });
      },
    );

    final polylines = GoogleMapsService.buildFleetRoutePolylines(
      fleet: _fleet,
      selectedIndex: _selectedAmbulanceIndex,
      showTraffic: _showTraffic,
      simulatedProgress: _simulatedProgress,
    );

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Authentic Google Maps Widget Instance
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: GoogleMapsConfig.initialCameraPosition,
              mapType: _showSatellite ? MapType.satellite : MapType.normal,
              trafficEnabled: _showTraffic,
              style: isDark ? GoogleMapsConfig.darkMapStyle : null,
              markers: markers,
              polylines: polylines,
              zoomControlsEnabled: false,
              compassEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),

          // Google Maps Watermark & Branding Badge
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.map_rounded, color: AppColors.primary500, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Google Maps Platform • Live Telemetry',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Map Control Floating Buttons (Layers, Traffic, Satellite, Recenter)
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              children: [
                _buildMapControlBtn(
                  icon: Icons.traffic_rounded,
                  isActive: _showTraffic,
                  tooltip: 'Traffic Corridor Layer',
                  onTap: () => setState(() => _showTraffic = !_showTraffic),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildMapControlBtn(
                  icon: Icons.layers_rounded,
                  isActive: _showSatellite,
                  tooltip: 'Satellite Layer',
                  onTap: () => setState(() => _showSatellite = !_showSatellite),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildMapControlBtn(
                  icon: Icons.my_location_rounded,
                  isActive: false,
                  tooltip: 'Recenter Selected Ambulance',
                  onTap: () {
                    final bounds = GoogleMapsService.getBoundsForFleet(_fleet);
                    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Focused on ${selectedAmb['id']} polyline route!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Top Map Floating Tooltip for Selected Ambulance Path Info
          Positioned(
            left: 16,
            top: 16,
            right: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard.withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: selectedAmb['badgeColor'], width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedAmb['badgeColor'],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.airport_shuttle, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${selectedAmb['id']} (${selectedAmb['status']})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: selectedAmb['badgeColor'],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (selectedAmb['speed'] > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary500.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${selectedAmb['speed']} km/h',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary500),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          'Destination: ${selectedAmb['destination']} (${selectedAmb['etaMinutes']} mins • ${selectedAmb['distanceKm']} km)',
                          style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlBtn({
    required IconData icon,
    required bool isActive,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary500
            : (isDark ? AppColors.darkSurfaceCard : Colors.white),
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: IconButton(
        icon: Icon(icon, color: isActive ? Colors.white : (isDark ? Colors.white : AppColors.neutral900), size: 20),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  // ==========================================
  // 3. FLEET TELEMETRY & DATA MATRIX PANEL
  // ==========================================
  Widget _buildFleetTelemetryPanel(bool isDark) {
    final filtered = _filteredFleet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Status Filters Bar
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hintText: 'Search unit, driver, hospital...',
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tamil Nadu City Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCityFilterChip('All', isDark),
                _buildCityFilterChip('Coimbatore', isDark),
                _buildCityFilterChip('Tirupur', isDark),
                _buildCityFilterChip('Chennai', isDark),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Status Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', isDark),
                _buildFilterChip('En Route', isDark),
                _buildFilterChip('On Scene', isDark),
                _buildFilterChip('Available', isDark),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Ambulance Telemetry Cards List
          Expanded(
            child: filtered.isEmpty
                ? const EmptyStateWidget(
                    title: 'No Ambulances Found',
                    message: 'Try adjusting your search or filter criteria.',
                    icon: Icons.airport_shuttle_outlined,
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, idx) {
                      final amb = filtered[idx];
                      final isSelected = _fleet.indexOf(amb) == _selectedAmbulanceIndex;
                      return _buildAmbulanceCard(amb, isSelected, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityFilterChip(String label, bool isDark) {
    final isSelected = _selectedCityFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        avatar: Icon(
          Icons.location_city_rounded,
          size: 14,
          color: isSelected ? Colors.white : AppColors.primary500,
        ),
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        selectedColor: AppColors.primary500,
        backgroundColor: isDark ? AppColors.darkSurfaceCard : AppColors.neutral200,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.neutral800),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (val) {
          if (val) {
            setState(() {
              _selectedCityFilter = label;
              _selectedAmbulanceIndex = 0;
            });
            if (label != 'All' && GoogleMapsConfig.cityCenters.containsKey(label) && _mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(GoogleMapsConfig.cityCenters[label]!, 12.5),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary500,
        backgroundColor: isDark ? AppColors.darkSurfaceCard : AppColors.neutral200,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.neutral800),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (val) {
          if (val) setState(() => _selectedFilter = label);
        },
      ),
    );
  }

  Widget _buildAmbulanceCard(Map<String, dynamic> amb, bool isSelected, bool isDark) {
    final Color badgeColor = amb['badgeColor'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmbulanceIndex = _fleet.indexOf(amb);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : (isDark ? AppColors.darkBorder : AppColors.neutral200),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary500.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Unit ID, Ambulance Icon, Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.airport_shuttle, color: badgeColor, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          amb['id'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          amb['type'],
                          style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor, width: 1),
                  ),
                  child: Text(
                    amb['status'].toString().toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.neutral200),
            const SizedBox(height: 12),

            // Driver & Crew Info
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.neutral600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Driver: ${amb['driver']} • ${amb['paramedic']}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.esi4LessUrgent),
                  tooltip: 'Call Crew',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${amb['driver']} (${amb['phone']})...')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Telemetry Gauges (Oxygen, Fuel, Speed)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTelemetryGauge(
                  label: 'Oxygen',
                  val: '${amb['oxygen']}%',
                  icon: Icons.air_rounded,
                  color: amb['oxygen'] > 50 ? AppColors.primaryAccent : AppColors.esi1Critical,
                  isDark: isDark,
                ),
                _buildTelemetryGauge(
                  label: 'Fuel/Bat',
                  val: '${amb['fuel']}%',
                  icon: Icons.local_gas_station_outlined,
                  color: amb['fuel'] > 40 ? AppColors.esi4LessUrgent : AppColors.esi2Emergent,
                  isDark: isDark,
                ),
                _buildTelemetryGauge(
                  label: 'Defib',
                  val: amb['defibrillatorReady'] ? 'READY' : 'OFFLINE',
                  icon: Icons.monitor_heart_outlined,
                  color: amb['defibrillatorReady'] ? AppColors.esi4LessUrgent : AppColors.esi1Critical,
                  isDark: isDark,
                ),
              ],
            ),

            if (amb['status'] == 'En Route' || amb['status'] == 'On Scene') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCanvas : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.navigation_outlined, color: AppColors.primary500, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Target: ${amb['destination']} (${amb['traumaBay']})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'ETA ${amb['etaMinutes']}m',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.esi1Critical),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryGauge({
    required String label,
    required String val,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCanvas : AppColors.neutral100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, color: AppColors.neutral600)),
              Text(val, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
