class MedicationModel {
  final String? id;
  final String userId;
  final String name;
  final String dosage;
  final List<String> times; // e.g., ["08:00", "20:00"]
  final List<int> daysOfWeek; // e.g., [1, 3, 5] for Mon, Wed, Fri
  final bool isActive;
  final DateTime createdAt;

  MedicationModel({
    this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.times,
    required this.daysOfWeek,
    this.isActive = true,
    required this.createdAt,
  });

  factory MedicationModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicationModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      times: List<String>.from(map['times'] ?? []),
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as dynamic).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'times': times,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
