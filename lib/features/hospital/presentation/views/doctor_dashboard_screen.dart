import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';

/// Doctor Clinical & Emergency Triage Portal
class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All Emergency Patients', 'ESI-1 Critical', 'ESI-2 Urgent', 'Tele-Consults'];

  final List<Map<String, dynamic>> _patients = [
    {
      'id': 'PT-9041',
      'name': 'Rajesh Kumar',
      'age': 48,
      'gender': 'Male',
      'esiLevel': 1,
      'esiName': 'ESI-1 Resuscitation',
      'symptoms': 'Acute Chest Pain, Diaphoresis, ST Elevation',
      'vitals': {'bp': '155/98', 'hr': 118, 'spo2': '92%', 'temp': '98.6°F'},
      'eta': '3 mins (En-route Ambulance #102)',
      'status': 'CRITICAL',
    },
    {
      'id': 'PT-9042',
      'name': 'Priya Sharma',
      'age': 32,
      'gender': 'Female',
      'esiLevel': 2,
      'esiName': 'ESI-2 Emergent',
      'symptoms': 'Severe Asthma Attack, Respiratory Distress',
      'vitals': {'bp': '128/82', 'hr': 102, 'spo2': '94%', 'temp': '99.1°F'},
      'eta': 'Arrived at ER Room 3',
      'status': 'IN_ER',
    },
    {
      'id': 'PT-9043',
      'name': 'Ananth Raman',
      'age': 61,
      'gender': 'Male',
      'esiLevel': 3,
      'esiName': 'ESI-3 Urgent',
      'symptoms': 'Right Lower Quadrant Abdominal Pain',
      'vitals': {'bp': '134/86', 'hr': 88, 'spo2': '98%', 'temp': '100.4°F'},
      'eta': 'Waiting Bay B',
      'status': 'WAITING',
    },
  ];

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
          'Are you sure you want to sign out of the Doctor Clinical Portal?',
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
          content: Text('🔒 Doctor session ended. Signed out.', style: GoogleFonts.poppins(fontSize: 13)),
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
                color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medical_services_rounded, color: Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doctor Clinical Portal',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Dr. Sarah Johnson • ER Chief Specialist',
                  style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.neutral400 : AppColors.neutral600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Sign Out Doctor',
            onPressed: _showSignOutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Department Queue (PSG Hospital)',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '3 Patients en-route or in triage • 1 Critical (ESI-1)',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.go(RouteNames.triageAssess),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E40AF),
                    ),
                    child: const Text('Start Clinical Triage'),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),

            const SizedBox(height: 20),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final selected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filters[index]),
                      selected: selected,
                      selectedColor: const Color(0xFF2563EB),
                      labelStyle: GoogleFonts.poppins(
                        color: selected ? Colors.white : (isDark ? AppColors.neutral300 : AppColors.neutral800),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        setState(() => _selectedFilterIndex = index);
                      },
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // Patient List Cards
            ..._patients.map((pt) {
              final isEsi1 = pt['esiLevel'] == 1;
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isEsi1 ? AppColors.esi1Critical : (isDark ? AppColors.darkBorder : AppColors.neutral200),
                    width: isEsi1 ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isEsi1 ? AppColors.esi1Critical : AppColors.esi2Emergent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pt['esiName'],
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${pt['name']} (${pt['age']}y/${pt['gender']})',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        Text(
                          pt['id'],
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.neutral400, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chief Complaint: ${pt['symptoms']}',
                      style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.neutral300 : AppColors.neutral700),
                    ),
                    const SizedBox(height: 12),

                    // Vitals Bar
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : AppColors.neutral100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _VitalChip(label: 'BP', value: pt['vitals']['bp']),
                          _VitalChip(label: 'HR', value: '${pt['vitals']['hr']} bpm'),
                          _VitalChip(label: 'SpO2', value: pt['vitals']['spo2']),
                          _VitalChip(label: 'Temp', value: pt['vitals']['temp']),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(
                              pt['eta'],
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Viewing EHR & Health Passport for ${pt['name']}')),
                            );
                            context.go(RouteNames.healthPassport);
                          },
                          icon: const Icon(Icons.folder_shared_rounded, size: 16),
                          label: const Text('Open Health Passport'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _VitalChip extends StatelessWidget {
  final String label;
  final String value;
  const _VitalChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.neutral400)),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
