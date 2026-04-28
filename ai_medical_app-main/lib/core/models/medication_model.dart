class MedicationModel {
  final String? id;
  final String userId;
  final String name;
  final String dosage;
  final List<String> times; // e.g., ["08:00", "20:00"]
  final List<int> daysOfWeek; // e.g., [1, 3, 5] for Mon, Wed, Fri
  /// One of:
  /// - once_daily
  /// - twice_daily_q12h
  /// - three_daily_q8h
  /// - weekly
  /// - monthly
  final String frequency;
  final bool isActive;
  final DateTime createdAt;
  /// Firebase uid of the account that created this record (parent or child).
  final String? enteredByUid;
  final String? enteredByName;
  /// Same values as [UserModel.familyRole]: `guardian` or `dependent`.
  final String? enteredByFamilyRole;

  MedicationModel({
    this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.times,
    required this.daysOfWeek,
    this.frequency = 'once_daily',
    this.isActive = true,
    required this.createdAt,
    this.enteredByUid,
    this.enteredByName,
    this.enteredByFamilyRole,
  });

  static String _inferFrequency(Map<String, dynamic> map) {
    final f = (map['frequency'] ?? '').toString().trim();
    if (f.isNotEmpty) return f;
    final List<dynamic> t = (map['times'] ?? []) as List<dynamic>;
    final n = t.length;
    if (n == 2) return 'twice_daily_q12h';
    if (n == 3) return 'three_daily_q8h';
    return 'once_daily';
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicationModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      times: List<String>.from(map['times'] ?? []),
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
      frequency: _inferFrequency(map),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as dynamic).toDate() : DateTime.now(),
      enteredByUid: map['enteredByUid'] as String?,
      enteredByName: map['enteredByName'] as String?,
      enteredByFamilyRole: map['enteredByFamilyRole'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'times': times,
      'daysOfWeek': daysOfWeek,
      'frequency': frequency,
      'isActive': isActive,
      'createdAt': createdAt,
      if (enteredByUid != null) 'enteredByUid': enteredByUid,
      if (enteredByName != null) 'enteredByName': enteredByName,
      if (enteredByFamilyRole != null) 'enteredByFamilyRole': enteredByFamilyRole,
    };
  }
}
