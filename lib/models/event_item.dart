import 'dart:ui';

class EventItem {
  final String title;
  final String venue;
  final String area;
  final String date;
  final String time;
  final String tag;
  final int capacity;
  final int reserved;
  final String notes;
  final List<Color> gradient;

  const EventItem({
    required this.title,
    required this.venue,
    required this.area,
    required this.date,
    required this.time,
    required this.tag,
    required this.capacity,
    required this.reserved,
    required this.notes,
    required this.gradient,
  });
}

final List<EventItem> dummyEvents = [
  EventItem(title: 'MIDNIGHT HOUR', venue: 'Blackbird Rooftop', tag: 'Guestlist Open', gradient: [const Color(0xFFE63888), const Color(0xFF4A2166)],area: 'Cyber Hub, Gurugram', date: 'Fri, 12 Sep', time: '10:00 PM – 3:00 AM', capacity: 150, reserved: 112, notes: 'Smart casuals only.'),
  EventItem(title: 'NEON TEMPLE', venue: 'Aria Social', tag: 'Tables Filling Fast', gradient: [const Color(0xFFC9A15E), const Color(0xFF5C2144)],area: 'Cyber Hub, Gurugram', date: 'Fri, 12 Sep', time: '10:00 PM – 3:00 AM', capacity: 150, reserved: 112, notes: 'Smart casuals only.'),
  EventItem(title: 'VELVET UNDERGROUND', venue: 'The Hollow', tag: 'Guestlist Open', gradient: [const Color(0xFF7A2E4E), const Color(0xFF1C1430)],area: 'Cyber Hub, Gurugram', date: 'Fri, 12 Sep', time: '10:00 PM – 3:00 AM', capacity: 150, reserved: 112, notes: 'Smart casuals only.'),
];