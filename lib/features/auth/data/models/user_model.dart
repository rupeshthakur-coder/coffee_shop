class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phone;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phone,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      name: data['name'],
      phone: data['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
    };
  }
}
