import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/base_state.dart';
import '../data/reservations_repository.dart';
import '../models/reservation.dart';

class ReservationCubit extends Cubit<BaseState<List<Reservation>>> {
  final ReservationsRepository _repo;
  StreamSubscription<List<Reservation>>? _passesSubscription;
  StreamSubscription<User?>? _authSubscription;
  String? _userId;
  int _generation = 0;
  bool _saving = false;

  ReservationCubit(this._repo) : super(const BaseState(data: [])) {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _userId = null;
        _generation++;
        _passesSubscription?.cancel();
        _passesSubscription = null;
        if (!isClosed) emit(const BaseState(data: []));
      } else if (user.uid != _userId) {
        loadForUser(user.uid);
      }
    });
  }

  Future<void> loadForUser(String userId) async {
    if (_userId == userId && _passesSubscription != null) return;
    _userId = userId;
    final generation = ++_generation;
    emit(const BaseState(isLoading: true, data: []));
    await _passesSubscription?.cancel();
    if (isClosed || generation != _generation) return;
    _passesSubscription = _repo.watchForUser(userId).listen(
      (passes) {
        if (!isClosed && generation == _generation) {
          emit(BaseState(data: passes));
        }
      },
      onError: (Object error) {
        if (!isClosed && generation == _generation) {
          emit(BaseState(error: error.toString(), data: const []));
        }
      },
    );
  }

  Future<bool> addReservation(Reservation reservation) async {
    if (_saving) return false;
    _saving = true;
    final generation = _generation;
    try {
      await _repo.addReservation(reservation);
      // The live query publishes the authoritative result. Avoid inserting
      // another local copy or reviving a reservation after event deletion.
      return !isClosed &&
          generation == _generation &&
          FirebaseAuth.instance.currentUser?.uid == reservation.userId;
    } catch (error) {
      if (!isClosed && generation == _generation) {
        emit(state.copyWith(error: error.toString()));
      }
      return false;
    } finally {
      _saving = false;
    }
  }

  @override
  Future<void> close() async {
    _generation++;
    await _authSubscription?.cancel();
    await _passesSubscription?.cancel();
    return super.close();
  }
}
