import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/support_request.dart';

class SupportRepository {
  SupportRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore, _auth = auth;

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;
  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  String newRequestId() => _db.collection('support_request_ids').doc().id;

  Future<String> submit({
    required String uid,
    required String requestId,
    required SupportDraft draft,
  }) async {
    if (uid != currentUserId) throw StateError('Your account changed. Sign in again.');
    final error = draft.validationError;
    if (error != null) throw ArgumentError(error);

    final ref = _db.collection('users').doc(uid)
        .collection('support_requests').doc(requestId);
    // A retried submission uses the same document. Transactions do not queue
    // offline writes, and a late acknowledgement cannot create a second ticket.
    await _db.runTransaction<void>((transaction) async {
      final existing = await transaction.get(ref);
      if (existing.exists) {
        final data = existing.data()!;
        final matches = data['userId'] == uid && draft.toMap().entries.every(
          (entry) => data[entry.key] == entry.value,
        );
        if (!matches) throw StateError('This reference belongs to another request.');
        return;
      }
      transaction.set(ref, {
        'userId': uid,
        ...draft.toMap(),
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
    return requestId;
  }
}
