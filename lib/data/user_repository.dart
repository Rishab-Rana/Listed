import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  Future<void> completeProfile(String uid, {
    required String name,
    required int age,
    required String gender,
    String? photoUrl,
  }) {
    return _col.doc(uid).update({
      'name': name,
      'age': age,
      'gender': gender,
      'photoUrl': photoUrl,
      'isProfileComplete': true,
    });
  }

  Future<String> uploadProfilePhoto(String uid, File imageFile) async {
    final ref = FirebaseStorage.instance.ref().child('user_profiles/$uid.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }
}