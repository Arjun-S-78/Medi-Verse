import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';

/// Enterprise Book Doctors & Tele-Consultation Screen
class DoctorBookingScreen extends StatefulWidget {
  const DoctorBookingScreen({super.key});

  @override
  State<DoctorBookingScreen> createState() => _DoctorBookingScreenState();
}

class _DoctorBookingScreenState extends State<DoctorBookingScreen> {
  String _selectedSpecialty = 'All';
  String _selectedCity = 'Coimbatore';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _specialties = [
    'All',
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Dermatology',
    'General Medicine',
    'Emergency Trauma',
    'Oncology',
  ];

  final List<Map<String, dynamic>> _doctors = [
    {
      'id': 'DOC-101',
      'name': 'Dr. Sarah Johnson',
      'specialty': 'Cardiology',
      'hospital': 'PSG Hospitals',
      'city': 'Coimbatore',
      'rating': 4.9,
      'reviews': 248,
      'experience': '14 Years Exp.',
      'fee': '₹800',
      'nextSlot': 'Today, 04:30 PM',
      'image': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300&auto=format&fit=crop&q=80',
      'isAvailable': true,
      'languages': 'English, Tamil',
    },
    {
      'id': 'DOC-102',
      'name': 'Dr. S. Raja Sabapathy',
      'specialty': 'Orthopedics',
      'hospital': 'Ganga Hospital',
      'city': 'Coimbatore',
      'rating': 4.95,
      'reviews': 412,
      'experience': '22 Years Exp.',
      'fee': '₹1,000',
      'nextSlot': 'Tomorrow, 10:00 AM',
      'image': 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=300&auto=format&fit=crop&q=80',
      'isAvailable': true,
      'languages': 'English, Tamil, Hindi',
    },
    {
      'id': 'DOC-103',
      'name': 'Dr. Nalla G. Palaniswami',
      'specialty': 'General Medicine',
      'hospital': 'KMCH (Kovai Medical Center)',
      'city': 'Coimbatore',
      'rating': 4.88,
      'reviews': 189,
      'experience': '18 Years Exp.',
      'fee': '₹750',
      'nextSlot': 'Today, 06:00 PM',
      'image': 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=300&auto=format&fit=crop&q=80',
      'isAvailable': true,
      'languages': 'English, Tamil',
    },
    {
      'id': 'DOC-104',
      'name': 'Dr. R. Revathi',
      'specialty': 'Pediatrics',
      'hospital': 'Revathi Medical Center',
      'city': 'Tirupur',
      'rating': 4.92,
      'reviews': 310,
      'experience': '16 Years Exp.',
      'fee': '₹600',
      'nextSlot': 'Today, 05:00 PM',
      'image': 'https://images.unsplash.com/photo-1594824813571-24a69c100417?w=300&auto=format&fit=crop&q=80',
      'isAvailable': true,
      'languages': 'English, Tamil',
    },
    {
      'id': 'DOC-105',
      'name': 'Dr. Prathap C. Reddy',
      'specialty': 'Cardiology',
      'hospital': 'Apollo Hospitals (Greams Rd)',
      'city': 'Chennai',
      'rating': 4.98,
      'reviews': 540,
      'experience': '25 Years Exp.',
      'fee': '₹1,500',
      'nextSlot': 'Tomorrow, 11:30 AM',
      'image': 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=300&auto=format&fit=crop&q=80',
      'isAvailable': true,
      'languages': 'English, Tamil, Telugu',
    },
    {
      'id': 'DOC-106',
      'name': 'Dr. K. R. Balakrishnan',
      'specialty': 'Cardiology',
      'hospital': 'Fortis Malar Hospital',
      'city': 'Chennai',
      'rating': 4.96,
      'reviews': 380,
      'experience': '20 Years Exp.',
      'fee': '₹1,200',
      'nextSlot': 'Today, 03:00 PM',
      'image': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=300&auto=format&fit=crop&q=80',
      'isAvailable': true,
      'languages': 'English, Tamil',
    },
    {
      'id': 'DOC-107',
      'name': 'Dr. Ananya V. Sharma',
      'specialty': 'Dermatology',
      'hospital': 'Sri Ramakrishna Hospital',
      'city': 'Coimbatore',
      'rating': 4.85,
      'reviews': 142,
      'experience': '10 Years Exp.',
      'fee': '₹700',
      'nextSlot': 'Tomorrow, 02:00 PM',
      'image': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300&auto=format&fit=crop&q=80',
      'isAvailable': true,
      'languages': 'English, Tamil, Hindi',
    },
    {
      'id': 'DOC-108',
      'name': 'Dr. P. Guhan',
      'specialty': 'Oncology',
      'hospital': 'Sri Ramakrishna Hospital',
      'city': 'Coimbatore',
      'rating': 4.94,
      'reviews': 295,
      'experience': '19 Years Exp.',
      'fee': '₹1,100',
      'nextSlot': 'Tomorrow, 09:30 AM',
      'image': 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=300&auto=format&fit=crop&q=80',
      'isAvailable': true,
      'languages': 'English, Tamil',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredDoctors {
    final query = _searchController.text.toLowerCase().trim();
    return _doctors.where((doc) {
      final matchesSpecialty = _selectedSpecialty == 'All' || doc['specialty'] == _selectedSpecialty;
      final matchesCity = doc['city'] == _selectedCity;
      final matchesQuery = query.isEmpty ||
          doc['name'].toString().toLowerCase().contains(query) ||
          doc['specialty'].toString().toLowerCase().contains(query) ||
          doc['hospital'].toString().toLowerCase().contains(query);
      return matchesSpecialty && matchesCity && matchesQuery;
    }).toList();
  }

  void _openBookingModal(BuildContext context, Map<String, dynamic> doctor, {bool isVideoConsult = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentBookingModal(
        doctor: doctor,
        initialIsVideo: isVideoConsult,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

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
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_search_rounded, color: Color(0xFFC084FC), size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book Specialist Doctors',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Top Rated Physicians & Tele-Consultants',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // City Selector Dropdown Pill
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1528),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Color(0xFFEC4899), size: 16),
                const SizedBox(width: 6),
                DropdownButton<String>(
                  value: _selectedCity,
                  dropdownColor: const Color(0xFF0E1528),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCity = val);
                  },
                  items: ['Coimbatore', 'Tirupur', 'Chennai'].map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            color: const Color(0xFF090D1E),
            child: Column(
              children: [
                // Search Input Field
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E1528),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {}),
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search doctor by name, specialty or hospital...',
                      hintStyle: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: Colors.white70, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(top: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Specialty Category Filter Pills
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _specialties.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final spec = _specialties[index];
                      final isSelected = spec == _selectedSpecialty;
                      return ChoiceChip(
                        label: Text(spec),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedSpecialty = spec);
                        },
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                        ),
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: const Color(0xFF0E1528),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFFA78BFA) : const Color(0xFF1E293B),
                          ),
                        ),
                        showCheckmark: false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Doctor Grid / List
          Expanded(
            child: _filteredDoctors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search_rounded, size: 64, color: Color(0xFF475569)),
                        const SizedBox(height: 16),
                        Text(
                          'No doctors found for "$_selectedSpecialty" in $_selectedCity',
                          style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedSpecialty = 'All';
                              _searchController.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Reset Filters', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 2 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 220,
                    ),
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doc = _filteredDoctors[index];
                      return _DoctorCard(
                        doctor: doc,
                        onBookPressed: () => _openBookingModal(context, doc, isVideoConsult: false),
                        onVideoPressed: () => _openBookingModal(context, doc, isVideoConsult: true),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Neatly Aligned Doctor Card
class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onBookPressed;
  final VoidCallback onVideoPressed;

  const _DoctorCard({
    required this.doctor,
    required this.onBookPressed,
    required this.onVideoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1427),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Image
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
                  image: DecorationImage(
                    image: NetworkImage(doctor['image'] as String),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            doctor['name'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${doctor['rating']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${doctor['specialty']} • ${doctor['experience']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor['hospital'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: const Color(0xFF94A3B8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Fee & Next Slot Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF070B18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Color(0xFF10B981), size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'Slot: ${doctor['nextSlot']}',
                      style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFFCBD5E1)),
                    ),
                  ],
                ),
                Text(
                  'Fee: ${doctor['fee']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF34D399),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.videocam_rounded, size: 16, color: Color(0xFF38BDF8)),
                  label: Text('Video Consult', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF38BDF8))),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Color(0xFF38BDF8)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: onVideoPressed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.white),
                  label: Text('Book Slot', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: onBookPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Interactive Appointment Booking Bottom Sheet Modal
class _AppointmentBookingModal extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final bool initialIsVideo;

  const _AppointmentBookingModal({
    required this.doctor,
    this.initialIsVideo = false,
  });

  @override
  State<_AppointmentBookingModal> createState() => _AppointmentBookingModalState();
}

class _AppointmentBookingModalState extends State<_AppointmentBookingModal> {
  late bool _isVideoConsult;
  int _selectedDateIndex = 0;
  String _selectedTimeSlot = '10:30 AM';
  final TextEditingController _symptomsController = TextEditingController();

  final List<Map<String, String>> _dates = [
    {'day': 'Today', 'date': '31 Aug'},
    {'day': 'Tue', 'date': '01 Sep'},
    {'day': 'Wed', 'date': '02 Sep'},
    {'day': 'Thu', 'date': '03 Sep'},
    {'day': 'Fri', 'date': '04 Sep'},
  ];

  final List<String> _morningSlots = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:15 AM'];
  final List<String> _afternoonSlots = ['02:00 PM', '02:45 PM', '03:30 PM', '04:15 PM'];
  final List<String> _eveningSlots = ['05:30 PM', '06:15 PM', '07:00 PM', '07:45 PM'];

  @override
  void initState() {
    super.initState();
    _isVideoConsult = widget.initialIsVideo;
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  void _confirmAppointment(BuildContext context) {
    Navigator.pop(context); // Close sheet

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFF059669),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 18),
              Text(
                'Appointment Confirmed! 🎉',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your appointment has been successfully scheduled with ${widget.doctor['name']}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 20),

              // Booking Pass Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF070B18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  children: [
                    _passRow('Doctor', widget.doctor['name'] as String),
                    const Divider(color: Color(0xFF1E293B)),
                    _passRow('Type', _isVideoConsult ? 'HD Video Consultation' : 'In-Person Hospital Visit'),
                    const Divider(color: Color(0xFF1E293B)),
                    _passRow('Hospital', widget.doctor['hospital'] as String),
                    const Divider(color: Color(0xFF1E293B)),
                    _passRow('Date & Time', '${_dates[_selectedDateIndex]['day']}, ${_dates[_selectedDateIndex]['date']} • $_selectedTimeSlot'),
                    const Divider(color: Color(0xFF1E293B)),
                    _passRow('Booking ID', 'MV-APT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}', isHighlight: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF475569)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close', style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.go(RouteNames.home);
                      },
                      child: Text('Go to Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                color: isHighlight ? const Color(0xFF34D399) : Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Handle Bar
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Doctor Summary Card
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.doctor['image'] as String,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book Consultation',
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF38BDF8), fontWeight: FontWeight.w600),
                      ),
                      Text(
                        widget.doctor['name'] as String,
                        style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '${widget.doctor['specialty']} • ${widget.doctor['hospital']}',
                        style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Mode Selector Toggle (In-Person vs Video)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF070B18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isVideoConsult = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isVideoConsult ? const Color(0xFF7C3AED) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business_rounded, color: !_isVideoConsult ? Colors.white : const Color(0xFF94A3B8), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'In-Person Visit',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: !_isVideoConsult ? Colors.white : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isVideoConsult = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isVideoConsult ? const Color(0xFF0284C7) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam_rounded, color: _isVideoConsult ? Colors.white : const Color(0xFF94A3B8), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'HD Video Call',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isVideoConsult ? Colors.white : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Date Picker Section
            Text(
              'Select Date',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _dates.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = _dates[index];
                  final isSelected = index == _selectedDateIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDateIndex = index),
                    child: Container(
                      width: 72,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFF070B18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? const Color(0xFFA78BFA) : const Color(0xFF1E293B)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['day']!,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: isSelected ? Colors.white70 : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['date']!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Time Slots Section
            Text(
              'Select Time Slot',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildSlotCategory('Morning', _morningSlots),
            const SizedBox(height: 10),
            _buildSlotCategory('Afternoon', _afternoonSlots),
            const SizedBox(height: 10),
            _buildSlotCategory('Evening', _eveningSlots),

            const SizedBox(height: 20),

            // Reason / Notes
            Text(
              'Reason for Visit / Symptoms (Optional)',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFCBD5E1)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF070B18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: TextField(
                controller: _symptomsController,
                maxLines: 2,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Mild chest tightness, routine follow-up, routine checkup...',
                  hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => _confirmAppointment(context),
                child: Text(
                  'Confirm Booking (${widget.doctor['fee']})',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotCategory(String title, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final isSelected = slot == _selectedTimeSlot;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeSlot = slot),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : const Color(0xFF070B18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? const Color(0xFF34D399) : const Color(0xFF1E293B)),
                ),
                child: Text(
                  slot,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            );
          },).toList(),
        ),
      ],
    );
  }
}
