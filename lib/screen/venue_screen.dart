import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/saved_venues_cubit.dart';
import '../models/event_item.dart';
import '../models/saved_venue.dart';
import '../widgets/event_visual.dart';
import '../widgets/save_venue_button.dart';
import '../widgets/venue_visual.dart';
import 'event_detail_screen.dart';

class VenueScreen extends StatefulWidget {
  final SavedVenue venue;

  const VenueScreen({super.key, required this.venue});

  @override
  State<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends State<VenueScreen> with WidgetsBindingObserver {
  late Stream<List<EventItem>> _events;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _events = _watchEvents();
    WidgetsBinding.instance.addObserver(this);
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Stream<List<EventItem>> _watchEvents() =>
      context.read<SavedVenuesCubit>().repository.watchEventsForVenue(widget.venue);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(() {});
  }

  @override
  void dispose() {
    _clock?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17111F),
        foregroundColor: Colors.white,
        title: Text(widget.venue.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          SaveVenueButton(venue: widget.venue),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<EventItem>>(
        stream: _events,
        builder: (context, snapshot) {
          final now = DateTime.now();
          final events = (snapshot.data ?? [])
              .where((event) => !event.isDeleting && !event.eventDateTime.isBefore(now))
              .toList();
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header()),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Text('Upcoming nights',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                ),
              ),
              if (snapshot.hasError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _message(
                    'Could not load nights',
                    'Check your connection and try again.',
                    retry: true,
                  ),
                )
              else if (!snapshot.hasData)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                )
              else if (events.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _message('No upcoming nights yet',
                      'This venue stays saved. New nights will appear here when published.'),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _eventCard(events[index]),
                      ),
                      childCount: events.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VenueVisual(imageUrl: widget.venue.coverImageUrl,
                borderRadius: BorderRadius.circular(18)),
          ),
          if (widget.venue.area.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFC9A15E)),
                const SizedBox(width: 6),
                Expanded(child: Text(widget.venue.area,
                    style: const TextStyle(color: Colors.white70, fontSize: 13))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _message(String title, String detail, {bool retry = false}) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(detail, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, height: 1.5)),
          if (retry)
            TextButton(
              onPressed: () => setState(() => _events = _watchEvents()),
              child: const Text('Retry', style: TextStyle(color: Color(0xFFE63888))),
            ),
        ],
      ),
    );
  }

  Widget _eventCard(EventItem event) {
    return Material(
      color: const Color(0xFF201A2B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => EventDetailScreen(event: event))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(width: 70, height: 70,
                  child: EventVisual(event: event, borderRadius: BorderRadius.circular(12))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('${event.date} · ${event.time}',
                        style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    if (event.tag.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(event.tag, style: const TextStyle(color: Color(0xFFE63888), fontSize: 11)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
