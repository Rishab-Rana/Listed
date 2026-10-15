import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_item.dart';
import '../models/reservation.dart';

class ReservationsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('reservations');

  /// Join live reservations with live events. A copied event title in a
  /// reservation never makes a deleted event valid.
  Stream<List<Reservation>> watchForUser(String userId) {
    late final StreamController<List<Reservation>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? reservationsSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? eventsSub;
    QuerySnapshot<Map<String, dynamic>>? reservations;
    QuerySnapshot<Map<String, dynamic>>? events;

    void publish() {
      if (controller.isClosed || reservations == null || events == null) return;
      final currentEvents = {
        for (final doc in events!.docs)
          doc.id: EventItem.fromMap(doc.id, doc.data()),
      };
      final docs = [...reservations!.docs]
        ..sort((a, b) => _createdAt(b.data()).compareTo(_createdAt(a.data())));
      final passes = <Reservation>[];
      for (final doc in docs) {
        final reservation = Reservation.fromMap(doc.id, doc.data());
        final event = currentEvents[reservation.event.id];
        if (event != null && !event.isDeleting) {
          passes.add(reservation.withEvent(event));
        }
      }
      controller.add(passes);
    }

    void reportError(Object error, StackTrace stackTrace) {
      if (!controller.isClosed) controller.addError(error, stackTrace);
    }

    controller = StreamController<List<Reservation>>(
      onListen: () {
        reservationsSub = _col
            .where('userId', isEqualTo: userId)
            .snapshots()
            .listen((snapshot) {
          reservations = snapshot;
          publish();
        }, onError: reportError);
        eventsSub = _db.collection('events').snapshots().listen((snapshot) {
          events = snapshot;
          publish();
        }, onError: reportError);
      },
      onCancel: () async {
        await reservationsSub?.cancel();
        await eventsSub?.cancel();
      },
    );
    return controller.stream;
  }

  int _createdAt(Map<String, dynamic> data) {
    final timestamp = data['createdAt'];
    return timestamp is Timestamp ? timestamp.microsecondsSinceEpoch : 0;
  }

  Future<List<Reservation>> fetchForUser(String userId) {
    return watchForUser(userId).first;
  }

  /// Checking the event and incrementing reserved happen atomically with
  /// creation. A concurrent event deletion causes this transaction to retry.
  Future<Reservation> addReservation(Reservation reservation) async {
    final reservationRef = _col.doc();
    final eventRef = _db.collection('events').doc(reservation.event.id);
    return _db.runTransaction<Reservation>((transaction) async {
      final snapshot = await transaction.get(eventRef);
      if (!snapshot.exists || snapshot.data()?['deleting'] == true) {
        throw StateError('This event is no longer available.');
      }
      final event = EventItem.fromMap(snapshot.id, snapshot.data()!);
      if (event.isPast) {
        throw StateError('This event has already started.');
      }
      final linked = reservation.withEvent(event);
      transaction.set(reservationRef, {
        ...linked.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.update(eventRef, {
        'reserved': FieldValue.increment(reservation.partySize),
      });
      return Reservation(
        id: reservationRef.id,
        userId: linked.userId,
        event: event,
        type: linked.type,
        partySize: linked.partySize,
        leadName: linked.leadName,
        leadPhone: linked.leadPhone,
        code: linked.code,
        checkedIn: linked.checkedIn,
      );
    });
  }

  Future<List<Reservation>> fetchForEvent(String eventId) async {
    final snap = await _col.where('eventId', isEqualTo: eventId).get();
    return snap.docs.map((d) => Reservation.fromMap(d.id, d.data())).toList();
  }

  Future<void> setCheckedIn(String reservationId, bool value) {
    return _col.doc(reservationId).update({'checkedIn': value});
  }
}
