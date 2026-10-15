import 'dart:convert';

enum SupportCategory {
  reservations('Reservations & passes'),
  account('Account & profile'),
  venue('Venue & entry'),
  technical('Technical issue'),
  other('Something else');

  const SupportCategory(this.label);
  final String label;
}

class SupportDraft {
  SupportDraft({
    required this.category,
    required String subject,
    required String message,
    String reservationReference = '',
  }) : subject = subject.trim(),
       message = message.trim(),
       reservationReference = reservationReference.trim();

  final SupportCategory category;
  final String subject;
  final String message;
  final String reservationReference;

  static String? validateSubject(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 5) return 'Enter a subject of at least 5 characters.';
    if (text.length > 120) return 'Keep the subject within 120 characters.';
    return null;
  }

  static String? validateMessage(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 20) return 'Describe your issue in at least 20 characters.';
    if (text.length > 2000) return 'Keep your message within 2,000 characters.';
    return null;
  }

  static String? validateReference(String? value) {
    if ((value ?? '').trim().length > 100) {
      return 'Keep the reference within 100 characters.';
    }
    return null;
  }

  String? get validationError => validateSubject(subject) ??
      validateMessage(message) ?? validateReference(reservationReference);

  Map<String, String> toMap() => {
    'category': category.name,
    'subject': subject,
    'message': message,
    'reservationReference': reservationReference,
  };

  String get fingerprint => jsonEncode(toMap());
}
