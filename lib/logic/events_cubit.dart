import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/base_state.dart';
import '../data/events_repository.dart';
import '../models/event_item.dart';

class EventsCubit extends Cubit<BaseState<List<EventItem>>> {
  final EventsRepository _repo;

  EventsCubit(this._repo) : super(const BaseState());

  Future<void> loadEvents() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final events = await _repo.fetchEvents();
      emit(state.copyWith(isLoading: false, data: events));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addEvent(EventItem event) async {
    try {
      final saved = await _repo.addEvent(event);
      emit(state.copyWith(data: [saved, ...(state.data ?? [])]));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> incrementReserved(String eventId, int by) async {
    try {
      await _repo.incrementReserved(eventId, by);
      final updated = (state.data ?? [])
          .map((e) => e.id == eventId ? e.copyWith(reserved: e.reserved + by) : e)
          .toList();
      emit(state.copyWith(data: updated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}