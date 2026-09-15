class GuestReservation {
  final String name;
  final String phone;
  final int size;
  final String type;
  bool checkedIn;

  GuestReservation({
    required this.name,
    required this.phone,
    required this.size,
    required this.type,
    this.checkedIn = false,
  });
}