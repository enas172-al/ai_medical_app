class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  /// Same as [displayName] in Labby schema; mirrors plan field `name`.
  final String? name;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.name,
    this.photoURL,
    this.createdAt,
    this.lastLogin,
  });

  String? get displayNameOrName => displayName ?? name;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final id = map['uid'] as String? ?? map['userId'] as String? ?? '';
    return UserModel(
      uid: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      name: map['name'] as String? ?? map['displayName'] as String?,
      photoURL: map['photoURL'] as String?,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as dynamic).toDate() as DateTime? : null,
      lastLogin: map['lastLogin'] != null ? (map['lastLogin'] as dynamic).toDate() as DateTime? : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userId': uid,
      'email': email,
      'displayName': displayName,
      'name': name ?? displayName,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }
}
