import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/phone_number.dart';
import 'auth_gate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/auth_cubit.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneTextInput = TextEditingController();
  bool _isSubmitting = false;

  bool get _isValid => isValidIndianMobileNumber(_phoneTextInput.text);

  Future<void> _continue() async {
    if (_isSubmitting || !_isValid) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    final auth = context.read<AuthCubit>();
    try {
      final phone = '+91${_phoneTextInput.text.trim()}';
      final sent = await auth.sendOtp(phone);
      if (!mounted) return;
      if (!sent) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(auth.state.error ?? 'Could not send OTP. Please try again.'),
        ));
        return;
      }
      if (auth.isSignedIn) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (_) => false,
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OtpScreen(phoneNumber: phone)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

@override
void dispose() {
_phoneTextInput.dispose();
super.dispose();
}

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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        enabled: !_isSubmitting,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _continue(),
        style: const TextStyle(color: Colors.white),
        controller: _phoneTextInput,
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

  Widget _continueBtn(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isValid && !_isSubmitting ? _continue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE63888),
          disabledBackgroundColor: const Color(0xFF2A2237),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          _isSubmitting ? 'Please wait...' : 'Continue',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
