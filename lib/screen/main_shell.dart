import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/base_state.dart';
import '../logic/user_cubit.dart';
import '../models/app_user.dart';
import 'home_screen.dart';
import 'my_passes_screen.dart';
import 'host_dashboard_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, BaseState<AppUser>>(
      builder: (context, userState) {
        final isHost = userState.data?.isHost ?? false;

        final screens = [
          const HomeScreen(),
          const MyPassesScreen(),
          if (isHost) const HostDashboardScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: _currentIndex.clamp(0, screens.length - 1),
            children: screens,
          ),
          bottomNavigationBar: _bottomNav(isHost),
        );
      },
    );
  }

  Widget _bottomNav(bool isHost) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17111F),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 24),
      child: Row(
        children: [
          _navItem(0, Icons.home, 'Home'),
          _navItem(1, Icons.confirmation_number, 'My Passes'),
          if (isHost) _navItem(2, Icons.mic, 'Host'),
          _navItem(isHost ? 3 : 2, Icons.person, 'Profile'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? const Color(0xFFE63888) : Colors.white38,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected ? const Color(0xFFE63888) : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
