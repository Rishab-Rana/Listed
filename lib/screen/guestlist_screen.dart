import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/base_state.dart';
import '../logic/guest_list_cubit.dart';
import '../models/event_item.dart';
import '../models/reservation.dart';

class GuestListScreen extends StatefulWidget {
  final EventItem event;
  const GuestListScreen({super.key, required this.event});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  late final GuestListCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<GuestListCubit>();
    _cubit.loadForEvent(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
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
        child: BlocBuilder<GuestListCubit, BaseState<List<Reservation>>>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (state.error != null) {
              return Center(child: Text(state.error!, style: const TextStyle(color: Colors.white70)));
            }

            final guests = state.data ?? [];
            final checkedInCount = guests.where((g) => g.checkedIn).length;
            final totalGuests = guests.fold(0, (sum, g) => sum + g.partySize);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryRow(guests.length, totalGuests, checkedInCount),
                Expanded(child: _guestListView(guests)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summaryRow(int reservationCount, int totalGuests, int checkedInCount) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: _statCard('$reservationCount', 'Reservations')),
          const SizedBox(width: 10),
          Expanded(child: _statCard('$totalGuests', 'Total guests')),
          const SizedBox(width: 10),
          Expanded(child: _statCard('$checkedInCount/$reservationCount', 'Checked in')),
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

  Widget _guestListView(List<Reservation> guests) {
    if (guests.isEmpty) {
      return Center(
        child: Text('No reservations yet', style: TextStyle(color: Colors.white.withOpacity(0.5))),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: guests.length,
      separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.06), height: 1),
      itemBuilder: (context, index) => _guestRow(guests[index]),
    );
  }

  Widget _guestRow(Reservation r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFF2A2237), shape: BoxShape.circle),
            child: Text(_initials(r.leadName), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.leadName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                Text('${r.type} · ${r.partySize} guests · ${r.leadPhone}', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ),
          _checkInButton(r),
        ],
      ),
    );
  }

  Widget _checkInButton(Reservation r) {
    return GestureDetector(
      onTap: () => _cubit.toggleCheckIn(r.id, r.checkedIn),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: r.checkedIn ? const Color(0xFF6BBF8C).withOpacity(0.15) : Colors.transparent,
          border: Border.all(color: r.checkedIn ? const Color(0xFF6BBF8C) : Colors.white.withOpacity(0.15), width: 1.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          r.checkedIn ? '✓ In' : 'Check in',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: r.checkedIn ? const Color(0xFF6BBF8C) : Colors.white.withOpacity(0.6)),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }
}