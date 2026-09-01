import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../triage/domain/services/mira_intent_orchestrator.dart';
import '../../../triage/presentation/providers/mira_conversation_provider.dart';
import '../../../triage/presentation/providers/mira_tts_provider.dart';

/// Enterprise Premium Patient Home Dashboard for MediVerse
/// High-fidelity execution matching the reference design:
/// - MIRA upper-body portrait (~45% left hero) with neon circular light halo portal
/// - Large high-impact gradient typography ("Hi, I'm MIRA ✨ Your AI Health Assistant")
/// - 2x3 Quick Actions Grid with 24-28px glowing interactive icons
/// - MIRA Health Tip of the Day panel with 3D Heart ECG visual
/// - 4 Summary Metric Cards with action buttons (View Details, View All) & hover elevation
/// - Bottom MIRA Assistant Panel with MIRA portrait, voice status, chips, 4 quick tools & mic CTA
class PatientDashboardScreen extends ConsumerStatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  ConsumerState<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends ConsumerState<PatientDashboardScreen> {
  int _selectedNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Patient Profile Data matching reference
  final String _patientName = 'John Doe';
  final String _patientRole = 'Patient';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleMiraQuickIntent(String promptText) {
    final result = MiraIntentOrchestrator.parseIntent(promptText);

    if (result.intentType == MiraIntentType.emergencyTriage) {
      ref.read(miraConversationProvider.notifier).sendPatientMessage(promptText);
      ref.read(miraTtsProvider.notifier).speakText(result.miraResponse);
      context.push(RouteNames.triageAssess);
    } else {
      ref.read(miraConversationProvider.notifier).sendPatientMessage(promptText);
      context.push(RouteNames.triageAssess);
    }
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(AppTokens.spaceLg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceCard : const Color(0xFF0F172A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.radius2Xl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Emergency & Health Alerts',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.spaceMd),
              const NotificationCard(
                title: 'AMBULANCE ASSIGNED',
                message: 'Unit #AMB-409 dispatched to your location. ETA 4 mins.',
                time: '2 mins ago',
                isUnread: true,
              ),
              const SizedBox(height: AppTokens.spaceSm),
              const NotificationCard(
                title: 'MIRA CARE SUMMARY',
                message: 'City General ER trauma team briefed on vital signs.',
                time: '15 mins ago',
              ),
              const SizedBox(height: AppTokens.spaceLg),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = true;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF050814), // Deep Midnight Obsidian Canvas
      drawer: !isDesktop ? Drawer(child: _buildSidebar(isDark, isDrawer: true)) : null,
      body: SafeArea(
        child: Row(
          children: [
            // Fixed Left Navigation Sidebar for Desktop
            if (isDesktop) _buildSidebar(isDark),

            // Main Workspace Content Area
            Expanded(
              child: Column(
                children: [
                  // Top Header Bar with Search & Profile
                  _buildTopHeader(isDark, showMenuButton: !isDesktop),

                  // Main Scrollable Dashboard Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ROW 1: MIRA Hero Section + Quick Actions Grid
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 7, child: _buildMiraHeroCard(isDark)),
                                const SizedBox(width: 20),
                                Expanded(flex: 5, child: _buildQuickActionsColumn(isDark)),
                              ],
                            )
                          else ...[
                            _buildMiraHeroCard(isDark),
                            const SizedBox(height: 20),
                            _buildQuickActionsColumn(isDark),
                          ],

                          const SizedBox(height: 20),

                          // ROW 2: MIRA Health Tip of the Day Panel
                          _buildHealthTipPanel(isDark),

                          const SizedBox(height: 20),

                          // ROW 3: 4 Health Summary Metric Cards Grid
                          _buildHealthSummaryCardsGrid(isDark, isDesktop),

                          const SizedBox(height: 20),

                          // ROW 4: Bottom MIRA Interaction Bar
                          _buildBottomMiraAssistantPanel(isDark),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 1. LEFT SIDEBAR NAVIGATION MATRIX
  // ------------------------------------------------------------
  Widget _buildSidebar(bool isDark, {bool isDrawer = false}) {
    return Container(
      width: 270,
      color: const Color(0xFF070B18),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MediVerse Header Logo & Tagline
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.55),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                    Positioned(
                      right: 7,
                      bottom: 7,
                      child: Icon(Icons.add, color: Colors.white, size: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MediVerse',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    'Your Health, Our Priority',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Sidebar Navigation Links List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home', isDark, isSelected: _selectedNavIndex == 0, onTap: () => setState(() => _selectedNavIndex = 0)),
                _buildNavItem(1, Icons.health_and_safety_outlined, 'Symptom Checker', isDark, onTap: () => context.push(RouteNames.triageAssess)),
                _buildNavItem(2, Icons.chat_bubble_outline_rounded, 'AI Consultation', isDark, onTap: () => context.push(RouteNames.triageAssess)),
                _buildNavItem(3, Icons.person_search_outlined, 'Find Doctors', isDark, onTap: () => context.push(RouteNames.doctorBooking)),
                _buildNavItem(4, Icons.domain_outlined, 'Hospitals', isDark, onTap: () => context.push(RouteNames.hospitalSearch)),
                _buildNavItem(5, Icons.calendar_month_outlined, 'Appointments', isDark, onTap: () => context.push(RouteNames.doctorBooking)),
                _buildNavItem(6, Icons.assignment_outlined, 'Health Records', isDark, onTap: () => context.go(RouteNames.healthPassport)),
                _buildNavItem(7, Icons.receipt_long_outlined, 'Prescriptions', isDark, onTap: () => context.go(RouteNames.healthPassport)),
                _buildNavItem(8, Icons.tune_rounded, 'Health Insights', isDark, onTap: () => context.go(RouteNames.healthPassport)),
                _buildNavItem(9, Icons.shield_outlined, 'Emergency', isDark, isEmergency: true, onTap: () => context.go(RouteNames.sosModal)),
              ],
            ),
          ),

          // Emergency Dial 108 Card
          _InteractiveHoverCard(
            accentColor: const Color(0xFFF43F5E),
            isEmergency: true,
            onTap: () => context.go(RouteNames.sosModal),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_enabled_rounded, color: Color(0xFFFB7185), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFDA4AF),
                          ),
                        ),
                        Text(
                          'Dial 108',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Get immediate help',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    bool isDark, {
    bool isSelected = false,
    bool isEmergency = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              border: isSelected
                  ? Border.all(color: const Color(0xFFA78BFA).withValues(alpha: 0.8), width: 1.2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.55),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? Colors.white
                      : (isEmergency ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8)),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isEmergency ? const Color(0xFFF43F5E) : const Color(0xFFCBD5E1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 2. TOP HEADER BAR COMPONENT
  // ------------------------------------------------------------
  Widget _buildTopHeader(bool isDark, {bool showMenuButton = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF090D1E),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF1E293B),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showMenuButton)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),

          // Search Bar Input Field (Large, centered, rounded pill)
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF0E1528),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFF1E293B),
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search symptoms, diseases, doctors...',
                  hintStyle: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF64748B)),
                  contentPadding: const EdgeInsets.only(left: 24, top: 13, bottom: 13),
                  suffixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 24),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) => _handleMiraQuickIntent(value),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Notifications Bell Button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFFCBD5E1), size: 26),
                onPressed: _showNotificationsSheet,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
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
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Patient User Profile Pill
          InkWell(
            onTap: () => context.go(RouteNames.healthPassport),
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _patientName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _patientRole,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // 3. MAIN MIRA HERO CARD (DOMINANT PORTRAIT PRESENTATION)
  // ------------------------------------------------------------
  Widget _buildMiraHeroCard(bool isDark) {
    final ttsState = ref.watch(miraTtsProvider);

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1630), Color(0xFF141D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isStacked = constraints.maxWidth < 620;

          // MIRA Portrait Section occupying ~40-45% of Hero
          final avatarSection = SizedBox(
            width: isStacked ? double.infinity : (constraints.maxWidth * 0.42),
            height: isStacked ? 300 : 360,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Background Glowing Neon Halo / Light Portal behind MIRA
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFA855F7).withValues(alpha: 0.5),
                          const Color(0xFFEC4899).withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // Subtle Circular Neon Ring accent behind MIRA's head
                Positioned(
                  top: 10,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC084FC).withValues(alpha: 0.85),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA855F7).withValues(alpha: 0.65),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),

                // Large MIRA Image in native upper-body aspect ratio
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/MIRA.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/mira.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (context, error2, stackTrace2) {
                            return Image.file(
                              File('C:\\Users\\C.PRAGATHESWARAN\\OneDrive\\Desktop\\Mediverse\\MIRA.png'),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Top-Left Online Status Pill Badge: ● Online
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF10B981), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Online',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Glass Badge overlay over lower scrub top: ||| MIRA
                Positioned(
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.75), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA855F7).withValues(alpha: 0.45),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.graphic_eq_rounded, color: Color(0xFFC084FC), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'MIRA',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

          // Hero Right Details & Headline Section (~55-60%)
          final detailsSection = Column(
            crossAxisAlignment: isStacked ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hi, I\'m',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFE9D5FF), Color(0xFFC084FC), Color(0xFFF472B6)],
                    ).createShader(bounds),
                    child: Text(
                      'MIRA',
                      style: GoogleFonts.poppins(
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.auto_awesome, color: Color(0xFFC084FC), size: 34),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Your AI Health Assistant',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'I\'m here to listen, understand your health concerns and guide you with accurate information.',
                textAlign: isStacked ? TextAlign.center : TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.5,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 20),

              // 3 Feature Badges with Large Icons
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: isStacked ? WrapAlignment.center : WrapAlignment.start,
                children: [
                  _buildHeroFeatureBadge(Icons.access_time_rounded, '24/7 Available'),
                  _buildHeroFeatureBadge(Icons.psychology_outlined, 'AI Powered'),
                  _buildHeroFeatureBadge(Icons.shield_outlined, 'Privacy First'),
                ],
              ),

              const SizedBox(height: 24),

              // Primary Action Button: Chat with MIRA
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFFC084FC)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9333EA).withValues(alpha: 0.65),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.graphic_eq_rounded, size: 22, color: Colors.white),
                  label: Text(
                    ttsState.isSpeaking ? 'MIRA Speaking...' : 'Chat with MIRA',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 17),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  onPressed: () => context.push(RouteNames.triageAssess),
                ),
              ),
            ],
          );

          if (isStacked) {
            return Column(
              children: [
                avatarSection,
                const SizedBox(height: 24),
                detailsSection,
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                avatarSection,
                const SizedBox(width: 28),
                Expanded(child: detailsSection),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildHeroFeatureBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1528),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFC084FC)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // 4. QUICK ACTIONS GRID COMPONENT (LARGE ICONS & HOVER FEEDBACK)
  // ------------------------------------------------------------
  Widget _buildQuickActionsColumn(bool isDark) {
    final actions = [
      {
        'title': 'Symptom\nChecker',
        'icon': Icons.medical_services_outlined,
        'color': const Color(0xFF38BDF8),
        'bg': const Color(0xFF0C2A4A),
        'onTap': () => context.push(RouteNames.triageAssess),
      },
      {
        'title': 'AI\nConsultation',
        'icon': Icons.chat_bubble_outline_rounded,
        'color': const Color(0xFF2DD4BF),
        'bg': const Color(0xFF0B2E2B),
        'onTap': () => context.push(RouteNames.triageAssess),
      },
      {
        'title': 'Find\nDoctors',
        'icon': Icons.person_search_outlined,
        'color': const Color(0xFF818CF8),
        'bg': const Color(0xFF1E1B4B),
        'onTap': () => context.push(RouteNames.doctorBooking),
      },
      {
        'title': 'Book\nAppointment',
        'icon': Icons.calendar_month_outlined,
        'color': const Color(0xFFF472B6),
        'bg': const Color(0xFF3B0726),
        'onTap': () => context.push(RouteNames.doctorBooking),
      },
      {
        'title': 'Health\nRecords',
        'icon': Icons.description_outlined,
        'color': const Color(0xFF34D399),
        'bg': const Color(0xFF062E1F),
        'onTap': () => context.go(RouteNames.healthPassport),
      },
      {
        'title': 'Emergency\nHelp',
        'icon': Icons.notifications_active_outlined,
        'color': const Color(0xFFFB7185),
        'bg': const Color(0xFF4C0519),
        'isEmergency': true,
        'onTap': () => context.go(RouteNames.sosModal),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.38,
          ),
          itemBuilder: (context, index) {
            final act = actions[index];
            final color = act['color'] as Color;
            final bg = act['bg'] as Color;
            final isEm = act['isEmergency'] as bool? ?? false;

            return _InteractiveHoverCard(
              accentColor: color,
              isEmergency: isEm,
              onTap: act['onTap'] as VoidCallback,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: bg,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.35),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(act['icon'] as IconData, color: color, size: 24),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 20),
                      ],
                    ),
                    Text(
                      act['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isEm ? const Color(0xFFFB7185) : Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // 5. MIRA HEALTH TIP OF THE DAY PANEL
  // ------------------------------------------------------------
  Widget _buildHealthTipPanel(bool isDark) {
    return _InteractiveHoverCard(
      accentColor: const Color(0xFFC084FC),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFC084FC), Color(0xFFF472B6)],
                        ).createShader(bounds),
                        child: Text(
                          'MIRA',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Health Tip of the Day',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"Stay hydrated, eat balanced meals, and get enough sleep. Small daily habits lead to a healthier life."',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFFCBD5E1),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Glowing 3D Heart Graphic with Pulse Line
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEC4899).withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.favorite_rounded, color: Color(0xFFEC4899), size: 38),
                  Icon(Icons.show_chart_rounded, color: Color(0xFF38BDF8), size: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 6. 4 HEALTH SUMMARY CARDS MATRIX (LARGE ICONS + ACTIONS)
  // ------------------------------------------------------------
  Widget _buildHealthSummaryCardsGrid(bool isDark, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 860 ? 4 : (constraints.maxWidth > 520 ? 2 : 1);
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.42,
          ),
          children: [
            // Card 1: Health Status
            _buildSummaryMetricCard(
              title: 'Health Status',
              metric: 'Good',
              metricColor: const Color(0xFF10B981),
              badgeText: '95%',
              badgeColor: const Color(0xFF10B981),
              subtitle: 'Your health score is excellent',
              icon: Icons.favorite_rounded,
              iconBg: const Color(0xFF064E3B),
              iconColor: const Color(0xFF34D399),
              accentColor: const Color(0xFF10B981),
              onTap: () => context.go(RouteNames.healthPassport),
            ),
            // Card 2: Upcoming Appointment
            _buildSummaryMetricCard(
              title: 'Upcoming Appointment',
              metric: 'Dr. Sarah Johnson',
              subtitle: 'Cardiologist\n24 May 2025 • 10:30 AM',
              actionButtonText: 'View Details',
              icon: Icons.calendar_month_rounded,
              iconBg: const Color(0xFF1E1B4B),
              iconColor: const Color(0xFF818CF8),
              accentColor: const Color(0xFF818CF8),
              onTap: () => context.push(RouteNames.triageAssess),
            ),
            // Card 3: Medications
            _buildSummaryMetricCard(
              title: 'Medications',
              metric: '2 Reminders',
              subtitle: 'Next: Vitamin D\nToday, 08:00 PM',
              actionButtonText: 'View All',
              icon: Icons.medication_rounded,
              iconBg: const Color(0xFF451A03),
              iconColor: const Color(0xFFFBBF24),
              accentColor: const Color(0xFFFBBF24),
              onTap: () => context.go(RouteNames.healthPassport),
            ),
            // Card 4: Activity
            _buildSummaryMetricCard(
              title: 'Activity',
              metric: '6,523 Steps',
              subtitle: 'Goal: 8,000 steps',
              icon: Icons.directions_run_rounded,
              iconBg: const Color(0xFF431407),
              iconColor: const Color(0xFFFB923C),
              accentColor: const Color(0xFFFB923C),
              showProgressBar: true,
              progressValue: 0.81,
              progressPercentText: '81%',
              onTap: () => context.go(RouteNames.healthPassport),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryMetricCard({
    required String title,
    required String metric,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color accentColor,
    required VoidCallback onTap,
    String? actionButtonText,
    Color? metricColor,
    String? badgeText,
    Color? badgeColor,
    bool showProgressBar = false,
    double progressValue = 0.0,
    String? progressPercentText,
  }) {
    return _InteractiveHoverCard(
      accentColor: accentColor,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 18),
              ],
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    metric,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: metricColor ?? Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badgeText != null)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: badgeColor ?? const Color(0xFF10B981), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        badgeText,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor ?? const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (showProgressBar) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 5,
                        backgroundColor: const Color(0xFF1E293B),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                      ),
                    ),
                  ),
                  if (progressPercentText != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      progressPercentText,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (actionButtonText != null)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161E36),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Text(
                        actionButtonText,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 7. BOTTOM MIRA ASSISTANT INTERACTION PANEL
  // ------------------------------------------------------------
  Widget _buildBottomMiraAssistantPanel(bool isDark) {
    final chips = [
      'Why do I have a headache?',
      'Is fever a sign of infection?',
      'What should I eat today?',
      'Book appointment with a cardiologist',
    ];

    final quickTools = [
      {'icon': Icons.mic_rounded, 'title': 'Voice Chat', 'desc': 'Talk to MIRA', 'onTap': () => context.push(RouteNames.triageAssess)},
      {'icon': Icons.insights_rounded, 'title': 'Health Analysis', 'desc': 'AI Insights', 'onTap': () => context.go(RouteNames.healthPassport)},
      {'icon': Icons.medication_rounded, 'title': 'Medication Check', 'desc': 'Reminders', 'onTap': () => context.go(RouteNames.healthPassport)},
      {'icon': Icons.description_rounded, 'title': 'Report Summary', 'desc': 'Health Overview', 'onTap': () => context.go(RouteNames.healthPassport)},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E152E), Color(0xFF131B3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6D28D9).withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isStacked = constraints.maxWidth < 780;

          if (isStacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFC084FC), width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset('assets/images/MIRA.png', fit: BoxFit.cover, alignment: Alignment.topCenter),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MIRA is here for you!',
                          style: GoogleFonts.poppins(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Ask me anything about your health, symptoms, medications or appointments.',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'You can ask me:',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: chips.map((c) {
                    return ActionChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            c,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: const Color(0xFFCBD5E1),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded, size: 15, color: Color(0xFF64748B)),
                        ],
                      ),
                      backgroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFF1E293B)),
                      onPressed: () => _handleMiraQuickIntent(c),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 30),
                          onPressed: () => context.push(RouteNames.triageAssess),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to speak with MIRA',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Title & Avatar Block
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFC084FC), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFA855F7).withValues(alpha: 0.5),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset('assets/images/MIRA.png', fit: BoxFit.cover, alignment: Alignment.topCenter),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MIRA is here for you!',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Ask me anything about your health, symptoms, medications or appointments.',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Interactive voice status pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.graphic_eq_rounded, color: Color(0xFFC084FC), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Listening... ||||||||',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFC084FC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Center Chips & Quick Tools Block
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You can ask me:',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chips.map((c) {
                        return InkWell(
                          onTap: () => _handleMiraQuickIntent(c),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  c,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF64748B)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    // Quick MIRA Tools row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: quickTools.map((tool) {
                        return InkWell(
                          onTap: tool['onTap'] as VoidCallback,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(tool['icon'] as IconData, size: 16, color: const Color(0xFF38BDF8)),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tool['title'] as String,
                                      style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    Text(
                                      tool['desc'] as String,
                                      style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Right Mic Button Block
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.65),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 30),
                      onPressed: () => context.push(RouteNames.triageAssess),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to speak\nwith MIRA',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Reusable Interactive Hover Card Component
class _InteractiveHoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color accentColor;
  final bool isEmergency;

  const _InteractiveHoverCard({
    required this.child,
    required this.onTap,
    this.accentColor = const Color(0xFF8B5CF6),
    this.isEmergency = false,
  });

  @override
  State<_InteractiveHoverCard> createState() => _InteractiveHoverCardState();
}

class _InteractiveHoverCardState extends State<_InteractiveHoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isEmergency
        ? const Color(0xFFF43F5E)
        : (_isHovered ? widget.accentColor.withValues(alpha: 0.8) : const Color(0xFF1E293B));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: _isHovered ? Matrix4.translationValues(0.0, -3.0, 0.0) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF131B34) : const Color(0xFF0E1428),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: widget.isEmergency || _isHovered ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                color: (widget.isEmergency ? const Color(0xFFF43F5E) : widget.accentColor)
                    .withValues(alpha: _isHovered ? 0.35 : 0.08),
                blurRadius: _isHovered ? 16 : 8,
                offset: _isHovered ? const Offset(0, 4) : const Offset(0, 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
