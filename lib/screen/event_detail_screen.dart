import 'package:flutter/material.dart';
import 'package:listed/screen/reserve_screen.dart';
import '../models/event_item.dart';

class EventDetailScreen extends StatelessWidget {
  final EventItem event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      body: CustomScrollView(
        slivers: [
          _heroAppBar(context),
          SliverToBoxAdapter(
            child: _detailBody(),
          ),
        ],
      ),
      bottomNavigationBar: _actionBar(context),
    );
  }

  Widget _heroAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF17111F),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.4), shape: const CircleBorder()),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: event.gradient,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(event.title, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white, height: 0.95)),
                  const SizedBox(height: 6),
                  Text(event.venue, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.9))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailBody() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _metaPill('Date', event.date)),
              const SizedBox(width: 10),
              Expanded(child: _metaPill('Time', event.time)),
            ],
          ),
          const SizedBox(height: 20),
          _capacityBlock(),
          const SizedBox(height: 20),
          _notesBlock(),
        ],
      ),
    );
  }

  Widget _metaPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF201A2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.4))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _capacityBlock() {
    final fillRatio = (event.reserved / event.capacity).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Guestlist capacity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.6))),
            Text('${event.reserved} / ${event.capacity} listed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.6))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: fillRatio,
            minHeight: 8,
            backgroundColor: const Color(0xFF2A2237),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFC9A15E)),
          ),
        ),
      ],
    );
  }

  Widget _notesBlock() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF201A2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ENTRY NOTES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFC9A15E))),
          const SizedBox(height: 8),
          Text(event.notes, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _actionBar(context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF17111F),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReserveScreen(event: event)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE63888),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Join Event', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}