class UserEntity {
  final String uid;
  final String? email;
  final String? name;
  final String? phone;

  UserEntity({
    required this.uid,
    this.email,
    this.name,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
    };
  }
}
