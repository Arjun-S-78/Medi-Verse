import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
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
  int _selectedHospitalIndex = 0;
  bool _isDarkMapLayer = false;

  final List<Map<String, dynamic>> _hospitals = [
    {
      'name': 'City General Hospital ER',
      'distance': '1.2 km',
      'eta': '4 mins',
      'icuBeds': '4 ICU Beds Available',
      'traumaLevel': 'Level 1 Trauma Center',
      'attending': 'Dr. Sarah Vance',
      'phone': '+1 (555) 019-2834',
      'color': AppColors.esi4LessUrgent,
      'pinOffset': const Offset(260, 180),
    },
    {
      'name': 'St. Jude Medical Center',
      'distance': '2.5 km',
      'eta': '7 mins',
      'icuBeds': '2 ICU Beds Available',
      'traumaLevel': 'Cardiac ER Unit',
      'attending': 'Dr. Robert Chen',
      'phone': '+1 (555) 019-9988',
      'color': AppColors.esi3Urgent,
      'pinOffset': const Offset(100, 120),
    },
    {
      'name': 'Memorial ER Care',
      'distance': '4.1 km',
      'eta': '12 mins',
      'icuBeds': '1 ICU Bed Available',
      'traumaLevel': 'General ER',
      'attending': 'Dr. Emily Watson',
      'phone': '+1 (555) 019-4411',
      'color': AppColors.esi2Emergent,
      'pinOffset': const Offset(310, 320),
    },
  ];

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
  // 1. GOOGLE MAPS SIMULATED CANVAS
  // ==========================================
  Widget _buildGoogleMapsCanvas(bool isDark) {
    final selectedHospital = _hospitals[_selectedHospitalIndex];

    return GestureDetector(
      onPanUpdate: (_) {}, // Drag interaction
      child: Stack(
        children: [
          // Grid Map & Polyline Painter
          CustomPaint(
            size: Size.infinite,
            painter: _GoogleMapCanvasPainter(
              isDark: isDark,
              destinationOffset: selectedHospital['pinOffset'] as Offset,
            ),
          ),

          // Current User Location Marker (Pulse Pin)
          Positioned(
            top: 240,
            left: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary500.withValues(alpha: 0.25),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.4, 1.4), duration: 1000.ms),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary500,
                    boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10)],
                  ),
                  child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),

          // Live Moving ALS Ambulance Marker
          Positioned(
            top: 190,
            left: 140,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.esi1Critical,
                boxShadow: [
                  BoxShadow(color: AppColors.esi1Critical, blurRadius: 14, spreadRadius: 2),
                ],
              ),
              child: const Icon(Icons.airport_shuttle_rounded, color: Colors.white, size: 22),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .slideX(begin: 0, end: 0.15, duration: 2000.ms),
          ),

          // Interactive Hospital Markers on Map
          ...List.generate(_hospitals.length, (index) {
            final h = _hospitals[index];
            final Offset pos = h['pinOffset'] as Offset;
            final isSelected = index == _selectedHospitalIndex;

            return Positioned(
              top: pos.dy,
              left: pos.dx,
              child: GestureDetector(
                onTap: () => setState(() => _selectedHospitalIndex = index),
                child: Column(
                  children: [
                    // Hospital Callout Bubble
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary500 : AppColors.neutral200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_hospital_outlined, color: h['color'] as Color, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            h['name'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.primary500, size: 24),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 2. TOP HEADER ETA & EMERGENCY CARD
  // ==========================================
  Widget _buildHeaderEtaCard(bool isDark) {
    final EsiSeverityLevel level = EsiSeverityLevel.esi1;
    final selectedHospital = _hospitals[_selectedHospitalIndex];

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
    final selectedHospital = _hospitals[_selectedHospitalIndex];

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

// Google Maps Interactive Canvas Painter (Grid, Terrain & Polylines)
class _GoogleMapCanvasPainter extends CustomPainter {
  final bool isDark;
  final Offset destinationOffset;

  _GoogleMapCanvasPainter({
    required this.isDark,
    required this.destinationOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Map Canvas Base Tint
    final bgPaint = Paint()..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Map Grid / Street Lines
    final streetPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white
      ..strokeWidth = 6.0;

    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), streetPaint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), streetPaint);
    }

    // Active Polyline Route (Connecting Ambulance -> User -> Hospital)
    final routePaint = Paint()
      ..color = AppColors.primary500
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(140, 190) // Ambulance
      ..lineTo(180, 240) // User GPS
      ..lineTo(destinationOffset.dx + 20, destinationOffset.dy + 20); // Destination Hospital

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant _GoogleMapCanvasPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.destinationOffset != destinationOffset;
  }
}
