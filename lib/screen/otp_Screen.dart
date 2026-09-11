import 'package:flutter/material.dart';
import 'package:listed/screen/home_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              _backButton(context),
              const SizedBox(height: 24),
              _title(),
              const SizedBox(height: 8),
              _subtitle(),
              const SizedBox(height: 36),
              _otpRow(),
              const SizedBox(height: 28),
              _verifyBtn(),
              const SizedBox(height: 18),
              _resendLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFF2A2237),
          shape: const CircleBorder(),
        ),
      ),
    );
  }

  Widget _title() {
    return const Text(
      'Enter the code',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    );
  }

  Widget _subtitle() {
    return Text(
      'Sent to +91 98765 43210',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.6),
      ),
    );
  }

  Widget _otpRow() {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 3 ? 0 : 12),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(color: Colors.white, fontSize: 22),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: const Color(0xFF2A2237),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty && index < 3) {
                  _focusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _verifyBtn() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE63888),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Verify & continue',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _resendLink() {
    return GestureDetector(
      onTap: () {

      },
      child: const Text(
        'Resend code',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFFC9A15E),
        ),
      ),
    );
  }
}