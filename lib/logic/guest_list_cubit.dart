import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/base_state.dart';
import '../data/reservations_repository.dart';
import '../models/reservation.dart';

class GuestListCubit extends Cubit<BaseState<List<Reservation>>> {
  final ReservationsRepository _repo;

  GuestListCubit(this._repo) : super(const BaseState());

  Future<void> loadForEvent(String eventId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final guests = await _repo.fetchForEvent(eventId);
      emit(state.copyWith(isLoading: false, data: guests));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> toggleCheckIn(String reservationId, bool currentValue) async {
    try {
      await _repo.setCheckedIn(reservationId, !currentValue);
      final updated = (state.data ?? []).map((r) {
        if (r.id == reservationId) {
          return Reservation(
            id: r.id, userId: r.userId, event: r.event, type: r.type,
            partySize: r.partySize, leadName: r.leadName, leadPhone: r.leadPhone,
            code: r.code, checkedIn: !currentValue,
          );
        }
        return r;
      }).toList();
      emit(state.copyWith(data: updated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}