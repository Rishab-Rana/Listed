import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation.dart';

class ReservationsRepository {
  final CollectionReference<Map<String, dynamic>> _col =
  FirebaseFirestore.instance.collection('reservations');

  Future<List<Reservation>> fetchForUser(String userId) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Reservation.fromMap(d.id, d.data())).toList();
  }

  Future<Reservation> addReservation(Reservation reservation) async {
    final ref = await _col.add({
      ...reservation.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return Reservation(
      id: ref.id,
      userId: reservation.userId,
      event: reservation.event,
      type: reservation.type,
      partySize: reservation.partySize,
      leadName: reservation.leadName,
      leadPhone: reservation.leadPhone,
      code: reservation.code,
    );
  }
}