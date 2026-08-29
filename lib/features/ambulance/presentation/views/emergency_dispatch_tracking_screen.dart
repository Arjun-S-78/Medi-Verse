import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/google_maps_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/widgets.dart';

/// Complete Emergency Dispatch & Live GPS Tracking Flow
/// Feature-First Clean Architecture: Presentation Layer
class EmergencyDispatchTrackingScreen extends StatefulWidget {
  final int initialStep; // 0 = Confirm, 1 = Searching, 2 = Assigned & Tracking

  const EmergencyDispatchTrackingScreen({
    super.key,
    this.initialStep = 0,
  });

  @override
  State<EmergencyDispatchTrackingScreen> createState() => _EmergencyDispatchTrackingScreenState();
}

class _EmergencyDispatchTrackingScreenState extends State<EmergencyDispatchTrackingScreen> {
  late int _dispatchStep;
  bool _notifyIceContacts = true;
  bool _shareMedicalPassport = true;
  final int _etaMinutes = 4;

  @override
  void initState() {
    super.initState();
    _dispatchStep = widget.initialStep;
  }

  void _startSearchingAmbulance() async {
    setState(() => _dispatchStep = 1); // Searching
    await Future.delayed(const Duration(milliseconds: 2400));
    if (mounted) {
      setState(() => _dispatchStep = 2); // Assigned & Live Tracking
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go(RouteNames.home),
        ),
        title: Text(
          _getStepTitle(),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Live Tracking Link copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: AppTokens.durationNormal,
          child: _buildCurrentDispatchStepWidget(isDark),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_dispatchStep) {
      case 0:
        return 'Confirm Dispatch';
      case 1:
        return 'Searching Fleet...';
      case 2:
        return 'En Route to Pickup';
      default:
        return 'Emergency Tracking';
    }
  }

  Widget _buildCurrentDispatchStepWidget(bool isDark) {
    switch (_dispatchStep) {
      case 0:
        return _buildConfirmationStepView(isDark);
      case 1:
        return _buildSearchingAmbulanceStepView(isDark);
      case 2:
        return _buildLiveTrackingAndAssignedView(isDark);
      default:
        return _buildConfirmationStepView(isDark);
    }
  }

  // STEP 1: EMERGENCY CONFIRMATION VIEW
  Widget _buildConfirmationStepView(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('ConfirmView'),
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceLg, vertical: AppTokens.spaceMd),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Header Alert Banner
              Container(
                padding: const EdgeInsets.all(AppTokens.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.esi1SurfaceLight,
                  borderRadius: AppTokens.borderRadiusLg,
                  border: Border.all(color: AppColors.esi1Critical, width: 1.5),
                  boxShadow: AppTokens.shadowEmergency(isDark),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.esi1Critical, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ESI Level 1 Emergency Confirmed',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.esi1Critical,
                            ),
                          ),
                          Text(
                            'ALS Ambulance & ER Trauma Bay Lock Requested',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.neutral700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0, duration: 400.ms),

              const SizedBox(height: AppTokens.spaceMd),

              // Pickup Location Map Preview Card
              _buildGoogleMapsPlaceholder(
                height: 160,
                isDark: isDark,
                overlayWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                    borderRadius: AppTokens.borderRadiusMd,
                    boxShadow: AppTokens.shadowSm(isDark),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location_rounded, color: AppColors.primary500, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Pickup: 5th Avenue, NYC (Accurate 5m)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTokens.spaceMd),

              // Destination ER Hospital Details Card
              Container(
                padding: const EdgeInsets.all(AppTokens.spaceMd),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                  borderRadius: AppTokens.borderRadiusLg,
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.neutral200),
                  boxShadow: AppTokens.shadowSm(isDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destination Hospital',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary500),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.local_hospital_outlined, color: AppColors.esi1Critical, size: 26),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'City General Hospital ER',
                                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Trauma Bay 2 • Attending: Dr. Sarah Vance',
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.neutral600),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '1.2 km',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.esi4LessUrgent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTokens.spaceMd),

              // Toggles: Family ICE Notification & Passport Sharing
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                  borderRadius: AppTokens.borderRadiusLg,
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.neutral200),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _notifyIceContacts,
                      activeThumbColor: AppColors.primary500,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Notify ICE Contacts (Spouse & Parent)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text('Send SMS alert with live GPS tracking link', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.neutral600)),
                      onChanged: (val) => setState(() => _notifyIceContacts = val),
                    ),
                    Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.neutral200),
                    SwitchListTile(
                      value: _shareMedicalPassport,
                      activeThumbColor: AppColors.primary500,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Transmit Emergency Health Passport', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text('Shares blood group & allergies with paramedic tablet', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.neutral600)),
                      onChanged: (val) => setState(() => _shareMedicalPassport = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTokens.spaceXl),

              // Dispatch Primary Action Button
              EmergencyButton(
                isFullWidth: true,
                label: 'CONFIRM & DISPATCH AMBULANCE NOW',
                onTap: _startSearchingAmbulance,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STEP 2: SEARCHING AMBULANCE RADAR VIEW
  Widget _buildSearchingAmbulanceStepView(bool isDark) {
    return Center(
      key: const ValueKey('SearchingView'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Radar Pulse Waves
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.esi1Critical.withValues(alpha: 0.15),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.35, 1.35), duration: 1100.ms),

                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.esi1Critical,
                  ),
                  child: const Icon(Icons.airport_shuttle_rounded, color: Colors.white, size: 56),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXl),
            Text(
              'Pinging Nearby ALS Ambulances...',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'Contacting 3 nearby Advanced Life Support units within 2 km radius.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.neutral600),
            ),
            const SizedBox(height: AppTokens.spaceXl),
            SizedBox(
              width: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: const LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: AppColors.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.esi1Critical),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 3 & 4: AMBULANCE ASSIGNED & LIVE TRACKING
  Widget _buildLiveTrackingAndAssignedView(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          // Desktop / Wide Screen Split View: Map on Left, Information Sheet on Right
          return Row(
            key: const ValueKey('LiveTrackingViewWide'),
            children: [
              Expanded(
                flex: 6,
                child: _buildMapSection(isDark),
              ),
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTokens.spaceLg),
                  child: _buildTrackingDetailsSheet(isDark),
                ),
              ),
            ],
          );
        }

        // Mobile Stacked Layout
        return Column(
          key: const ValueKey('LiveTrackingViewMobile'),
          children: [
            Expanded(
              flex: 5,
              child: _buildMapSection(isDark),
            ),
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceLg, vertical: AppTokens.spaceMd),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCanvas : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.radius2Xl)),
                  boxShadow: AppTokens.shadowLg(isDark),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildTrackingDetailsSheet(isDark),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMapSection(bool isDark) {
    return Stack(
      children: [
        _buildGoogleMapsPlaceholder(
          height: double.infinity,
          isDark: isDark,
          showLiveVehicleMarker: true,
          overlayWidget: Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                borderRadius: AppTokens.borderRadiusLg,
                boxShadow: AppTokens.shadowMd(isDark),
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
                            'ETA: $_etaMinutes Minutes',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.esi1Critical),
                          ),
                          const Text(
                            'Distance: 1.2 km • Traffic Light',
                            style: TextStyle(fontSize: 11, color: AppColors.neutral600),
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
                      'En Route',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.esi4LessUrgent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingDetailsSheet(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag Handle Indicator
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

        const SizedBox(height: AppTokens.spaceMd),

        // Assigned Driver & Paramedic Card
        Container(
          padding: const EdgeInsets.all(AppTokens.spaceMd),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceCard : AppColors.neutral100,
            borderRadius: AppTokens.borderRadiusLg,
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.neutral200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary500.withValues(alpha: 0.2),
                    child: const Icon(Icons.person_rounded, color: AppColors.primary500, size: 30),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Driver: K. Karthik',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Paramedic: S. Ramanan, EMT-P',
                          style: TextStyle(fontSize: 12, color: AppColors.neutral600),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '4.9 (520 Dispatches)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Quick Action Buttons
                  IconButton.filledTonal(
                    icon: const Icon(Icons.phone_rounded, color: AppColors.esi4LessUrgent),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling 108 Paramedic S. Ramanan directly...')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.neutral200),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vehicle: 108 TN ALS Unit',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Plate: TN-37-AM-1080',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary500),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTokens.spaceMd),

        // Destination Hospital Summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceCard : AppColors.neutral100,
            borderRadius: AppTokens.borderRadiusLg,
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.neutral200),
          ),
          child: const Row(
            children: [
              Icon(Icons.local_hospital_outlined, color: AppColors.esi1Critical, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PSG Hospitals ER (Trauma Bay 2 Reserved)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Attending: Dr. S. Rajendran • ICU Bed Reserved',
                      style: TextStyle(fontSize: 11, color: AppColors.neutral600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTokens.spaceMd),

        // Emergency Status Timeline Progress Stepper
        Text(
          'Emergency Status Timeline',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 12),
        _buildTimelineStep('1. Emergency Requested', 'SOS verified & ESI 1 priority assigned', true, isDark),
        _buildTimelineStep('2. 108 Ambulance Assigned', 'TN-37-AM-1080 accepted dispatch', true, isDark),
        _buildTimelineStep('3. Ambulance En Route', 'Driver is 1.2 km away (ETA 4 mins)', true, isDark),
        _buildTimelineStep('4. Patient Handover', 'PSG Hospitals Trauma Bay 2 transfer', false, isDark),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isCompleted, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppColors.esi4LessUrgent : (isDark ? AppColors.darkBorder : AppColors.neutral200),
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.circle_outlined,
              size: 14,
              color: isCompleted ? Colors.white : AppColors.neutral600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? (isDark ? Colors.white : AppColors.neutral900)
                        : AppColors.neutral600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.neutral600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMapsPlaceholder({
    required double height,
    required bool isDark,
    Widget? overlayWidget,
    bool showLiveVehicleMarker = false,
  }) {
    final LatLng pickupPos = GoogleMapsConfig.cityPickupLocations['Coimbatore']!;
    final LatLng ambPos = LatLng(
      pickupPos.latitude - 0.008,
      pickupPos.longitude - 0.006,
    );
    final LatLng hospitalPos = GoogleMapsConfig.hospitalLocations['PSG Hospitals']!;

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('pickup_location'),
        position: pickupPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(
          title: 'Patient Pickup Point',
          snippet: 'Avinashi Rd, Peelamedu, Coimbatore',
        ),
      ),
      if (showLiveVehicleMarker)
        Marker(
          markerId: const MarkerId('assigned_ambulance'),
          position: ambPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: 'Assigned 108 Unit (TN-37-AM-1080)',
            snippet: 'En Route • ETA 4 Mins • 64 km/h',
          ),
        ),
      Marker(
        markerId: const MarkerId('destination_hospital'),
        position: hospitalPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        infoWindow: const InfoWindow(
          title: 'PSG Hospitals ER',
          snippet: 'Destination ER • Trauma Bay 2',
        ),
      ),
    };

    final Set<Polyline> polylines = showLiveVehicleMarker
        ? {
            Polyline(
              polylineId: const PolylineId('dispatch_route'),
              points: [ambPos, pickupPos, hospitalPos],
              color: AppColors.primary500,
              width: 5,
              jointType: JointType.round,
            ),
          }
        : {};

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: AppTokens.borderRadiusLg,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: pickupPos,
              zoom: 14.0,
            ),
            style: isDark ? GoogleMapsConfig.darkMapStyle : null,
            markers: markers,
            polylines: polylines,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),
          ?overlayWidget,
        ],
      ),
    );
  }
}
