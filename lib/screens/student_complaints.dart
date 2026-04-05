import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../services/database_service.dart';

class StudentComplaintsScreen extends StatefulWidget {
  const StudentComplaintsScreen({super.key});

  @override
  State<StudentComplaintsScreen> createState() => StudentComplaintsScreenState();
}

class StudentComplaintsScreenState extends State<StudentComplaintsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _complaints = [];
  Map<String, String> _submitterNames = {};
  bool _isLoading = true;
  String _activeStatusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> refresh() => _loadData();

  Future<void> _loadData() async {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final visibleComplaints = _filteredComplaints();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearch(),
            const SizedBox(height: 14),
            _buildFilters(),
            const SizedBox(height: 28),
            Text(
              'Active Ledger',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 44 / 1.6,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Review and track hostel maintenance requests',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Total complaints: ${_complaints.length}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D4ED8),
              ),
            ),
            const SizedBox(height: 18),
            if (visibleComplaints.isEmpty)
              _buildEmptyState()
            else
              ...visibleComplaints.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildComplaintCard(item),
                ),
              ),
            const SizedBox(height: 8),
            _buildHelpCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.plusJakartaSans(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search by complaint or name...',
          hintStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF6B7280),
            fontSize: 16,
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF0F2F5),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('ALL', label: 'Filters', icon: LucideIcons.slidersHorizontal),
          const SizedBox(width: 8),
          _buildChip('PENDING', label: 'Pending'),
          const SizedBox(width: 8),
          _buildChip('IN PROGRESS', label: 'In Progress'),
          const SizedBox(width: 8),
          _buildChip('RESOLVED', label: 'Resolved'),
        ],
      ),
    );
  }

  Widget _buildChip(String value, {required String label, IconData? icon}) {
    final selected = _activeStatusFilter == value;
    return InkWell(
      onTap: () => setState(() => _activeStatusFilter = value),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? Colors.white : const Color(0xFF374151)),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: selected ? Colors.white : const Color(0xFF374151),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final status = (complaint['status']?.toString() ?? 'PENDING').toUpperCase();
    final title = complaint['title']?.toString() ?? 'Untitled complaint';
    final description = complaint['description']?.toString() ?? '';
    final date = _formatDate(complaint['created_at']?.toString());
    final userId = complaint['user_id']?.toString() ?? '';
    final userName = _submitterNames[userId] ?? 'Student';

    final statusData = _statusStyle(status);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: status == 'IN PROGRESS'
            ? const Border(left: BorderSide(color: Color(0xFFF59E0B), width: 3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusData.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(statusData.icon, size: 12, color: statusData.fg),
                    const SizedBox(width: 5),
                    Text(
                      statusData.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusData.fg,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 35 / 1.6,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              height: 1.45,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.user, size: 16, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  userName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F3B78),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                status == 'RESOLVED' ? 'View Report  →' : 'Details  →',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F4DBA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFA7C1EE), width: 1.2, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE8FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Color(0xFF1E56B5), size: 30),
          ),
          const SizedBox(height: 18),
          Text(
            'Need assistance?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 34 / 1.6,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F4DBA),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our concierge is ready to help resolve your hostel issues.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF4B5563),
            ),
          ),
        ],
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
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.fileText, color: Color(0xFF9CA3AF), size: 24),
          const SizedBox(height: 10),
          Text(
            'No complaints found',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try changing filters or create a new complaint.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filteredComplaints() {
    final query = _searchController.text.trim().toLowerCase();

    return _complaints.where((item) {
      final status = (item['status']?.toString() ?? 'PENDING').toUpperCase();
      final title = item['title']?.toString().toLowerCase() ?? '';
      final description = item['description']?.toString().toLowerCase() ?? '';
      final userId = item['user_id']?.toString() ?? '';
      final name = (_submitterNames[userId] ?? 'Student').toLowerCase();

      final matchesStatus = _activeStatusFilter == 'ALL' || status == _activeStatusFilter;
      final matchesSearch =
          query.isEmpty || title.contains(query) || description.contains(query) || name.contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '—';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return '—';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  _StatusStyle _statusStyle(String status) {
    switch (status) {
      case 'RESOLVED':
        return const _StatusStyle(
          label: 'RESOLVED',
          bg: Color(0xFFDBEAFE),
          fg: Color(0xFF1D4ED8),
          icon: LucideIcons.checkCircle2,
        );
      case 'IN PROGRESS':
        return const _StatusStyle(
          label: 'IN PROGRESS',
          bg: Color(0xFFFFEDD5),
          fg: Color(0xFF9A3412),
          icon: LucideIcons.briefcase,
        );
      default:
        return const _StatusStyle(
          label: 'PENDING',
          bg: Color(0xFFFECACA),
          fg: Color(0xFF991B1B),
          icon: LucideIcons.alertCircle,
        );
    }
  }
}

class _StatusStyle {
  final String label;
  final Color bg;
  final Color fg;
  final IconData icon;

  const _StatusStyle({
    required this.label,
    required this.bg,
    required this.fg,
    required this.icon,
  });
}
