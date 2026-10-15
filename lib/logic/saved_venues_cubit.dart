import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/saved_venues_repository.dart';
import '../models/saved_venue.dart';
import 'saved_venues_state.dart';

class SavedVenuesCubit extends Cubit<SavedVenuesState> {
  final SavedVenuesRepository _repo;
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<SavedVenue>>? _venuesSubscription;
  String? _uid;
  int _generation = 0;

  SavedVenuesCubit(this._repo, {FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        super(const SavedVenuesState()) {
    _authSubscription = _auth.authStateChanges().listen((user) {
      _loadForUser(user?.uid);
    });
  }

  SavedVenuesRepository get repository => _repo;

  Future<void> _loadForUser(String? uid) async {
    if (isClosed) return;
    _uid = uid;
    final generation = ++_generation;
    emit(SavedVenuesState(isLoading: uid != null));
    final previous = _venuesSubscription;
    _venuesSubscription = null;
    await previous?.cancel();
    if (isClosed || generation != _generation || uid == null) return;
    _venuesSubscription = _repo.watchForUser(uid).listen(
      (venues) {
        if (isClosed || generation != _generation) return;
        emit(SavedVenuesState(
          isLoading: false,
          isReady: true,
          venues: List.unmodifiable(venues),
          updatingIds: state.updatingIds,
        ));
      },
      onError: (Object error) {
        if (isClosed || generation != _generation) return;
        emit(SavedVenuesState(
          isLoading: false,
          error: 'Could not load saved venues. Check your connection and retry.',
        ));
      },
    );
  }

  Future<void> retry() => _loadForUser(_auth.currentUser?.uid);

  /// Returns an error message on failure; Firestore's live list drives the UI.
  Future<String?> setSaved(SavedVenue venue, bool shouldSave) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid != _uid) return 'Please sign in again.';
    if (!state.isReady) return 'Saved venues are still loading. Please retry.';
    if (state.isUpdating(venue.id)) return 'This venue is already being updated.';
    if (state.isSaved(venue.id) == shouldSave) return null;
    if (shouldSave && venue.name.trim().isEmpty) return 'This event has no venue name.';

    final generation = _generation;
    void emitUpdating(Set<String> ids) {
      emit(SavedVenuesState(
        isLoading: state.isLoading,
        isReady: state.isReady,
        error: state.error,
        venues: state.venues,
        updatingIds: Set.unmodifiable(ids),
      ));
    }

    emitUpdating({...state.updatingIds, venue.id});
    try {
      final write = shouldSave ? _repo.save(uid, venue) : _repo.remove(uid, venue.id);
      await write.timeout(const Duration(seconds: 20));
      if (generation != _generation || _auth.currentUser?.uid != uid) {
        return 'Your account changed. Please reopen this screen.';
      }
      return null;
    } on TimeoutException {
      // Firestore can queue offline writes; a timeout does not cancel the write.
      return 'Could not confirm the change. Reconnect and check Saved venues.';
    } catch (_) {
      return 'Could not update this venue. Please try again.';
    } finally {
      if (!isClosed && generation == _generation) {
        emitUpdating({...state.updatingIds}..remove(venue.id));
      }
    }
  }

  @override
  Future<void> close() async {
    _generation++;
    await _authSubscription?.cancel();
    await _venuesSubscription?.cancel();
    return super.close();
  }
}
