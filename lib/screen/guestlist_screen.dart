import 'package:flutter/material.dart';
import '../models/event_item.dart';
import '../models/guest_reservation.dart';

class GuestListScreen extends StatefulWidget {
  final EventItem event;
  const GuestListScreen({super.key, required this.event});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  final List<GuestReservation> _guests = [
    GuestReservation(name: 'Priya Sharma', phone: '+91 98110 22331', size: 2, type: 'Guestlist'),
    GuestReservation(name: 'Karan Vij', phone: '+91 99586 44120', size: 4, type: 'Table', checkedIn: true),
    GuestReservation(name: 'Neha & friends', phone: '+91 97170 88213', size: 3, type: 'Guestlist'),
    GuestReservation(name: 'Rohan Kapoor', phone: '+91 98730 11209', size: 2, type: 'Guestlist', checkedIn: true),
    GuestReservation(name: 'Simran Kaur', phone: '+91 96543 90871', size: 5, type: 'Table'),
  ];

  @override
  Widget build(BuildContext context) {
    final checkedInCount = _guests.where((g) => g.checkedIn).length;
    final totalGuests = _guests.fold(0, (sum, g) => sum + g.size);

    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17111F),
        elevation: 0,
        title: Text(widget.event.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryRow(checkedInCount, totalGuests),
            Expanded(child: _guestListView()),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(int checkedInCount, int totalGuests) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: _statCard('${_guests.length}', 'Reservations')),
          const SizedBox(width: 10),
          Expanded(child: _statCard('$totalGuests', 'Total guests')),
          const SizedBox(width: 10),
          Expanded(child: _statCard('$checkedInCount/${_guests.length}', 'Checked in')),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
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
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.4))),
        ],
      ),
    );
  }

  Widget _guestListView() {
    if (_guests.isEmpty) {
      return Center(
        child: Text('No reservations yet', style: TextStyle(color: Colors.white.withOpacity(0.5))),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _guests.length,
      separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.06), height: 1),
      itemBuilder: (context, index) => _guestRow(_guests[index]),
    );
  }

  Widget _guestRow(GuestReservation guest) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFF2A2237), shape: BoxShape.circle),
            child: Text(_initials(guest.name), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guest.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                Text('${guest.type} · ${guest.size} guests · ${guest.phone}', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ),
          _checkInButton(guest),
        ],
      ),
    );
  }

  Widget _checkInButton(GuestReservation guest) {
    return GestureDetector(
      onTap: () {
        setState(() {
          guest.checkedIn = !guest.checkedIn;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: guest.checkedIn ? const Color(0xFF6BBF8C).withOpacity(0.15) : Colors.transparent,
          border: Border.all(color: guest.checkedIn ? const Color(0xFF6BBF8C) : Colors.white.withOpacity(0.15), width: 1.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          guest.checkedIn ? '✓ In' : 'Check in',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: guest.checkedIn ? const Color(0xFF6BBF8C) : Colors.white.withOpacity(0.6)),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.replaceAll('&', '').trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }
}