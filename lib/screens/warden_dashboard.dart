import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WardenDashboard extends StatelessWidget {
  const WardenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Color(0xFFE0E0FF),
            child: Icon(LucideIcons.shieldCheck, color: Color(0xFF2D31FA), size: 20),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Warden Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
            Text('Boys Hostel • Block A', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(LucideIcons.search, color: Colors.black)),
          Stack(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(LucideIcons.bell, color: Colors.black)),
              Positioned(right: 12, top: 12, child: CircleAvatar(radius: 4, backgroundColor: Colors.red)),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Report an Issue", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("Provide details about to help our wardens resolve reossible.", 
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),
            
            // Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: Color(0xFFE0E0FF), child: Icon(LucideIcons.user, color: Color(0xFF2D31FA))),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome back,", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("Alex Johnson", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const Spacer(),
                  Icon(LucideIcons.bell, color: Colors.grey.shade400),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            const Text("Recent Complaints", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Grid of Stats
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 2.2,
              children: [
                _buildStatCard("Active", "Complaints", LucideIcons.fileText, Colors.red, true),
                _buildStatCard("03", "Resolved", LucideIcons.checkCircle, Colors.blue, false),
                _buildStatCard("03", "Resolved", LucideIcons.repeat, Colors.grey, false),
                _buildStatCard("Resolved", "20:23 • 9:15 AM", LucideIcons.calendar, Colors.blue, false),
              ],
            ),

            const SizedBox(height: 25),
            
            // Emergency Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A1AFF), Color(0xFF2D31FA)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Need urgent help? Contact\nthe warden directly...", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Call Warden", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2D31FA),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildStatCard(String title, String sub, IconData icon, Color color, bool hasBadge) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Icon(icon, color: Colors.grey, size: 24),
              if (hasBadge)
                Positioned(right: 0, top: 0, child: CircleAvatar(radius: 6, backgroundColor: color, child: const Text("!", style: TextStyle(fontSize: 8, color: Colors.white)))),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 10), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(LucideIcons.home, "Home", false),
          _navItem(LucideIcons.clipboardList, "Complaints", true),
          const SizedBox(width: 40), // Space for FAB
          _navItem(LucideIcons.users, "Students", false),
          _navItem(LucideIcons.settings, "Profile", false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF2D31FA) : Colors.grey, size: 20),
        Text(label, style: TextStyle(color: isActive ? const Color(0xFF2D31FA) : Colors.grey, fontSize: 10)),
      ],
    );
  }
}