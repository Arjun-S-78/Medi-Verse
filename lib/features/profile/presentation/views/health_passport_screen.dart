import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';

/// Enterprise MediVerse Health Passport, Digital Prescriptions & AI Health Insights View
class HealthPassportScreen extends StatefulWidget {
  final int initialTabIndex;

  const HealthPassportScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<HealthPassportScreen> createState() => _HealthPassportScreenState();
}

class _HealthPassportScreenState extends State<HealthPassportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _prescriptions = [
    {
      'id': 'RX-8092',
      'medication': 'Amoxicillin 500mg',
      'doctor': 'Dr. Sarah Johnson',
      'specialty': 'Cardiologist',
      'frequency': '1 Capsule twice daily (After meals)',
      'duration': '5 Days remaining',
      'pillsLeft': 10,
      'status': 'Active',
      'time': '08:00 AM & 08:00 PM',
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'RX-7120',
      'medication': 'Atorvastatin 10mg',
      'doctor': 'Dr. Nalla G. Palaniswami',
      'specialty': 'General Physician',
      'frequency': '1 Tablet at bedtime',
      'duration': '28 Days remaining',
      'pillsLeft': 28,
      'status': 'Active',
      'time': '09:30 PM',
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': 'RX-6401',
      'medication': 'Paracetamol 650mg',
      'doctor': 'Dr. R. Revathi',
      'specialty': 'Pediatrician',
      'frequency': 'As needed for fever/pain',
      'duration': 'As needed',
      'pillsLeft': 6,
      'status': 'As Needed',
      'color': const Color(0xFFF59E0B),
    },
  ];

  final List<Map<String, dynamic>> _records = [
    {'title': 'Annual Cardiac ECG Assessment', 'date': '12 Aug 2026', 'doctor': 'Dr. Sarah Johnson', 'hospital': 'PSG Hospitals', 'type': 'Diagnostic Report', 'status': 'Verified'},
    {'title': 'Comprehensive Blood Panel & Lipid Profile', 'date': '24 Jul 2026', 'doctor': 'Dr. Nalla G. Palaniswami', 'hospital': 'KMCH Coimbatore', 'type': 'Lab Result', 'status': 'Normal'},
    {'title': 'COVID-19 Booster Vaccination Certificate', 'date': '15 Jan 2026', 'doctor': 'City General Clinic', 'hospital': 'City Health Dept', 'type': 'Immunization', 'status': 'Completed'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showSignOutDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
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
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of MediVerse?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white54,
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
          content: Text('🔒 Patient session ended. Signed out.', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.home);
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_rounded, color: Color(0xFFC084FC), size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MediVerse Health Passport',
                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Encrypted Health Records, Prescriptions & Health Insights',
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Sign Out',
            onPressed: _showSignOutDialog,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF7C3AED),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.assignment_outlined, size: 20), text: 'Health Records'),
            Tab(icon: Icon(Icons.receipt_long_outlined, size: 20), text: 'Prescriptions'),
            Tab(icon: Icon(Icons.insights_rounded, size: 20), text: 'Health Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHealthRecordsTab(),
          _buildPrescriptionsTab(),
          _buildHealthInsightsTab(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TAB 1: HEALTH RECORDS & VITAL SIGNS
  // ------------------------------------------------------------
  Widget _buildHealthRecordsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Emergency Medical Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF10B981), width: 2),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('John Doe', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                            child: Text('Blood Group: O+', style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF34D399))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Age: 29 • Male • ID: #MV-90823', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8))),
                      Text('Allergies: Penicillin, Dust Mites', style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFFF87171), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Vitals Grid
          Text('Live Vital Indicators', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _vitalCard('Blood Pressure', '120/80', 'mmHg', Icons.favorite_rounded, const Color(0xFFEF4444), 'Optimal'),
              _vitalCard('Heart Rate', '72', 'bpm', Icons.monitor_heart_rounded, const Color(0xFF10B981), 'Normal'),
              _vitalCard('Blood Sugar', '95', 'mg/dL', Icons.water_drop_rounded, const Color(0xFF3B82F6), 'Fasting'),
              _vitalCard('SpO2 Oxygen', '98', '%', Icons.air_rounded, const Color(0xFF8B5CF6), 'Healthy'),
            ],
          ),

          const SizedBox(height: 24),

          // Medical Documents & Reports List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Medical History & Lab Reports', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Document upload scanner initialized.', style: GoogleFonts.poppins()),
                      backgroundColor: const Color(0xFF7C3AED),
                    ),
                  );
                },
                icon: const Icon(Icons.upload_file_rounded, color: Color(0xFF38BDF8), size: 18),
                label: Text('Upload Report', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF38BDF8))),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _records.length,
            itemBuilder: (context, index) {
              final rec = _records[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1528),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.description_rounded, color: Color(0xFFC084FC), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rec['title']!, style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('${rec['type']} • ${rec['hospital']} • ${rec['date']}', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(rec['status']!, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF34D399))),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _vitalCard(String title, String value, String unit, IconData icon, Color color, String badge) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1528),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 4),
                    Text(unit, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TAB 2: DIGITAL PRESCRIPTIONS
  // ------------------------------------------------------------
  Widget _buildPrescriptionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Prescriptions', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Prescription refill order placed with MediVerse Pharmacy.', style: GoogleFonts.poppins()),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
                icon: const Icon(Icons.local_pharmacy_rounded, size: 16, color: Colors.white),
                label: Text('Refill All RX', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _prescriptions.length,
            itemBuilder: (context, index) {
              final rx = _prescriptions[index];
              final Color accentColor = rx['color'] as Color;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1528),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.2),
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.medication_rounded, color: accentColor, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rx['medication'] as String, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text('Prescribed by ${rx['doctor']} (${rx['specialty']})', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                          child: Text(rx['status'] as String, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: accentColor)),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF1E293B), height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dosage Schedule', style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B))),
                            Text(rx['frequency'] as String, style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Duration / Remaining', style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B))),
                            Text(rx['duration'] as String, style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF34D399))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF334155)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Reminder set for ${rx['medication']}.', style: GoogleFonts.poppins()),
                                  backgroundColor: const Color(0xFF7C3AED),
                                ),
                              );
                            },
                            icon: const Icon(Icons.alarm_add_rounded, size: 16, color: Color(0xFFC084FC)),
                            label: Text('Set Reminder', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFC084FC))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Refill request sent for ${rx['medication']}.', style: GoogleFonts.poppins()),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.white),
                            label: Text('Order Refill', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TAB 3: CLINICAL HEALTH INSIGHTS & ANALYTICS
  // ------------------------------------------------------------
  Widget _buildHealthInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clinical Insights Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F1630), Color(0xFF1D1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                  ),
                  child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF10B981), size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Clinical Health Assessment', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        'Your vital trends & cardiovascular health metrics show an overall 92% optimal score this week.',
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFCBD5E1)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text('Personalized AI Health Metrics', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          _insightCard('Cardiovascular Risk Score', 'Low Risk (94/100)', 'ECG pattern and resting HR (72 bpm) are steady.', Icons.favorite_rounded, const Color(0xFF10B981)),
          _insightCard('Sleep Quality Index', '82% Optimal', 'Deep sleep average 7.2 hrs. Reminders set for 10:30 PM bedtime.', Icons.nightlight_round, const Color(0xFF8B5CF6)),
          _insightCard('Medication Adherence', '100% Tracked', 'All 3 active prescriptions taken on time over last 14 days.', Icons.check_circle_rounded, const Color(0xFF38BDF8)),
          _insightCard('Metabolic Health Trend', 'Fasting Sugar 95 mg/dL', 'Dietary glucose levels remain within target clinical range.', Icons.trending_up_rounded, const Color(0xFFF59E0B)),

          const SizedBox(height: 20),

          // Detailed Medical Report Analysis Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => context.push(RouteNames.triageAssess),
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
              label: Text('Get Detailed Medical Report Analysis', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightCard(String title, String status, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1528),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(status, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
