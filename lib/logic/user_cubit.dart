import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/base_state.dart';
import '../data/user_repository.dart';
import '../models/app_user.dart';

class UserCubit extends Cubit<BaseState<AppUser>> {
  final UserRepository _repo;

  UserCubit(this._repo) : super(const BaseState());

  Future<void> loadOrCreate(String uid, String phone) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final user = await _repo.fetchOrCreate(uid, phone);
      emit(state.copyWith(isLoading: false, data: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> completeProfile({
    required String name,
    required int age,
    required String gender,
    String? photoUrl,
  }) async {
    final current = state.data;
    if (current == null) return;

    try {
      await _repo.completeProfile(current.uid, name: name, age: age, gender: gender, photoUrl: photoUrl);
      emit(state.copyWith(data: current.copyWith(
        name: name, age: age, gender: gender, photoUrl: photoUrl, isProfileComplete: true,
      )));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<String> uploadProfilePhoto(File imageFile) async {
    final uid = state.data!.uid;
    return _repo.uploadProfilePhoto(uid, imageFile);
  }
}