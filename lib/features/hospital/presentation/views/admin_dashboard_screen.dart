import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';

/// Hospital Admin & System Command Console
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _icuAvailable = 4;
  final int _ventilatorsAvailable = 2;
  bool _emergencyLockdown = false;

  Future<void> _showSignOutDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of the Hospital Admin Console?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Sign Out',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔒 Hospital Admin session ended. Signed out.', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(RouteNames.login);
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF7C3AED), size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hospital Admin Console',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'PSG Hospitals Operations • System Control',
                  style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.neutral400 : AppColors.neutral600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Sign Out Admin',
            onPressed: _showSignOutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin KPI Cards Grid
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _KpiCard(
                  title: 'ICU Beds Avail.',
                  value: '$_icuAvailable / 24',
                  icon: Icons.bed_rounded,
                  color: const Color(0xFF7C3AED),
                ),
                _KpiCard(
                  title: 'Active Ambulances',
                  value: '4 Units En-route',
                  icon: Icons.local_shipping_rounded,
                  color: Colors.orange,
                ),
                _KpiCard(
                  title: 'Ventilators Free',
                  value: '$_ventilatorsAvailable Free',
                  icon: Icons.air_rounded,
                  color: const Color(0xFF10B981),
                ),
                _KpiCard(
                  title: 'ER Wait Time',
                  value: '6 mins avg',
                  icon: Icons.timer_rounded,
                  color: const Color(0xFF3B82F6),
                ),
              ],
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Emergency Action Controls
            Text(
              'Hospital Capacity Management',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.neutral200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available ICU Beds', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Adjust real-time capacity visible to Emergency Dispatch', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.neutral400)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _icuAvailable > 0 ? () => setState(() => _icuAvailable--) : null,
                          ),
                          Text('$_icuAvailable', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setState(() => _icuAvailable++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Emergency Diversion Status', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Reroute non-critical ambulances to nearest regional trauma hubs', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.neutral400)),
                        ],
                      ),
                      Switch(
                        value: _emergencyLockdown,
                        activeThumbColor: Colors.red,
                        onChanged: (val) {
                          setState(() => _emergencyLockdown = val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? '⚠️ Emergency Diversion ACTIVATED' : '✅ Emergency Diversion CLEARED'),
                              backgroundColor: val ? Colors.red : Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Navigation buttons to related admin views
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(RouteNames.hospitalSearch),
                    icon: const Icon(Icons.map_rounded),
                    label: const Text('Live Emergency Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go(RouteNames.ambulanceDashboard),
                    icon: const Icon(Icons.local_shipping_rounded),
                    label: const Text('Ambulance Dispatch'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.neutral400)),
          Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
