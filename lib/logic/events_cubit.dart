import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/base_state.dart';
import '../models/event_item.dart';

class EventsCubit extends Cubit<BaseState<List<EventItem>>> {
  EventsCubit() : super(const BaseState());

  Future<void> loadEvents() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      emit(state.copyWith(isLoading: false, data: dummyEvents));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void addEvent(EventItem event) {
    final updated = List<EventItem>.from(state.data ?? []);
    updated.insert(0, event);
    emit(state.copyWith(data: updated));
  }
}