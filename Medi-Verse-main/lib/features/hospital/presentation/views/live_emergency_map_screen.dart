import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/google_maps_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/severity_level.dart';

/// Enterprise Google Maps Live Emergency & Hospital Radar Screen
/// Feature-First Clean Architecture: Presentation Layer
class LiveEmergencyMapScreen extends StatefulWidget {
  const LiveEmergencyMapScreen({super.key});

  @override
  State<LiveEmergencyMapScreen> createState() => _LiveEmergencyMapScreenState();
}

class _LiveEmergencyMapScreenState extends State<LiveEmergencyMapScreen> {
  GoogleMapController? _mapController;
  String _selectedCity = 'Coimbatore';
  int _selectedHospitalIndex = 0;
  bool _isDarkMapLayer = false;

  final Map<String, List<Map<String, dynamic>>> _cityHospitals = {
    'Coimbatore': [
      {
        'name': 'PSG Hospitals',
        'address': 'Peelamedu, Avinashi Rd, Coimbatore',
        'distance': '1.2 km',
        'eta': '4 mins',
        'icuBeds': '8 ICU Beds Available',
        'traumaLevel': 'Level 1 Trauma Center',
        'attending': 'Dr. S. Rajendran',
        'phone': '+91 422 257 0170',
        'color': AppColors.esi4LessUrgent,
      },
      {
        'name': 'Ganga Hospital',
        'address': '313 Mettupalayam Rd, Coimbatore',
        'distance': '2.8 km',
        'eta': '8 mins',
        'icuBeds': '5 ICU Beds Available',
        'traumaLevel': 'Ortho & Plastic Trauma Center',
        'attending': 'Dr. S. Raja Sabapathy',
        'phone': '+91 422 248 5000',
        'color': AppColors.esi3Urgent,
      },
      {
        'name': 'KMCH (Kovai Medical Center)',
        'address': 'Avinashi Rd, Civil Aerodrome Post, Coimbatore',
        'distance': '3.5 km',
        'eta': '10 mins',
        'icuBeds': '12 ICU Beds Available',
        'traumaLevel': 'Multi-Specialty & Cardiac ER',
        'attending': 'Dr. Nalla G. Palaniswami',
        'phone': '+91 422 432 3800',
        'color': AppColors.esi1Critical,
      },
      {
        'name': 'Sri Ramakrishna Hospital',
        'address': '395 Sarojini Naidu Rd, Avarampalayam, Coimbatore',
        'distance': '4.1 km',
        'eta': '11 mins',
        'icuBeds': '4 ICU Beds Available',
        'traumaLevel': 'Emergency & Oncology Center',
        'attending': 'Dr. P. Guhan',
        'phone': '+91 422 450 0000',
        'color': AppColors.esi2Emergent,
      },
      {
        'name': 'GKNM Hospital',
        'address': 'P.N. Palayam, Coimbatore',
        'distance': '4.9 km',
        'eta': '14 mins',
        'icuBeds': '3 ICU Beds Available',
        'traumaLevel': 'General ER & Heart Unit',
        'attending': 'Dr. Ragupathy',
        'phone': '+91 422 224 5000',
        'color': AppColors.esi3Urgent,
      },
    ],
    'Tirupur': [
      {
        'name': 'Revathi Medical Center',
        'address': 'Kumar Nagar, Avinashi Rd, Tirupur',
        'distance': '1.5 km',
        'eta': '5 mins',
        'icuBeds': '6 ICU Beds Available',
        'traumaLevel': 'Multispecialty Emergency Hub',
        'attending': 'Dr. R. Revathi',
        'phone': '+91 421 225 3300',
        'color': AppColors.esi4LessUrgent,
      },
      {
        'name': 'Sri Kumaran Hospital',
        'address': 'Bungalow Stop, Dharapuram Rd, Tirupur',
        'distance': '3.0 km',
        'eta': '9 mins',
        'icuBeds': '4 ICU Beds Available',
        'traumaLevel': 'Trauma & Critical Care',
        'attending': 'Dr. K. Kumaran',
        'phone': '+91 421 224 8888',
        'color': AppColors.esi2Emergent,
      },
      {
        'name': 'Govt Head Quarters Hospital Tirupur',
        'address': 'Main Rd, Tirupur',
        'distance': '2.1 km',
        'eta': '6 mins',
        'icuBeds': '10 ICU Beds (Govt)',
        'traumaLevel': '24x7 Regional Govt ER',
        'attending': 'Dr. M. Murugesan',
        'phone': '+91 421 224 0001',
        'color': AppColors.esi1Critical,
      },
      {
        'name': 'Velan Specialty Hospital',
        'address': 'Kangayam Rd, Tirupur',
        'distance': '4.5 km',
        'eta': '12 mins',
        'icuBeds': '2 ICU Beds Available',
        'traumaLevel': 'General Emergency Unit',
        'attending': 'Dr. V. Velan',
        'phone': '+91 421 242 4444',
        'color': AppColors.esi3Urgent,
      },
    ],
    'Chennai': [
      {
        'name': 'Apollo Hospitals (Greams Rd)',
        'address': '21 Greams Lane, Thousand Lights, Chennai',
        'distance': '2.0 km',
        'eta': '6 mins',
        'icuBeds': '15 ICU Beds Available',
        'traumaLevel': 'Level 1 Emergency & Heart Institute',
        'attending': 'Dr. Prathap C. Reddy',
        'phone': '+91 44 2829 0200',
        'color': AppColors.esi1Critical,
      },
      {
        'name': 'Fortis Malar Hospital',
        'address': '52 1st Main Rd, Gandhi Nagar, Adyar, Chennai',
        'distance': '4.2 km',
        'eta': '12 mins',
        'icuBeds': '7 ICU Beds Available',
        'traumaLevel': 'Super Specialty & Cardiac ER',
        'attending': 'Dr. K. R. Balakrishnan',
        'phone': '+91 44 4289 2222',
        'color': AppColors.esi2Emergent,
      },
      {
        'name': 'MIOT International',
        'address': '430 Mount Poonamallee Rd, Manapakkam, Chennai',
        'distance': '5.8 km',
        'eta': '15 mins',
        'icuBeds': '11 ICU Beds Available',
        'traumaLevel': 'Level 1 Ortho & Polytrauma ER',
        'attending': 'Dr. P. V. A. Mohandas',
        'phone': '+91 44 4200 2288',
        'color': AppColors.esi4LessUrgent,
      },
      {
        'name': 'Rajiv Gandhi Govt General Hospital',
        'address': 'EVR Periyar Salai, Park Town, Chennai',
        'distance': '3.1 km',
        'eta': '9 mins',
        'icuBeds': '25 ICU Beds (Govt)',
        'traumaLevel': 'Apex Regional Govt Trauma Hub',
        'attending': 'Dr. E. Theranirajan',
        'phone': '+91 44 2530 5000',
        'color': AppColors.esi1Critical,
      },
      {
        'name': 'SIMS Hospital (Vadapalani)',
        'address': '1 Jawaharlal Nehru Salai, Vadapalani, Chennai',
        'distance': '4.7 km',
        'eta': '13 mins',
        'icuBeds': '6 ICU Beds Available',
        'traumaLevel': 'Stroke & Advanced ER Care',
        'attending': 'Dr. Raju Sivasamy',
        'phone': '+91 44 4921 1455',
        'color': AppColors.esi3Urgent,
      },
      {
        'name': 'Kauvery Hospital',
        'address': '199 Luz Church Rd, Alwarpet, Chennai',
        'distance': '3.6 km',
        'eta': '10 mins',
        'icuBeds': '5 ICU Beds Available',
        'traumaLevel': 'Multispecialty Emergency Unit',
        'attending': 'Dr. Aravindan Selvaraj',
        'phone': '+91 44 4000 6000',
        'color': AppColors.esi2Emergent,
      },
    ],
  };

  List<Map<String, dynamic>> get _hospitals => _cityHospitals[_selectedCity] ?? _cityHospitals['Coimbatore']!;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMapLayer || Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.neutral100,
      body: Stack(
        children: [
          // 1. Google Maps Simulated Interactive Canvas with Route Lines & Markers
          Positioned.fill(
            child: _buildGoogleMapsCanvas(isDark),
          ),

          // 2. Top Header Bar: Emergency Status & Live ETA Card
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: _buildHeaderEtaCard(isDark),
          ),

          // 3. Right Floating Action Buttons Stack (Recenter, Layers, Call, SOS)
          Positioned(
            right: 16,
            bottom: 240,
            child: _buildFloatingActionButtonsStack(isDark),
          ),

          // 4. Draggable Emergency Bottom Sheet (Hospital & Ambulance Details)
          _buildDraggableBottomSheet(isDark),
        ],
      ),
    );
  }

  // ==========================================
  // 1. GOOGLE MAPS INTERACTIVE RADAR CANVAS
  // ==========================================
  Widget _buildGoogleMapsCanvas(bool isDark) {
    final LatLng userPos = GoogleMapsConfig.cityPickupLocations[_selectedCity] ?? GoogleMapsConfig.defaultPickupLocation;
    final LatLng ambPos = LatLng(userPos.latitude - 0.005, userPos.longitude - 0.004);

    final Set<Marker> markers = {
      // User Location Marker
      Marker(
        markerId: const MarkerId('user_location'),
        position: userPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: 'Patient Location ($_selectedCity)',
          snippet: 'Emergency Scene (Pulse Location)',
        ),
      ),
      // Dispatched ALS Unit Marker
      Marker(
        markerId: const MarkerId('active_ambulance'),
        position: ambPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: '108 TN ALS Unit',
          snippet: 'Responding • Speed 62 km/h',
        ),
      ),
    };

    // Add Hospital Markers
    for (int i = 0; i < _hospitals.length; i++) {
      final h = _hospitals[i];
      final LatLng? hPos = GoogleMapsConfig.hospitalLocations[h['name']];
      if (hPos != null) {
        final isSelected = i == _selectedHospitalIndex;
        markers.add(
          Marker(
            markerId: MarkerId('hosp_$i'),
            position: hPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isSelected ? BitmapDescriptor.hueRose : BitmapDescriptor.hueMagenta,
            ),
            infoWindow: InfoWindow(
              title: h['name'] as String,
              snippet: '${h['icuBeds']} • ETA ${h['eta']}',
            ),
            onTap: () {
              setState(() => _selectedHospitalIndex = i);
              _mapController?.animateCamera(CameraUpdate.newLatLngZoom(hPos, 14.5));
            },
          ),
        );
      }
    }

    final safeIndex = _selectedHospitalIndex < _hospitals.length ? _selectedHospitalIndex : 0;
    final selectedHospital = _hospitals[safeIndex];
    final LatLng? selectedHospitalPos = GoogleMapsConfig.hospitalLocations[selectedHospital['name']];

    final Set<Polyline> polylines = selectedHospitalPos != null
        ? {
            Polyline(
              polylineId: const PolylineId('hospital_radar_route'),
              points: [ambPos, userPos, selectedHospitalPos],
              color: AppColors.primary500,
              width: 5,
              jointType: JointType.round,
            ),
          }
        : {};

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: userPos,
        zoom: 13.0,
      ),
      style: isDark ? GoogleMapsConfig.darkMapStyle : null,
      markers: markers,
      polylines: polylines,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }

  // ==========================================
  // 2. TOP HEADER ETA & EMERGENCY CARD
  // ==========================================
  Widget _buildHeaderEtaCard(bool isDark) {
    final EsiSeverityLevel level = EsiSeverityLevel.esi1;
    final safeIndex = _selectedHospitalIndex < _hospitals.length ? _selectedHospitalIndex : 0;
    final selectedHospital = _hospitals[safeIndex];

    return Column(
      children: [
        // Emergency Status Pill & Back Button Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
                foregroundColor: isDark ? Colors.white : AppColors.neutral900,
              ),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => context.go(RouteNames.home),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: level.color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: level.color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'ESI LEVEL 1: ${level.name.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Tamil Nadu City Selection Chips Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: GoogleMapsConfig.supportedCities.map((city) {
              final isSelected = city == _selectedCity;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  selected: isSelected,
                  showCheckmark: false,
                  avatar: Icon(
                    Icons.location_city_rounded,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.primary500,
                  ),
                  label: Text(
                    city,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.neutral900),
                    ),
                  ),
                  backgroundColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
                  selectedColor: AppColors.primary500,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary500 : (isDark ? AppColors.darkBorder : AppColors.neutral200),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCity = city;
                        _selectedHospitalIndex = 0;
                      });
                      final targetCenter = GoogleMapsConfig.cityCenters[city];
                      if (targetCenter != null && _mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLngZoom(targetCenter, 13.0),
                        );
                      }
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // Live ETA Banner Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.neutral200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.esi1Critical,
                    ),
                    child: const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ambulance ETA: ${selectedHospital['eta']}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.esi1Critical,
                        ),
                      ),
                      Text(
                        'To ${selectedHospital['name']} (${selectedHospital['distance']})',
                        style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.esi4LessUrgent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ALS Unit En Route',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.esi4LessUrgent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. FLOATING ACTION BUTTONS STACK
  // ==========================================
  Widget _buildFloatingActionButtonsStack(bool isDark) {
    return Column(
      children: [
        // Layer Switcher (Light / Dark Map)
        FloatingActionButton.small(
          heroTag: 'fab_layer',
          backgroundColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
          foregroundColor: isDark ? Colors.white : AppColors.neutral900,
          onPressed: () {
            setState(() => _isDarkMapLayer = !_isDarkMapLayer);
          },
          child: Icon(_isDarkMapLayer ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
        ),
        const SizedBox(height: 10),

        // GPS Recenter Button
        FloatingActionButton.small(
          heroTag: 'fab_gps',
          backgroundColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
          foregroundColor: AppColors.primary500,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recentered on Current GPS Position')),
            );
          },
          child: const Icon(Icons.my_location_rounded),
        ),
        const SizedBox(height: 10),

        // Call Paramedic Direct FAB
        FloatingActionButton(
          heroTag: 'fab_call',
          backgroundColor: AppColors.esi4LessUrgent,
          foregroundColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calling ALS Ambulance Unit #402 Paramedic...')),
            );
          },
          child: const Icon(Icons.phone_rounded),
        ),
      ],
    );
  }

  // ==========================================
  // 4. DRAGGABLE EMERGENCY BOTTOM SHEET
  // ==========================================
  Widget _buildDraggableBottomSheet(bool isDark) {
    final safeIndex = _selectedHospitalIndex < _hospitals.length ? _selectedHospitalIndex : 0;
    final selectedHospital = _hospitals[safeIndex];

    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.18,
      maxChildSize: 0.70,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCanvas : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            children: [
              // Sheet Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.neutral200,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Selected Destination Hospital Profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedHospital['name'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${selectedHospital['traumaLevel']} • ${selectedHospital['distance']} away',
                          style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (selectedHospital['color'] as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      selectedHospital['icuBeds'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: selectedHospital['color'] as Color,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Row: Reserve Bed & Call ER
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.esi1Critical,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.lock_clock_outlined, size: 20),
                      label: const Text('RESERVE ER BED NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ICU Bed Locked at ${selectedHospital['name']}'),
                            backgroundColor: AppColors.esi1Critical,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.phone_outlined, color: AppColors.primary500),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dialing ${selectedHospital['name']} ER Desk...')),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Divider(color: isDark ? AppColors.darkBorder : AppColors.neutral200),

              const SizedBox(height: 12),

              // Nearby ER Hospitals Selection List
              Text(
                'Nearby ER Hospitals Radar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.neutral900,
                ),
              ),

              const SizedBox(height: 10),

              ...List.generate(_hospitals.length, (index) {
                final h = _hospitals[index];
                final isSelected = index == _selectedHospitalIndex;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => setState(() => _selectedHospitalIndex = index),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary500.withValues(alpha: 0.12)
                            : (isDark ? AppColors.darkSurfaceCard : AppColors.neutral100),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary500 : (isDark ? AppColors.darkBorder : AppColors.neutral200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_hospital_outlined, color: h['color'] as Color, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h['name'] as String,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  '${h['traumaLevel']} • ${h['distance']}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            h['icuBeds'] as String,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: h['color'] as Color),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
