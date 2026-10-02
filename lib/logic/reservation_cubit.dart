import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/base_state.dart';
import '../data/reservations_repository.dart';
import '../models/reservation.dart';

class ReservationCubit extends Cubit<BaseState<List<Reservation>>> {
  final ReservationsRepository _repo;

  ReservationCubit(this._repo) : super(const BaseState(data: []));

  Future<void> loadForUser(String userId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final reservations = await _repo.fetchForUser(userId);
      emit(state.copyWith(isLoading: false, data: reservations));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addReservation(Reservation reservation) async {
    try {
      final saved = await _repo.addReservation(reservation);
      emit(state.copyWith(data: [saved, ...(state.data ?? [])]));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}