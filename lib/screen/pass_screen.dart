import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import '../models/event_item.dart';

class PassScreen extends StatelessWidget {
  final EventItem event;
  final String reserveType;
  final int partySize;

  const PassScreen({
    super.key,
    required this.event,
    required this.reserveType,
    required this.partySize,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17111F),
        elevation: 0,
        title: const Text('Your pass', style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ticket(),
                const SizedBox(height: 18),
                _contactCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ticket() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF201A2B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusChip(),
                const SizedBox(height: 14),
                Text(event.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  '${event.venue} · ${event.area}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.6)),
                ),
                const SizedBox(height: 18),
                _ticketGrid(),
              ],
            ),
          ),
          const DottedLine(
            dashColor: Colors.white24,
            lineThickness: 1.5,
            dashLength: 6,
            dashGapLength: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LST-${(1000 + partySize * 137) % 9999}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                    Text('Show this at entry', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6BBF8C).withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Text(
        '✓ CONFIRMED — NO APPROVAL NEEDED',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF6BBF8C)),
      ),
    );
  }

  Widget _ticketGrid() {
    return Row(
      children: [
        Expanded(child: _gridItem('Date', event.date)),
        Expanded(child: _gridItem('Time', event.time.split('–').first.trim())),
      ],
    );
  }

  Widget _gridItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.4))),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }

  Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201A2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFC9A15E), Color(0xFFE63888)]),
              shape: BoxShape.circle,
            ),
            child: const Text('RS', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1C1420))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR ENTRY CONTACT TONIGHT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.4))),
                const SizedBox(height: 2),
                const Text('Rishab · +91 98100 22334', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
          ),
          _roundIconButton(Icons.chat_bubble, const Color(0xFF25D366)),
          const SizedBox(width: 8),
          _roundIconButton(Icons.call, const Color(0xFF332B41)),
        ],
      ),
    );
  }

  Widget _roundIconButton(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
}