import 'event_item.dart';

class Reservation {
  final EventItem event;
  final String type;
  final int partySize;
  final String leadName;
  final String leadPhone;
  final String code;

  const Reservation({
    required this.event,
    required this.type,
    required this.partySize,
    required this.leadName,
    required this.leadPhone,
    required this.code,
  });
}