import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventItem {
  final String id;
  final String title;
  final String venue;
  final String area;
  final DateTime eventDateTime;
  final String tag;
  final int capacity;
  final int reserved;
  final String notes;
  final List<Color> gradient;
  final String? coverImageUrl;
  final bool guestlistEnabled;
  final bool tableEnabled;

  const EventItem({
    required this.id,
    required this.title,
    required this.venue,
    required this.area,
    required this.eventDateTime,
    required this.tag,
    required this.capacity,
    required this.reserved,
    required this.notes,
    required this.gradient,
    this.coverImageUrl,
    this.guestlistEnabled = true,
    this.tableEnabled = true,
  });

  String get date => DateFormat('E, d MMM').format(eventDateTime);
  String get time => DateFormat('h:mm a').format(eventDateTime);
  bool get isPast => eventDateTime.isBefore(DateTime.now());

  factory EventItem.fromMap(String id, Map<String, dynamic> map) {
    final colors = (map['gradient'] as List<dynamic>? ?? [])
        .map((c) => Color((c as num).toInt()))
        .toList();

    final ts = map['eventDateTime'];
    final dateTime = ts is Timestamp ? ts.toDate() : DateTime.now();

    return EventItem(
      id: id,
      title: map['title'] ?? '',
      venue: map['venue'] ?? '',
      area: map['area'] ?? '',
      eventDateTime: dateTime,
      tag: map['tag'] ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
      reserved: (map['reserved'] as num?)?.toInt() ?? 0,
      notes: map['notes'] ?? '',
      gradient: colors.length >= 2 ? colors : const [Color(0xFFE63888), Color(0xFF4A2166)],
      coverImageUrl: map['coverImageUrl'],
      guestlistEnabled: map['guestlistEnabled'] ?? true,
      tableEnabled: map['tableEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'venue': venue,
      'area': area,
      'eventDateTime': Timestamp.fromDate(eventDateTime),
      'tag': tag,
      'capacity': capacity,
      'reserved': reserved,
      'notes': notes,
      'gradient': gradient.map((c) => c.value).toList(),
      'coverImageUrl': coverImageUrl,
      'guestlistEnabled': guestlistEnabled,
      'tableEnabled': tableEnabled,
    };
  }

  EventItem copyWith({String? id, int? reserved, String? coverImageUrl}) {
    return EventItem(
      id: id ?? this.id,
      title: title,
      venue: venue,
      area: area,
      eventDateTime: eventDateTime,
      tag: tag,
      capacity: capacity,
      reserved: reserved ?? this.reserved,
      notes: notes,
      gradient: gradient,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      guestlistEnabled: guestlistEnabled,
      tableEnabled: tableEnabled,
    );
  }
}