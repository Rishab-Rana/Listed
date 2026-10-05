import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/user_cubit.dart';
import '../models/app_user.dart';
import 'complete_profile_screen.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final user = FirebaseAuth.instance.currentUser;

    AppUser? appUser;
    if (user != null) {
      await context.read<UserCubit>().loadOrCreate(user.uid, user.phoneNumber ?? '');
      appUser = context.read<UserCubit>().state.data;
    }

    if (!mounted) return;

    Widget destination;
    if (user == null) {
      destination = const LoginScreen();
    } else if (appUser == null || !appUser.isProfileComplete) {
      destination = const CompleteProfileScreen();
    } else {
      destination = const MainShell();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(settings: const RouteSettings(name: '/main'), builder: (_) => destination),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF17111F),
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}