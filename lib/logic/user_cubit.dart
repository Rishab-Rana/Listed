import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/base_state.dart';
import '../data/user_repository.dart';
import '../models/app_user.dart';

class UserCubit extends Cubit<BaseState<AppUser>> {
  final UserRepository _repo;

  UserCubit(this._repo) : super(const BaseState());

  Future<void> loadOrCreate(String uid, String phone) async {
    emit(BaseState<AppUser>(
      isLoading: true,
      data: state.data?.uid == uid ? state.data : null,
    ));
    try {
      final user = await _repo.fetchOrCreate(uid, phone);
      if (isClosed || FirebaseAuth.instance.currentUser?.uid != uid) return;
      emit(BaseState<AppUser>(data: user));
    } catch (e) {
      if (isClosed || FirebaseAuth.instance.currentUser?.uid != uid) return;
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // The form navigates only when this returns true.
  Future<bool> completeProfile({
    required String name,
    required int age,
    required String gender,
    String? photoUrl,
    File? photo,
  }) async {
    if (state.isLoading) return false;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final current = state.data;
    if (uid == null || current == null || current.uid != uid) {
      emit(state.copyWith(error: 'Your profile could not be loaded. Please sign in again.'));
      return false;
    }
    final cleanName = name.trim();
    if (cleanName.isEmpty || age < 18 || age > 100 ||
        !['Male', 'Female', 'Other'].contains(gender)) {
      emit(state.copyWith(error: 'Enter a name, a valid age (18–100), and gender.'));
      return false;
    }

    emit(state.copyWith(isLoading: true));
    try {
      final savedPhotoUrl = photo != null
          ? await _repo.uploadProfilePhoto(uid, photo)
          : photoUrl ?? current.photoUrl;
      if (FirebaseAuth.instance.currentUser?.uid != uid) {
        throw StateError('Your session changed. Please sign in again.');
      }
      await _repo.completeProfile(uid,
        name: cleanName, age: age, gender: gender, photoUrl: savedPhotoUrl,
      );
      if (isClosed || FirebaseAuth.instance.currentUser?.uid != uid) return false;
      emit(BaseState<AppUser>(data: current.copyWith(
        name: cleanName, age: age, gender: gender,
        photoUrl: savedPhotoUrl, isProfileComplete: true,
      )));
      return true;
    } catch (e) {
      if (!isClosed && FirebaseAuth.instance.currentUser?.uid == uid) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
      return false;
    }
  }

  Future<String> uploadProfilePhoto(File imageFile) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || state.data?.uid != uid) {
      throw StateError('Please sign in before uploading a profile photo.');
    }
    return _repo.uploadProfilePhoto(uid, imageFile);
  }

  void clear() => emit(const BaseState<AppUser>());
}
