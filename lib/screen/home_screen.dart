import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/base_state.dart';
import '../core/event_filters.dart';
import '../data/location_service.dart';
import '../logic/events_cubit.dart';
import '../models/event_item.dart';
import '../widgets/event_visual.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final EventsCubit _cubit;
  int _selectedChip = 0;
  final List<String> _chips = ['All', 'Tonight', 'This weekend', 'Guestlist open', 'Tables'];
  String _locationLabel = 'No Location';
  Timer? _dateTimer;
  DateTime _visibleDay = DateUtils.dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _cubit = context.read<EventsCubit>();
    _loadLocation();
    WidgetsBinding.instance.addObserver(this);
    _dateTimer = Timer.periodic(const Duration(minutes: 1), (_) => _refreshDate());
    // The first global load may have run before authentication completed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cubit.loadEvents();
    });
  }

  void _refreshDate() {
    if (!mounted) return;
    final today = DateUtils.dateOnly(DateTime.now());
    setState(() {
      if (today != _visibleDay) _selectedChip = 0;
      _visibleDay = today;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDate();
      _cubit.loadEvents();
    }
  }

  @override
  void dispose() {
    _dateTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadLocation() async {
    final position = await LocationService().getCurrentLocation();
    if (position == null || !mounted) return;
    setState(() => _locationLabel = 'Current location');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            return _homeMainWidget(_filteredEvents(events));
          },
        ),
      ),
    );
  }

  Widget _homeMainWidget(List<EventItem> events) {
    return RefreshIndicator(
      color: const Color(0xFFE63888),
      onRefresh: _cubit.loadEvents,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _locationLabel,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tonight's Lineup",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.person, color: Colors.white),
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFF2A2237), shape: const CircleBorder()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _searchBar(),
                  const SizedBox(height: 14),
                  _chipRow(),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(_selectedChip == 1 ? 'Featured tonight' : 'Featured nights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  if (events.isNotEmpty) _featuredRow(context, events),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Upcoming nights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  events.isEmpty ? _emptyEvents() : _eventList(events),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyEvents() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.event_busy, color: Colors.white38, size: 40),
          const SizedBox(height: 12),
          Text(
            _selectedChip == 0 ? 'No upcoming events yet' : 'No events for this filter',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedChip == 0
                ? 'New nights will appear here when hosts publish them.'
                : 'Try All to see other upcoming nights.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, height: 1.5),
          ),
          if (_selectedChip != 0)
            TextButton(
              onPressed: () => setState(() => _selectedChip = 0),
              child: const Text('Show all events', style: TextStyle(color: Color(0xFFE63888))),
            ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2237),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search venues, nights, areas',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipRow() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedChip == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedChip = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE63888).withOpacity(0.15) : const Color(0xFF2A2237),
                border: Border.all(color: isSelected ? const Color(0xFFE63888) : Colors.transparent, width: 1.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                _chips[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFFE63888) : Colors.white70,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _featuredRow(BuildContext context, List<EventItem> events) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => _openDetail(context, event),
              child: _flyerCard(event),
            ),
          );
        },
      ),
    );
  }

  Widget _flyerCard(EventItem event) {
    return SizedBox(
      width: 200,
      height: 260,
      child: Stack(
        children: [
          Positioned.fill(
            child: EventVisual(event: event, borderRadius: BorderRadius.circular(18)),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(event.tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
                const SizedBox(height: 4),
                Text(event.venue, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventList(List<EventItem> events) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _eventRow(events[index]),
    );
  }

  Widget _eventRow(EventItem event) {
    return GestureDetector(
      onTap: () => _openDetail(context, event),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF201A2B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 74,
              height: 74,
              child: EventVisual(
                event: event,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(event.venue, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.6))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE63888).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(event.tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFE63888))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, EventItem event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    );
  }

  List<EventItem> _filteredEvents(List<EventItem> events) {
    return filterUpcomingEvents(
      events,
      selectedChip: _selectedChip,
      now: DateTime.now(),
    );
  }
}
