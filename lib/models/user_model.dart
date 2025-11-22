class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final bool isRegistered;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.isRegistered = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      isRegistered: map['isRegistered'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isRegistered': isRegistered,
    };
  }
}
