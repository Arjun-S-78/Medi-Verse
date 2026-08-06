import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';

/// Enterprise Patient Home Dashboard for MediVerse
class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _selectedNavIndex = 0;

  // Mock Patient Data
  final String _patientName = 'Sarah Jenkins';
  final String _bloodGroup = 'O+';
  final String _iceContact = 'Spouse (+1 555-0192)';
  final String _allergies = 'Penicillin';
  final String _vitals = '72 BPM • 98% SpO2';

  // Mock Nearby Hospitals Data
  final List<Map<String, dynamic>> _hospitals = [
    {
      'name': 'City General Hospital ER',
      'distance': '1.2 km away',
      'icuBeds': '4 Beds Free',
      'type': 'Trauma Level 1',
      'eta': '4 mins',
      'status': StatusBadgeType.lessUrgent,
    },
    {
      'name': 'St. Jude Emergency Center',
      'distance': '2.5 km away',
      'icuBeds': '2 Beds Free',
      'type': 'Cardiac Care Unit',
      'eta': '8 mins',
      'status': StatusBadgeType.urgent,
    },
    {
      'name': 'Memorial Urgent Care',
      'distance': '4.1 km away',
      'icuBeds': '1 Bed Free',
      'type': 'General Emergency',
      'eta': '12 mins',
      'status': StatusBadgeType.emergent,
    },
  ];

  // Mock Recent Emergency Requests
  final List<Map<String, dynamic>> _recentRequests = [
    {
      'title': 'Chest Pain & AI Triage Assessment',
      'date': 'Aug 2, 2026 • 14:32',
      'hospital': 'City General ER',
      'status': 'Handover Complete',
      'badgeType': StatusBadgeType.completed,
      'color': AppColors.esi1Critical,
    },
    {
      'title': 'Asthma Respiratory Triage',
      'date': 'Jul 19, 2026 • 09:15',
      'hospital': 'St. Jude Medical',
      'status': 'Resolved',
      'badgeType': StatusBadgeType.completed,
      'color': AppColors.esi3Urgent,
    },
  ];

  // Mock Health Tips
  final List<Map<String, dynamic>> _healthTips = [
    {
      'title': 'CPR Emergency Protocol',
      'subtitle': 'Key steps for cardiac arrest response',
      'icon': Icons.favorite_border_rounded,
      'color': AppColors.esi1Critical,
    },
    {
      'title': 'Stroke FAST Rules',
      'subtitle': 'Face, Arms, Speech & Time checklist',
      'icon': Icons.health_and_safety_outlined,
      'color': AppColors.secondary500,
    },
    {
      'title': 'Heat Stroke Care',
      'subtitle': 'Immediate cooling first-aid techniques',
      'icon': Icons.wb_sunny_outlined,
      'color': AppColors.esi2Emergent,
    },
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Emergency Notifications',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildNotificationItem(
                '🚨 ALS Ambulance #402 Stationed Nearby',
                '2 mins ago',
                AppColors.esi1Critical,
                isDark,
              ),
              _buildNotificationItem(
                '🏥 City General ER updated ICU Beds (4 Free)',
                '15 mins ago',
                AppColors.primary500,
                isDark,
              ),
              _buildNotificationItem(
                '🩸 Emergency Health Passport synced with Cloud',
                '1 hr ago',
                AppColors.esi4LessUrgent,
                isDark,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(String title, String time, Color dotColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.neutral100 : AppColors.neutral900,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark ? AppColors.neutral400 : AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.neutral100,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary500.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.medical_services_rounded,
                color: isDark ? AppColors.primaryAccent : AppColors.primary500,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Medi',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.neutral900,
                    ),
                  ),
                  TextSpan(
                    text: 'Verse',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.primaryAccent : AppColors.primary400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Notification Bell Icon with Badge Count
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 26),
                onPressed: _showNotificationsSheet,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.esi1Critical,
                  ),
                  child: Text(
                    '3',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 800));
          },
          color: isDark ? AppColors.primaryAccent : AppColors.primary500,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1 & 2. Greeting & Patient Name Header
                _buildGreetingSection(isDark),

                const SizedBox(height: 20),

                // 3. Prominent Emergency SOS Button
                _buildEmergencyButtonSection(isDark),

                const SizedBox(height: 24),

                // 4. Medical Summary Card
                _buildMedicalSummaryCard(isDark),

                const SizedBox(height: 24),

                // 5. Nearby Hospitals Section
                _buildNearbyHospitalsSection(isDark),

                const SizedBox(height: 24),

                // 6. Recent Emergency Requests Section
                _buildRecentEmergencyRequestsSection(isDark),

                const SizedBox(height: 24),

                // 7. Health Tips Section
                _buildHealthTipsSection(isDark),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDark),
    );
  }

  // Section 1 & 2: Greeting & Patient Name
  Widget _buildGreetingSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.neutral200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                    ),
                  ),
                  Text(
                    _patientName,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.neutral900,
                    ),
                  ),
                ],
              ),
              StatusBadge.active(label: 'AI Ready'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.primaryAccent : AppColors.primary500).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: isDark ? AppColors.primaryAccent : AppColors.primary500,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '5th Avenue, NYC • GPS Signal High Accuracy',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0, duration: 400.ms);
  }

  // Section 3: Large Emergency Button Component
  Widget _buildEmergencyButtonSection(bool isDark) {
    return Center(
      child: Column(
        children: [
          EmergencyButton(
            label: 'EMERGENCY SOS',
            subtitle: 'Press for instant dispatch',
            size: 135,
            onTap: () {
              context.go(RouteNames.sosModal);
            },
          ),
          const SizedBox(height: 14),
          Text(
            'TAP FOR AI NURSE TRIAGE & AMBULANCE DISPATCH',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? AppColors.neutral400 : AppColors.neutral600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 500.ms);
  }

  // Section 4: Medical Summary Card
  Widget _buildMedicalSummaryCard(bool isDark) {
    return MedicalCard(
      title: 'Medical Passport Summary',
      subtitle: 'Encrypted Emergency Record',
      icon: Icons.health_and_safety_outlined,
      iconColor: isDark ? AppColors.primaryAccent : AppColors.primary500,
      badgeText: 'Verified',
      badgeColor: AppColors.esi4LessUrgent,
      child: Column(
        children: [
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryMetric('Blood', _bloodGroup, Icons.bloodtype_outlined, AppColors.esi1Critical, isDark),
              _buildMetricDivider(isDark),
              _buildSummaryMetric('Allergies', _allergies, Icons.warning_amber_rounded, AppColors.esi2Emergent, isDark),
              _buildMetricDivider(isDark),
              _buildSummaryMetric('Vitals', _vitals, Icons.favorite_outline_rounded, AppColors.secondary500, isDark),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCanvas : AppColors.neutral100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.contact_phone_outlined, size: 16, color: AppColors.primary500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ICE Contact: $_iceContact',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms, duration: 500.ms);
  }

  Widget _buildSummaryMetric(String label, String value, IconData icon, Color iconColor, bool isDark) {
    return Column(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.neutral100 : AppColors.neutral900,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: isDark ? AppColors.neutral400 : AppColors.neutral600,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricDivider(bool isDark) {
    return Container(
      height: 28,
      width: 1,
      color: isDark ? AppColors.darkBorder : AppColors.neutral200,
    );
  }

  // Section 5: Nearby Hospitals
  Widget _buildNearbyHospitalsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Nearby ER Hospitals', 'View Map', isDark, () {
          context.go(RouteNames.hospitalSearch);
        }),
        const SizedBox(height: 12),
        SizedBox(
          height: 145,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _hospitals.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final hospital = _hospitals[index];
              return Container(
                width: 250,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.neutral200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hospital['name'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.neutral900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.local_hospital_outlined, size: 20, color: AppColors.esi1Critical),
                      ],
                    ),
                    Text(
                      '${hospital['type']} • ${hospital['eta']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          hospital['distance'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.neutral100 : AppColors.neutral900,
                          ),
                        ),
                        StatusBadge(
                          label: hospital['icuBeds'] as String,
                          type: hospital['status'] as StatusBadgeType,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms, duration: 500.ms);
  }

  // Section 6: Recent Emergency Requests
  Widget _buildRecentEmergencyRequestsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Recent Triage Logs', 'History', isDark, () {}),
        const SizedBox(height: 12),
        Column(
          children: _recentRequests.map((req) {
            final Color accentColor = req['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MedicalCard(
                accentColor: accentColor,
                title: req['title'] as String,
                subtitle: '${req['date']} • ${req['hospital']}',
                badgeText: req['status'] as String,
                badgeColor: AppColors.esi4LessUrgent,
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 450.ms, duration: 500.ms);
  }

  // Section 7: Health Tips
  Widget _buildHealthTipsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Emergency First-Aid Guides', 'Explore', isDark, () {}),
        const SizedBox(height: 12),
        Row(
          children: _healthTips.map((tip) {
            final Color color = tip['color'] as Color;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.neutral200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(tip['icon'] as IconData, color: color, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      tip['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tip['subtitle'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 550.ms, duration: 500.ms);
  }

  // Section Header Helper
  Widget _buildSectionHeader(String title, String action, bool isDark, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.neutral900,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            action,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.primaryAccent : AppColors.primary500,
            ),
          ),
        ),
      ],
    );
  }

  // Section 8: Bottom Navigation Bar
  Widget _buildBottomNavigationBar(bool isDark) {
    return NavigationBar(
      selectedIndex: _selectedNavIndex,
      backgroundColor: isDark ? AppColors.darkSurfaceCard : Colors.white,
      indicatorColor: (isDark ? AppColors.primaryAccent : AppColors.primary500).withValues(alpha: 0.18),
      onDestinationSelected: (index) {
        setState(() => _selectedNavIndex = index);
        if (index == 1) {
          context.go(RouteNames.triageAssess);
        } else if (index == 2) {
          context.go(RouteNames.hospitalSearch);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary500),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.psychology_outlined),
          selectedIcon: Icon(Icons.psychology_rounded, color: AppColors.primary500),
          label: 'AI Triage',
        ),
        NavigationDestination(
          icon: Icon(Icons.local_hospital_outlined),
          selectedIcon: Icon(Icons.local_hospital_rounded, color: AppColors.primary500),
          label: 'Hospitals',
        ),
        NavigationDestination(
          icon: Icon(Icons.badge_outlined),
          selectedIcon: Icon(Icons.badge_rounded, color: AppColors.primary500),
          label: 'Passport',
        ),
      ],
    );
  }
}
