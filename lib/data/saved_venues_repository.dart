import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_item.dart';
import '../models/saved_venue.dart';

class SavedVenuesRepository {
  final FirebaseFirestore _db;

  SavedVenuesRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _db.collection('users').doc(uid).collection('saved_venues');

  Stream<List<SavedVenue>> watchForUser(String uid) {
    return _collection(uid).snapshots().map((snapshot) {
      final venues = snapshot.docs
          .map((doc) => SavedVenue.fromMap(doc.id, doc.data()))
          .toList();
      venues.sort((a, b) {
        final order = (b.savedAt?.millisecondsSinceEpoch ?? 0)
            .compareTo(a.savedAt?.millisecondsSinceEpoch ?? 0);
        return order != 0 ? order : a.name.compareTo(b.name);
      });
      return venues;
    });
  }

  Future<void> save(String uid, SavedVenue venue) {
    return _collection(uid).doc(venue.id).set(venue.toMap());
  }

  Future<void> remove(String uid, String venueId) {
    return _collection(uid).doc(venueId).delete();
  }

  // Existing events have no venueId. Match their normalized venue + area.
  // Filter dates in the screen as well so events expire without a DB write.
  Stream<List<EventItem>> watchEventsForVenue(SavedVenue venue) {
    return _db.collection('events').snapshots().map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventItem.fromMap(doc.id, doc.data()))
          .where(venue.matchesEvent)
          .toList();
      events.sort((a, b) => a.eventDateTime.compareTo(b.eventDateTime));
      return events;
    });
  }
}
