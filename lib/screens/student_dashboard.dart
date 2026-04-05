import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'student_complaints.dart';
import 'file_new_complaint.dart';
import 'student_home.dart';
import 'student_profile.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  // Set default index to 0 (Home)
  int _selectedIndex = 0;
  final GlobalKey<StudentHomeState> _studentHomeKey = GlobalKey<StudentHomeState>();
  final GlobalKey<StudentComplaintsScreenState> _studentComplaintsKey =
      GlobalKey<StudentComplaintsScreenState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      StudentHome(key: _studentHomeKey),
      StudentComplaintsScreen(key: _studentComplaintsKey),
      const StudentProfile(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFEBEBFF),
        selectedItemColor: const Color(0xFF2D31FA),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.fileText),
            label: 'Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: (_selectedIndex == 0 || _selectedIndex == 1)
          ? FloatingActionButton(
              onPressed: () async {
                final complaintCreated = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => const FileNewComplaintScreen(),
                  ),
                );

                if (complaintCreated == true) {
                  await _studentHomeKey.currentState?.refresh();
                  await _studentComplaintsKey.currentState?.refresh();
                }
              },
              backgroundColor: const Color(0xFF2D31FA),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
