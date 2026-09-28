import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_item.dart';

class EventsRepository {
  final CollectionReference<Map<String, dynamic>> _col =
  FirebaseFirestore.instance.collection('events');

  Future<List<EventItem>> fetchEvents() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => EventItem.fromMap(d.id, d.data())).toList();
  }

  Future<EventItem> addEvent(EventItem event) async {
    final ref = await _col.add({
      ...event.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return event.copyWith(id: ref.id);
  }

  Future<void> incrementReserved(String eventId, int by) {
    return _col.doc(eventId).update({'reserved': FieldValue.increment(by)});
  }

  // One-time helper to put the dummy events into Firestore
  Future<void> seedIfEmpty() async {
    final existing = await _col.limit(1).get();
    if (existing.docs.isNotEmpty) return;
    for (final e in dummyEvents) {
      await _col.add({...e.toMap(), 'createdAt': FieldValue.serverTimestamp()});
    }
  }
}