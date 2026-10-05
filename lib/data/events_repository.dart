import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EventsRepository {
  final CollectionReference<Map<String, dynamic>> _col =
  FirebaseFirestore.instance.collection('events');

  Future<String> uploadCoverImage(String eventId, File imageFile) async {
    final ref = FirebaseStorage.instance.ref().child('event_covers/$eventId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

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

  Future<void> setCoverImage(String eventId, String url) {
    return _col.doc(eventId).update({'coverImageUrl': url});
  }

  Future<void> deleteEvent(String eventId) {
    return _col.doc(eventId).delete();
  }
}