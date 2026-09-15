import 'package:flutter/material.dart';

import 'otp_screen.dart';

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
              Row(
                children: [
                  _phoneCode(),
                  const SizedBox(width: 10),
                  _phoneTextField(),
                ],
              ),
              const SizedBox(height: 18),
              _continueBtn(context),
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
    return Container(
      height: 52,
      width: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2237),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        '+91',
        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _phoneTextField() {
    return Expanded(
      child: TextField(
        keyboardType: TextInputType.phone,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: '98765 43210',
          filled: true,
          fillColor: const Color(0xFF2A2237),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _continueBtn(context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const OtpScreen()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE63888),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
