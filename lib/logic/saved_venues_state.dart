import 'package:equatable/equatable.dart';

import '../models/saved_venue.dart';

class SavedVenuesState extends Equatable {
  final bool isLoading;
  final bool isReady;
  final String? error;
  final List<SavedVenue> venues;
  final Set<String> updatingIds;

  const SavedVenuesState({
    this.isLoading = true,
    this.isReady = false,
    this.error,
    this.venues = const [],
    this.updatingIds = const {},
  });

  bool isSaved(String venueId) => venues.any((venue) => venue.id == venueId);
  bool isUpdating(String venueId) => updatingIds.contains(venueId);

  @override
  List<Object?> get props => [isLoading, isReady, error, venues, updatingIds];
}
