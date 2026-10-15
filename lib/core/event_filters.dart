import '../models/event_item.dart';

/// Dates use the same local timezone as the event pickers in this app.
List<EventItem> filterUpcomingEvents(
  List<EventItem> events, {
  required int selectedChip,
  required DateTime now,
}) {
  final upcoming = events
      .where((event) => !event.isDeleting && !event.eventDateTime.isBefore(now))
      .toList()
    ..sort((a, b) => a.eventDateTime.compareTo(b.eventDateTime));

  switch (selectedChip) {
    case 1:
      return upcoming.where((event) =>
          event.eventDateTime.year == now.year &&
          event.eventDateTime.month == now.month &&
          event.eventDateTime.day == now.day).toList();
    case 2:
      final monday = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - DateTime.monday));
      final saturday = monday.add(const Duration(days: 5));
      final nextMonday = monday.add(const Duration(days: 7));
      return upcoming.where((event) =>
          !event.eventDateTime.isBefore(saturday) &&
          event.eventDateTime.isBefore(nextMonday)).toList();
    case 3:
      return upcoming.where((event) => event.guestlistEnabled).toList();
    case 4:
      return upcoming.where((event) => event.tableEnabled).toList();
    default:
      return upcoming;
  }
}
