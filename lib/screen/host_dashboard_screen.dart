import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/base_state.dart';
import '../logic/events_cubit.dart';
import '../models/event_item.dart';
import 'create_event_screen.dart';
import 'guestlist_screen.dart';

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  late final EventsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<EventsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      body: SafeArea(
        child: BlocBuilder<EventsCubit, BaseState<List<EventItem>>>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (state.error != null) {
              return Center(child: Text(state.error!, style: const TextStyle(color: Colors.white70)));
            }

            final events = state.data ?? [];
            final totalReserved = events.fold(0, (sum, e) => sum + e.reserved);
            final totalCapacity = events.fold(1, (sum, e) => sum + e.capacity);
            final avgFill = ((totalReserved / totalCapacity) * 100).round();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                _statRow(events.length, totalReserved, avgFill),
                Expanded(child: _eventsList(context, events)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE63888),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HOST MODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.4))),
              const Text('Your Nights', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: const Color(0xFF2A2237), shape: const CircleBorder()),
          ),
        ],
      ),
    );
  }

  Widget _statRow(int liveNights, int totalReserved, int avgFill) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Row(
        children: [
          Expanded(child: _statCard('$liveNights', 'Live nights')),
          const SizedBox(width: 10),
          Expanded(child: _statCard('$totalReserved', 'Total listed')),
          const SizedBox(width: 10),
          Expanded(child: _statCard('$avgFill%', 'Avg fill')),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF201A2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.4))),
        ],
      ),
    );
  }

  Widget _eventsList(BuildContext context, List<EventItem> events) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _hostEventCard(context, events[index]),
    );
  }

  Widget _hostEventCard(BuildContext context, EventItem event) {
    final fillRatio = (event.reserved / event.capacity).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => GuestListScreen(event: event)));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF201A2B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                    Text('${event.venue} · ${event.date}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE63888).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(event.tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFE63888))),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: fillRatio,
                minHeight: 6,
                backgroundColor: const Color(0xFF2A2237),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFC9A15E)),
              ),
            ),
            const SizedBox(height: 6),
            Text('${event.reserved} / ${event.capacity} listed · tap to manage guestlist', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
          ],
        ),
      ),
    );
  }
}