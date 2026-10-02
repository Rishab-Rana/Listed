import 'package:flutter/material.dart';
import 'event_item.dart';

class Reservation {
  final String id;
  final String userId;
  final EventItem event;
  final String type;
  final int partySize;
  final String leadName;
  final String leadPhone;
  final String code;

  const Reservation({
    required this.id,
    required this.userId,
    required this.event,
    required this.type,
    required this.partySize,
    required this.leadName,
    required this.leadPhone,
    required this.code,
  });

  factory Reservation.fromMap(String id, Map<String, dynamic> map) {
    final colors = (map['eventGradient'] as List<dynamic>? ?? [])
        .map((c) => Color((c as num).toInt()))
        .toList();

    return Reservation(
      id: id,
      userId: map['userId'] ?? '',
      event: EventItem(
        id: map['eventId'] ?? '',
        title: map['eventTitle'] ?? '',
        venue: map['eventVenue'] ?? '',
        area: map['eventArea'] ?? '',
        date: map['eventDate'] ?? '',
        time: map['eventTime'] ?? '',
        tag: '',
        capacity: 0,
        reserved: 0,
        notes: '',
        gradient: colors.length >= 2
            ? colors
            : const [Color(0xFFE63888), Color(0xFF4A2166)],
      ),
      type: map['type'] ?? 'guestlist',
      partySize: (map['partySize'] as num?)?.toInt() ?? 1,
      leadName: map['leadName'] ?? '',
      leadPhone: map['leadPhone'] ?? '',
      code: map['code'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': event.id,
      'eventTitle': event.title,
      'eventVenue': event.venue,
      'eventArea': event.area,
      'eventDate': event.date,
      'eventTime': event.time,
      'eventGradient': event.gradient.map((c) => c.toARGB32()).toList(),
      'type': type,
      'partySize': partySize,
      'leadName': leadName,
      'leadPhone': leadPhone,
      'code': code,
    };
  }
}