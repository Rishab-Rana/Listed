import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'event_item.dart';

String normalizeVenueText(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

/// A venue is a place, so its identity does not depend on an event/date.
String venueKey(String name, String area) {
  final identity = jsonEncode([
    normalizeVenueText(name),
    normalizeVenueText(area),
  ]);
  return base64Url.encode(utf8.encode(identity)).replaceAll('=', '');
}

class SavedVenue {
  final String id;
  final String name;
  final String area;
  final String? coverImageUrl;
  final String sourceEventId;
  final DateTime? savedAt;

  const SavedVenue({
    required this.id,
    required this.name,
    required this.area,
    this.coverImageUrl,
    this.sourceEventId = '',
    this.savedAt,
  });

  factory SavedVenue.fromEvent(EventItem event) {
    return SavedVenue(
      id: venueKey(event.venue, event.area),
      name: event.venue.trim(),
      area: event.area.trim(),
      coverImageUrl: event.coverImageUrl,
      sourceEventId: event.id,
    );
  }

  factory SavedVenue.fromMap(String id, Map<String, dynamic> data) {
    final timestamp = data['savedAt'];
    return SavedVenue(
      id: id,
      name: data['name'] as String? ?? '',
      area: data['area'] as String? ?? '',
      coverImageUrl: data['coverImageUrl'] as String?,
      sourceEventId: data['sourceEventId'] as String? ?? '',
      savedAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  bool matchesEvent(EventItem event) =>
      id == venueKey(event.venue, event.area);

  Map<String, dynamic> toMap() => {
    'name': name,
    'area': area,
    'coverImageUrl': coverImageUrl,
    'sourceEventId': sourceEventId,
    'savedAt': FieldValue.serverTimestamp(),
  };
}
