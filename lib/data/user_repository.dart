import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserRepository {
  final CollectionReference<Map<String, dynamic>> _col =
  FirebaseFirestore.instance.collection('users');

  Future<AppUser> fetchOrCreate(String uid, String phone) async {
    final doc = await _col.doc(uid).get();

    if (doc.exists) {
      return AppUser.fromMap(uid, doc.data()!);
    }

    final newUser = AppUser(uid: uid, phone: phone, isHost: false);
    await _col.doc(uid).set({
      ...newUser.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return newUser;
  }
}