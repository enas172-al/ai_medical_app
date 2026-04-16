class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  /// Same as [displayName] in Labby schema; mirrors plan field `name`.
  final String? name;
  final String? photoURL;
  /// `guardian` = parent/guardian account, `dependent` = linked family member (e.g. child).
  final String? familyRole;
  /// Invite code generated for guardians (shared with family).
  final String? familyCode;
  /// Set for dependents: Firebase uid of the guardian account.
  final String? guardianUid;
  /// Raw code the dependent used when linking (normalized uppercase in Firestore).
  final String? linkedFamilyCode;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.name,
    this.photoURL,
    this.familyRole,
    this.familyCode,
    this.guardianUid,
    this.linkedFamilyCode,
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
      familyRole: map['familyRole'] as String?,
      familyCode: map['familyCode'] as String?,
      guardianUid: map['guardianUid'] as String?,
      linkedFamilyCode: map['linkedFamilyCode'] as String?,
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
      if (familyRole != null) 'familyRole': familyRole,
      if (familyCode != null) 'familyCode': familyCode,
      if (guardianUid != null) 'guardianUid': guardianUid,
      if (linkedFamilyCode != null) 'linkedFamilyCode': linkedFamilyCode,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }
}
