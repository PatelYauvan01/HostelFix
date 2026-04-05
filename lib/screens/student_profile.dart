import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/auth_service.dart';
import '../auth/screens/login_screen.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile({super.key});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final profile = await _authService.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile Header
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[100],
                backgroundImage: _userProfile?['avatar_url'] != null
                    ? NetworkImage(_userProfile!['avatar_url'])
                    : null,
                child: _userProfile?['avatar_url'] == null
                    ? Text(
                        (_userProfile?['full_name'] ??
                                _authService.currentUser?.userMetadata?['full_name'] ??
                                'U')[0]
                            .toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D31FA),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                _userProfile?['full_name'] ??
                    _authService.currentUser?.userMetadata?['full_name'] ??
                    'Student Name',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                _userProfile?['email'] ??
                    _authService.currentUser?.email ??
                    'No email',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Profile Details Card
              Container(
                padding: const EdgeInsets.all(20),
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
                  children: [
                    _buildProfileItem(
                      icon: LucideIcons.user,
                      label: 'Username',
                      value: _userProfile?['username'] ??
                          _authService.currentUser?.userMetadata?['username'] ??
                          'Not set',
                    ),
                    const Divider(height: 32),
                    _buildProfileItem(
                      icon: LucideIcons.phone,
                      label: 'Phone Number',
                      value: _userProfile?['phone_number'] ?? 'Not set',
                    ),
                    const Divider(height: 32),
                    _buildProfileItem(
                      icon: LucideIcons.doorOpen, // Replaced doorClosed with doorOpen (common alternative) or just door
                      label: 'Room Number',
                      value: _userProfile?['room_number'] ??
                          _authService.currentUser?.userMetadata?['room_number'] ??
                          'Not set',
                    ),
                    const Divider(height: 32),
                    _buildProfileItem(
                      icon: LucideIcons.badgeCheck,
                      label: 'Role',
                      value: (_userProfile?['role'] ?? 'Student').toString().toUpperCase(),
                    ),
                    const Divider(height: 32),
                    _buildProfileItem(
                      icon: LucideIcons.clock,
                      label: 'Joined',
                      value: _userProfile?['created_at'] != null
                          ? _userProfile!['created_at'].toString().substring(0, 10)
                          : 'Unknown',
                    ),
                    const Divider(height: 32),
                    _buildProfileItem(
                      icon: LucideIcons.refreshCw,
                      label: 'Last Updated',
                      value: _userProfile?['updated_at'] != null
                          ? _userProfile!['updated_at'].toString().substring(0, 10)
                          : 'Never',
                    ),
                    const Divider(height: 32),
                    _buildProfileItem(
                      icon: LucideIcons.fingerprint,
                      label: 'User ID',
                      value: _userProfile?['id'] ?? 'Unknown',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(LucideIcons.logOut),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    foregroundColor: const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF2D31FA)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
