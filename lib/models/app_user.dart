class AppUser {
  final String uid;
  final String phone;
  final bool isHost;
  final String name;
  final int? age;
  final String gender;
  final String? photoUrl;
  final bool isProfileComplete;

  const AppUser({
    required this.uid,
    required this.phone,
    required this.isHost,
    this.name = '',
    this.age,
    this.gender = '',
    this.photoUrl,
    this.isProfileComplete = false,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      phone: map['phone'] ?? '',
      isHost: map['isHost'] ?? false,
      name: map['name'] ?? '',
      age: (map['age'] as num?)?.toInt(),
      gender: map['gender'] ?? '',
      photoUrl: map['photoUrl'],
      isProfileComplete: map['isProfileComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'isHost': isHost,
      'name': name,
      'age': age,
      'gender': gender,
      'photoUrl': photoUrl,
      'isProfileComplete': isProfileComplete,
    };
  }

  AppUser copyWith({String? name, int? age, String? gender, String? photoUrl, bool? isProfileComplete}) {
    return AppUser(
      uid: uid,
      phone: phone,
      isHost: isHost,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}