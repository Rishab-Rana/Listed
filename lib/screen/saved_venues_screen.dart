import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/saved_venues_cubit.dart';
import '../logic/saved_venues_state.dart';
import '../models/saved_venue.dart';
import '../widgets/venue_visual.dart';
import 'venue_screen.dart';

class SavedVenuesScreen extends StatelessWidget {
  const SavedVenuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17111F),
        foregroundColor: Colors.white,
        title: const Text('Saved venues', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<SavedVenuesCubit, SavedVenuesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.error!, textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.read<SavedVenuesCubit>().retry(),
                      child: const Text('Retry', style: TextStyle(color: Color(0xFFE63888))),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state.venues.isEmpty) return _emptyState();
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.venues.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _venueCard(context, state.venues[index], state),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border, color: Colors.white38, size: 44),
            SizedBox(height: 14),
            Text('No saved venues yet',
                style: TextStyle(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('Tap the bookmark on an event page to save its venue here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _venueCard(BuildContext context, SavedVenue venue, SavedVenuesState state) {
    return Material(
      color: const Color(0xFF201A2B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => VenueScreen(venue: venue))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: VenueVisual(imageUrl: venue.coverImageUrl,
                    borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(venue.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    if (venue.area.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(venue.area, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                    const SizedBox(height: 6),
                    const Text('View upcoming nights',
                        style: TextStyle(color: Color(0xFFC9A15E), fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Unsave venue',
                onPressed: state.isUpdating(venue.id) ? null : () async {
                  final error = await context.read<SavedVenuesCubit>().setSaved(venue, false);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error ?? 'Venue removed')),
                  );
                },
                icon: state.isUpdating(venue.id)
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
                    : const Icon(Icons.bookmark, color: Color(0xFFE63888)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
