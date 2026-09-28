import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/base_state.dart';
import '../models/reservation.dart';

class ReservationCubit extends Cubit<BaseState<List<Reservation>>> {
  ReservationCubit() : super(const BaseState(data: []));

  void addReservation(Reservation reservation) {
    final updated = List<Reservation>.from(state.data ?? []);
    updated.insert(0, reservation);
    emit(state.copyWith(data: updated));
  }
}