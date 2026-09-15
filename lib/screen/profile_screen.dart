import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileHeader(),
              _switchCard(context),
              _menuList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFC9A15E), Color(0xFFE63888)]),
              shape: BoxShape.circle,
            ),
            child: const Text('A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1C1420))),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aarav Mehta', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('+91 98765 43210', style: TextStyle(fontSize: 13, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _switchCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFC9A15E).withOpacity(0.15), const Color(0xFFE63888).withOpacity(0.1)],
        ),
        border: Border.all(color: const Color(0xFFC9A15E).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Switch to Host mode', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            'Post your nights, manage guestlists and check people in at the door.',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6), height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                // handled by bottom nav shell once built
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A15E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Go to Host dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF241A0E))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuList() {
    final items = [
      ('🎫', 'My passes'),
      ('📍', 'Saved venues'),
      ('🔔', 'Notifications'),
      ('⚙️', 'Settings'),
      ('💬', 'Help & support'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: items.map((item) => _menuItem(item.$1, item.$2)).toList(),
      ),
    );
  }

  Widget _menuItem(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white))),
          Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }
}