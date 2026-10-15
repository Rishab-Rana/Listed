import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/base_state.dart';
import '../data/support_repository.dart';
import '../models/support_request.dart';

class SupportCubit extends Cubit<BaseState<String>> {
  SupportCubit(this._repository) : super(const BaseState<String>());
  final SupportRepository _repository;
  String? _requestId;
  String? _fingerprint;
  String? _uid;

  Future<void> submit(SupportDraft draft) async {
    if (isClosed || state.isLoading || state.data != null) return;
    final error = draft.validationError;
    if (error != null) {
      emit(BaseState<String>(error: error));
      return;
    }
    final uid = _repository.currentUserId;
    if (uid == null) {
      emit(const BaseState<String>(error: 'Please sign in again before sending a request.'));
      return;
    }
    emit(const BaseState<String>(isLoading: true));
    try {
      if (_uid != uid || _fingerprint != draft.fingerprint || _requestId == null) {
        _requestId = _repository.newRequestId();
        _fingerprint = draft.fingerprint;
        _uid = uid;
      }
      final reference = await _repository.submit(
        uid: uid, requestId: _requestId!, draft: draft,
      );
      if (isClosed) return;
      if (_repository.currentUserId != uid) {
        emit(const BaseState<String>(error: 'Your account changed. Reopen Help & support.'));
        return;
      }
      emit(BaseState<String>(data: reference));
    } on FirebaseException catch (error) {
      if (!isClosed) emit(BaseState<String>(error: _firebaseMessage(error.code)));
    } on TimeoutException {
      if (!isClosed) emit(const BaseState<String>(
        error: 'Could not confirm your request. Reconnect and retry with the same details.',
      ));
    } catch (_) {
      if (!isClosed) emit(const BaseState<String>(
        error: 'Could not send your request. Please check your connection and retry.',
      ));
    }
  }

  String _firebaseMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Support is currently unavailable for this account. Please try again later.';
      case 'unauthenticated':
        return 'Please sign in again before sending a request.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Could not confirm your request. Reconnect and retry with the same details.';
      default:
        return 'Could not send your request. Please try again.';
    }
  }
}
