class AppUser {
  final String uid;
  final String phone;
  final bool isHost;

  const AppUser({
    required this.uid,
    required this.phone,
    required this.isHost,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      phone: map['phone'] ?? '',
      isHost: map['isHost'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'isHost': isHost,
    };
  }
}