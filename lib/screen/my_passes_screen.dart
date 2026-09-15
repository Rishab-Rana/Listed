import 'package:flutter/material.dart';
import '../models/event_item.dart';

class MyPassesScreen extends StatelessWidget {
  const MyPassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for now — this will come from real reservation state later
    final List<EventItem> passes = [dummyEvents[0]];

    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17111F),
        elevation: 0,
        title: const Text('My Passes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: passes.isEmpty ? _emptyState() : _passList(passes),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No passes yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.7))),
            const SizedBox(height: 8),
            Text(
              "Reserve your spot on a guestlist or table and it'll show up here — ready to show at the door.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.6, color: Colors.white.withOpacity(0.4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passList(List<EventItem> passes) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: passes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _miniTicket(passes[index]),
    );
  }

  Widget _miniTicket(EventItem event) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF201A2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 74,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: event.gradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text('${event.venue} · ${event.date}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                  const SizedBox(height: 6),
                  const Text('✓ CONFIRMED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF6BBF8C))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}