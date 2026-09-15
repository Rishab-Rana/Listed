import 'package:flutter/material.dart';
import 'package:listed/screen/pass_screen.dart';
import '../models/event_item.dart';

class ReserveScreen extends StatefulWidget {
  final EventItem event;
  const ReserveScreen({super.key, required this.event});

  @override
  State<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen> {
  final _formKey = GlobalKey<FormState>();
  String _reserveType = 'guestlist';
  int _partySize = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17111F),
        elevation: 0,
        title: const Text('Reserve your spot', style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _summaryCard(),
                const SizedBox(height: 20),
                _typeToggle(),
                const SizedBox(height: 20),
                _partyStepper(),
                const SizedBox(height: 20),
                _formFields(),
                const SizedBox(height: 28),
                _submitButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF201A2B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.event.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 3),
            Text(
              '${widget.event.venue} · ${widget.event.date}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _typeOption('guestlist', 'Guestlist', 'No cover, no approval')),
          const SizedBox(width: 10),
          Expanded(child: _typeOption('table', 'Table', 'Seating + minimum spend')),
        ],
      ),
    );
  }

  Widget _typeOption(String value, String title, String subtitle) {
    final isSelected = _reserveType == value;
    return GestureDetector(
      onTap: () => setState(() => _reserveType = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE63888).withOpacity(0.1) : const Color(0xFF201A2B),
          border: Border.all(color: isSelected ? const Color(0xFFE63888) : Colors.white.withOpacity(0.08), width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  Widget _partyStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PARTY SIZE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.5), letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2237),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stepperButton(Icons.remove, () {
                  if (_partySize > 1) setState(() => _partySize--);
                }),
                Text('$_partySize', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                _stepperButton(Icons.add, () {
                  if (_partySize < 8) setState(() => _partySize++);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF332B41),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _formFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Lead guest name'),
          const SizedBox(height: 8),
          TextFormField(
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDecoration('Your full name'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Enter your name';
              return null;
            },
          ),
          const SizedBox(height: 18),
          _fieldLabel('Mobile number'),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDecoration('+91 98765 43210'),
            validator: (value) {
              if (value == null || value.trim().length < 10) return 'Enter a valid number';
              return null;
            },
          ),
          if (_reserveType == 'table') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFC9A15E).withOpacity(0.1),
                border: Border.all(color: const Color(0xFFC9A15E).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Table deposit and minimum spend are settled directly at the venue — nothing is charged in the app.',
                style: TextStyle(fontSize: 12, color: Color(0xFFC9A15E), height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(text.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.5), letterSpacing: 0.5));
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
      filled: true,
      fillColor: const Color(0xFF2A2237),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );
  }

  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE63888),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Confirm reservation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PassScreen(event: widget.event, reserveType: _reserveType, partySize: _partySize)),
      );
    }
  }
}