import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/database_service.dart';

class WardenDashboard extends StatefulWidget {
  const WardenDashboard({super.key});

  @override
  State<WardenDashboard> createState() => _WardenDashboardState();
}

class _WardenDashboardState extends State<WardenDashboard> {
  static const Color _primary = Color(0xFF2D31FA);
  final DatabaseService _databaseService = DatabaseService();
  static const List<String> _statusOptions = [
    'PENDING',
    'IN PROGRESS',
    'RESOLVED',
  ];

  int _selectedTab = 0;
  int _selectedFilter = 0;

  final List<String> _filters = const [
    'All Issues',
    'Plumbing',
    'Electrical',
    'WiFi',
  ];

  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _students = [];
  Map<String, String> _submitterNames = {};
  bool _isLoading = true;
  bool _isStudentsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
    _loadStudents();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);

    final complaints = await _databaseService.getAllComplaints();
    final userIds = complaints
        .map((item) => item['user_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    final names = userIds.isEmpty
        ? <String, String>{}
        : await _databaseService.getProfileNamesByIds(userIds);

    if (!mounted) return;

    setState(() {
      _complaints = complaints;
      _submitterNames = names;
      _isLoading = false;
    });
  }

  Future<void> _loadStudents() async {
    setState(() => _isStudentsLoading = true);
    final students = await _databaseService.getAllStudents();
    if (!mounted) return;
    setState(() {
      _students = students;
      _isStudentsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleComplaints = _filteredComplaints();
    final pendingCount = _complaints.where((item) => _normalizeStatus(item['status']) == 'PENDING').length;
    final activeCount = _complaints.where((item) => _normalizeStatus(item['status']) == 'IN PROGRESS').length;
    final resolvedCount = _complaints.where((item) => _normalizeStatus(item['status']) == 'RESOLVED').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _selectedTab == 0 ? _buildCenterAction() : null,
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        child: _selectedTab == 2
            ? _buildStudentsTab()
            : (_selectedTab == 0
                ? (_isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                onRefresh: _loadComplaints,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildStatsRow(
                      newCount: pendingCount,
                      activeCount: activeCount,
                      resolvedCount: resolvedCount,
                    ),
                    const SizedBox(height: 28),
                    _buildSectionHeader(),
                    const SizedBox(height: 14),
                    _buildFilterChips(),
                    const SizedBox(height: 18),
                    if (visibleComplaints.isEmpty)
                      _buildEmptyState()
                    else
                      for (final complaint in visibleComplaints) ...[
                        _ComplaintCard(
                          complaint: complaint,
                          submitterName: _submitterNames[complaint['user_id']?.toString() ?? ''] ?? 'Student',
                          onUpdateStatus: () => _openStatusDialog(complaint),
                        ),
                        const SizedBox(height: 16),
                      ],
                    const SizedBox(height: 12),
                  ],
                ),
              ))
                : _buildComingSoonTab()),
      ),
    );
  }

  Widget _buildStudentsTab() {
    if (_isStudentsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadStudents,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Text(
            'Students',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF11131E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total students: ${_students.length}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF5B6080),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (_students.isEmpty)
            _buildStudentsEmptyState()
          else
            ..._students.map((student) {
              final fullName = (student['full_name']?.toString().trim().isNotEmpty == true)
                  ? student['full_name'].toString()
                  : 'Student';
              final username = student['username']?.toString() ?? '—';
              final phone = student['phone_number']?.toString() ?? '—';
              final email = student['email']?.toString() ?? '—';
              final room = student['room_number']?.toString() ?? '—';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StudentCard(
                  fullName: fullName,
                  initials: _initialsFromName(fullName),
                  username: username,
                  phone: phone,
                  email: email,
                  room: room,
                ),
              );
            }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildStudentsEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3D6E4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.groups_outlined, color: Color(0xFF9CA3AF), size: 26),
          const SizedBox(height: 10),
          Text(
            'No students found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonTab() {
    return Center(
      child: Text(
        'Coming soon',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          color: const Color(0xFF5B6080),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E7FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.shield_rounded, color: _primary, size: 32),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Warden Dashboard',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10131F),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Boys Hostel • Block A',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: const Color(0xFF565A7A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _circleAction(Icons.search_rounded),
        const SizedBox(width: 8),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _circleAction(Icons.notifications_rounded),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D57),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow({
    required int newCount,
    required int activeCount,
    required int resolvedCount,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatCard(title: 'NEW', value: '$newCount'),
          SizedBox(width: 12),
          _StatCard(title: 'ACTIVE', value: '$activeCount'),
          SizedBox(width: 12),
          _StatCard(title: 'RESOLVED', value: '$resolvedCount'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text(
          'Manage Complaints',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 37 / 1.7,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF11131E),
          ),
        ),
        const Spacer(),
        const Icon(Icons.tune_rounded, color: _primary, size: 18),
        const SizedBox(width: 4),
        Text(
          'Advanced',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: _primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final selected = _selectedFilter == index;
          return Padding(
            padding: EdgeInsets.only(right: index == _filters.length - 1 ? 0 : 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFD3D6E4)),
                ),
                child: Row(
                  children: [
                    if (index == 1) ...[
                      Icon(
                        Icons.plumbing_outlined,
                        size: 18,
                        color: selected ? Colors.white : const Color(0xFF11131E),
                      ),
                      const SizedBox(width: 8),
                    ] else if (index == 2) ...[
                      Icon(
                        Icons.flash_on_rounded,
                        size: 18,
                        color: selected ? Colors.white : const Color(0xFF11131E),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _filters[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : const Color(0xFF11131E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3D6E4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, color: Color(0xFF9CA3AF), size: 26),
          const SizedBox(height: 10),
          Text(
            'No complaints found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try another filter or check Supabase records.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openStatusDialog(Map<String, dynamic> complaint) async {
    final complaintId = complaint['id']?.toString() ?? complaint['complaint_id']?.toString();
    if (complaintId == null || complaintId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint ID not found.')),
      );
      return;
    }

    final currentStatus = _normalizeStatus(complaint['status']);
    String selectedStatus = currentStatus;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Update Status',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: _statusOptions.map((status) {
                  return RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_displayStatus(status)),
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => selectedStatus = value);
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(selectedStatus),
              style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null || result == currentStatus) return;

    try {
      await _databaseService.updateComplaintStatus(
        complaintId: complaintId,
        status: result,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint status updated.')),
      );
      await _loadComplaints();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _filteredComplaints() {
    return _complaints.where((item) {
      final category = _normalizeCategory(item['category']);
      final status = _normalizeStatus(item['status']);
      final query = _selectedFilter;

      if (query == 0) return true;
      if (query == 1) return category == 'PLUMBING';
      if (query == 2) return category == 'ELECTRICAL';
      if (query == 3) return category == 'WIFI';
      return status.isNotEmpty;
    }).toList();
  }

  Widget _buildCenterAction() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _primary,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.black12,
      height: 84,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Row(
        children: [
          Expanded(child: _navItem(icon: Icons.grid_view_rounded, label: 'Overview', index: 0)),
          Expanded(child: _navItem(icon: Icons.assignment_outlined, label: 'Reports', index: 1)),
          const SizedBox(width: 46),
          Expanded(child: _navItem(icon: Icons.groups_outlined, label: 'Students', index: 2)),
          Expanded(child: _navItem(icon: Icons.settings_outlined, label: 'Settings', index: 3)),
        ],
      ),
    );
  }

  String _displayStatus(String status) {
    switch (status) {
      case 'IN PROGRESS':
        return 'In Progress';
      case 'RESOLVED':
        return 'Resolved';
      default:
        return 'Pending';
    }
  }

  Widget _circleAction(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD1D4E0)),
        color: Colors.white,
      ),
      child: Icon(icon, color: const Color(0xFF11131E), size: 22),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final selected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: selected ? _primary : const Color(0xFF64688A),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? _primary : const Color(0xFF64688A),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8DBE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF595D81),
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF10131F),
                  fontSize: 46 / 1.7,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;
  final String submitterName;
  final VoidCallback onUpdateStatus;

  const _ComplaintCard({
    required this.complaint,
    required this.submitterName,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final status = _normalizeStatus(complaint['status']);
    final category = _normalizeCategory(complaint['category']);
    final title = complaint['title']?.toString() ?? 'Untitled complaint';
    final description = complaint['description']?.toString() ?? '';
    final complaintId = complaint['id']?.toString() ?? complaint['complaint_id']?.toString() ?? '—';
    final initials = _initialsFromName(submitterName);
    final timeAndCategory = '${_formatDate(complaint['created_at']?.toString())} • ${_displayCategory(category)}';
    final statusStyle = _statusStyle(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3D6E4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: statusStyle.borderColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusStyle.color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusStyle.label,
                          style: GoogleFonts.plusJakartaSans(
                            color: statusStyle.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '#C-${complaintId.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0')}',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF62668A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 37 / 1.7,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF11131E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFD8D7FF),
                        child: Text(
                          initials,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF2D31FA),
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              submitterName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 35 / 1.7,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF11131E),
                              ),
                            ),
                            Text(
                              timeAndCategory,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                color: const Color(0xFF585C80),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 35 / 1.7,
                        height: 1.45,
                        color: const Color(0xFF343A67),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (status != 'RESOLVED')
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: onUpdateStatus,
                              icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Update Status',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D31FA),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD1D4E0)),
                          ),
                          child: IconButton(
                            onPressed: onUpdateStatus,
                            icon: Icon(_actionIconForStatus(status), color: const Color(0xFF10131E)),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F1F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF7A7F94)),
                          const SizedBox(width: 8),
                          Text(
                            'Case Closed',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF7A7F94),
                              fontSize: 34 / 1.7,
                              fontWeight: FontWeight.w700,
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
}

class _StudentCard extends StatelessWidget {
  final String fullName;
  final String initials;
  final String username;
  final String phone;
  final String email;
  final String room;

  const _StudentCard({
    required this.fullName,
    required this.initials,
    required this.username,
    required this.phone,
    required this.email,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD3D6E4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFD8D7FF),
            child: Text(
              initials,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF2D31FA),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF11131E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@$username • Room $room',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF5B6080),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$phone • $email',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF7A7F94),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final String label;
  final Color color;
  final Color borderColor;

  const _StatusStyle({
    required this.label,
    required this.color,
    required this.borderColor,
  });
}

_StatusStyle _statusStyle(String status) {
  switch (status) {
    case 'RESOLVED':
      return const _StatusStyle(label: 'Resolved', color: Color(0xFF1C9B59), borderColor: Color(0xFF2BCB77));
    case 'IN PROGRESS':
      return const _StatusStyle(label: 'In Progress', color: Color(0xFFBF6A00), borderColor: Color(0xFFF59E0B));
    case 'HIGH PRIORITY':
      return const _StatusStyle(label: 'High Priority', color: Color(0xFFE53935), borderColor: Color(0xFFFF3A3A));
    default:
      return const _StatusStyle(label: 'Pending', color: Color(0xFFF57C00), borderColor: Color(0xFFF59E0B));
  }
}

IconData _actionIconForStatus(String status) {
  switch (status) {
    case 'IN PROGRESS':
      return Icons.history_toggle_off_rounded;
    case 'HIGH PRIORITY':
      return Icons.call_outlined;
    default:
      return Icons.edit_note_rounded;
  }
}

String _normalizeStatus(dynamic status) => (status?.toString() ?? 'PENDING').toUpperCase();

String _normalizeCategory(dynamic category) => (category?.toString() ?? 'OTHER').toUpperCase();

String _displayCategory(String normalizedCategory) {
  switch (normalizedCategory) {
    case 'PLUMBING':
      return 'Plumbing';
    case 'ELECTRICAL':
      return 'Electrical';
    case 'WIFI':
    case 'INTERNET & WI-FI':
      return 'WiFi';
    default:
      return 'Other';
  }
}

String _initialsFromName(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return '??';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}

String _formatDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '—';
  final dateTime = DateTime.tryParse(isoDate);
  if (dateTime == null) return '—';

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
}