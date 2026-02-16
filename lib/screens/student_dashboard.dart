import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _complaints = [];
  int _activeCount = 0;
  int _resolvedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final profile = await _authService.getCurrentUserProfile();
    final complaints = await _dbService.getUserComplaints();
    final active = await _dbService.getActiveComplaintCount();
    final resolved = await _dbService.getResolvedComplaintCount();

    if (mounted) {
      setState(() {
        _userProfile = profile;
        _complaints = complaints;
        _activeCount = active;
        _resolvedCount = resolved;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: _userProfile?['avatar_url'] != null
                              ? NetworkImage(_userProfile!['avatar_url'])
                              : null,
                          backgroundColor: Colors.blue[100],
                          child: _userProfile?['avatar_url'] == null
                              ? Text(
                                  (_userProfile?['full_name'] ?? 'U')[0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      color: Color(0xFF2D31FA),
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _userProfile?['full_name'] ?? 'Student',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(LucideIcons.bell,
                                size: 20, color: Color(0xFF2C3E50)),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: LucideIcons.calendarClock, // Icon for Active
                            label: 'Active',
                            value: _activeCount.toString().padLeft(2, '0'),
                            color: const Color(0xFF2D31FA),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            icon: LucideIcons.checkCircle, // Icon for Resolved
                            label: 'Resolved',
                            value: _resolvedCount.toString().padLeft(2, '0'),
                            color: const Color(0xFF00C853),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Recent Complaints Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Complaints',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View all',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D31FA),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Complaints List
                    if (_complaints.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No complaints found',
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._complaints.take(4).map((complaint) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildComplaintCardFromData(complaint),
                        );
                      }),

                    const SizedBox(height: 16), // Extra spacing

                    // Urgent Help Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2D31FA), Color(0xFF5D5FEF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D31FA).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Need urgent help?',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Contact the warden directly for emergency maintenance requests after 10 PM.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF2D31FA),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                  child: Text(
                                    'Call Warden',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 48,
                            width: 48,
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80), // Space for Bottom Nav
                  ],
                ),
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
            label: 'Complaints', // Changed from clipboard
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.messageSquare),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2D31FA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCardFromData(Map<String, dynamic> data) {
    IconData icon;
    Color color;
    Color iconColor;
    Color statusColor;
    Color statusTextColor;
    String category = data['category'] ?? 'General';
    String status = data['status'] ?? 'PENDING';

    // Status Styling
    if (status == 'RESOLVED') {
      statusColor = const Color(0xFFE8F5E9);
      statusTextColor = const Color(0xFF388E3C);
    } else if (status == 'IN PROGRESS') {
      statusColor = const Color(0xFFE3F2FD);
      statusTextColor = const Color(0xFF1976D2);
    } else {
      statusColor = const Color(0xFFFFF3E0);
      statusTextColor = const Color(0xFFF57C00);
    }

    // Category Styling
    if (category == 'Plumbing') {
      icon = LucideIcons.droplets;
      color = const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFD32F2F);
    } else if (category == 'Electrical') {
      icon = LucideIcons.lightbulb;
      color = const Color(0xFFF5F5F5);
      iconColor = const Color(0xFF616161);
    } else if (category == 'Network') {
      icon = LucideIcons.wifi;
      color = const Color(0xFFE3F2FD);
      iconColor = const Color(0xFF1976D2);
    } else if (category == 'Carpentry') {
      icon = LucideIcons.bed;
      color = const Color(0xFFF3E5F5);
      iconColor = const Color(0xFF7B1FA2);
    } else {
      icon = LucideIcons.fileText;
      color = const Color(0xFFE0F7FA);
      iconColor = const Color(0xFF006064);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? 'No Title',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Submitted ${data['created_at'] != null ? data['created_at'].toString().substring(0, 10) : ''} • $category',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
