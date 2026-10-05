import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../core/base_state.dart';
import '../logic/user_cubit.dart';
import '../models/app_user.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const ProfileScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      body: SafeArea(
        child: BlocBuilder<UserCubit, BaseState<AppUser>>(
          builder: (context, state) {
            final user = state.data;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileHeader(user),
                  if (user?.isHost == true) _hostCard(),
                  _menuList(context),
                  _signOutButton(context),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profileHeader(AppUser? user) {
    final name = (user?.name.isNotEmpty ?? false) ? user!.name : 'Guest';
    final subtitle = [
      if (user?.phone.isNotEmpty ?? false) user!.phone,
      if (user?.age != null) '${user!.age} yrs',
      if (user?.gender.isNotEmpty ?? false) user!.gender,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Row(
        children: [
          _avatar(user),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(AppUser? user) {
    const size = 60.0;

    if (user?.photoUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: user!.photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _avatarFallback(user.name),
          errorWidget: (context, url, error) => _avatarFallback(user.name),
        ),
      );
    }

    return _avatarFallback(user?.name ?? '');
  }

  Widget _avatarFallback(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFC9A15E), Color(0xFFE63888)]),
        shape: BoxShape.circle,
      ),
      child: Text(initial, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1C1420))),
    );
  }

  Widget _hostCard() {
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
          const Text("You're a host", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            'Post nights, manage guestlists and check people in at the door.',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6), height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () => onNavigate(2), // Host tab — always index 2 when present
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

  Widget _menuList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _menuItem('🎫', 'My passes', onTap: () => onNavigate(1)),
          _menuItem('📍', 'Saved venues'),
          _menuItem('🔔', 'Notifications'),
          _menuItem('⚙️', 'Settings'),
          _menuItem('💬', 'Help & support'),
        ],
      ),
    );
  }

  Widget _menuItem(String emoji, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _signOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: () => _handleSignOut(context),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white.withOpacity(0.15)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Sign out', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(settings: const RouteSettings(name: '/login'), builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
}