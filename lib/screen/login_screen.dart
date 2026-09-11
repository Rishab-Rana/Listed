import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _logoHeader(),
              const SizedBox(height: 8),
              _logoDesc(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoHeader() {
    return Text(
      'LISTED',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 1,
      ),
    );
  }

  Widget _logoDesc() {
    return Text(
      'Skip the line. Get listed.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.6),
      ),
    );
  }

  Widget _phoneCode() {
    return Row();
  }
}
