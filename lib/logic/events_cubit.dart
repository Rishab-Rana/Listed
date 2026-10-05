import 'dart:io';

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

  Future<void> attachCoverImage(String eventId, File imageFile) async {
    try {
      final url = await _repo.uploadCoverImage(eventId, imageFile);
      await _repo.setCoverImage(eventId, url);
      final updated = (state.data ?? []).map((e) {
        return e.id == eventId ? e.copyWith(coverImageUrl: url) : e;
      }).toList();
      emit(state.copyWith(data: updated));
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

  Future<void> deleteEvent(String eventId) async {
    try {
      await _repo.deleteEvent(eventId);
      final updated = (state.data ?? []).where((e) => e.id != eventId).toList();
      emit(state.copyWith(data: updated));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}