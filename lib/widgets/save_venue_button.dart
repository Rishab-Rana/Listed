import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/saved_venues_cubit.dart';
import '../logic/saved_venues_state.dart';
import '../models/saved_venue.dart';

class SaveVenueButton extends StatelessWidget {
  final SavedVenue venue;

  const SaveVenueButton({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedVenuesCubit, SavedVenuesState>(
      builder: (context, state) {
        final saved = state.isSaved(venue.id);
        final busy = state.isLoading || state.isUpdating(venue.id);
        final cubit = context.read<SavedVenuesCubit>();
        return IconButton(
          tooltip: state.error != null
              ? 'Retry saved venues'
              : saved ? 'Unsave venue' : 'Save venue',
          onPressed: busy
              ? null
              : state.error != null
                  ? () => cubit.retry()
                  : !state.isReady
                      ? null
                      : () async {
                          final error = await cubit.setSaved(venue, !saved);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(error ?? (saved ? 'Venue removed' : 'Venue saved')),
                          ));
                        },
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.4),
            shape: const CircleBorder(),
          ),
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                )
              : Icon(
                  state.error != null
                      ? Icons.refresh
                      : saved ? Icons.bookmark : Icons.bookmark_border,
                  color: saved ? const Color(0xFFE63888) : Colors.white,
                  size: 22,
                ),
        );
      },
    );
  }
}
