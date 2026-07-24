import 'package:cloud_firestore/cloud_firestore.dart';

class Attempt {
  final String uidLevelId; // formatted as "${uid}_${levelId}"
  final int completionTime; // in seconds
  final int mistakes;
  final int stars; // 1 to 3 stars
  final bool completed;
  final DateTime startedAt;
  final DateTime completedAt;

  const Attempt({
    required this.uidLevelId,
    required this.completionTime,
    required this.mistakes,
    required this.stars,
    required this.completed,
    required this.startedAt,
    required this.completedAt,
  });

  Attempt copyWith({
    String? uidLevelId,
    int? completionTime,
    int? mistakes,
    int? stars,
    bool? completed,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return Attempt(
      uidLevelId: uidLevelId ?? this.uidLevelId,
      completionTime: completionTime ?? this.completionTime,
      mistakes: mistakes ?? this.mistakes,
      stars: stars ?? this.stars,
      completed: completed ?? this.completed,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid_levelId': uidLevelId,
      'completionTime': completionTime,
      'mistakes': mistakes,
      'stars': stars,
      'completed': completed,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  factory Attempt.fromMap(Map<String, dynamic> map) {
    return Attempt(
      uidLevelId: map['uid_levelId'] as String? ?? '',
      completionTime: map['completionTime'] as int? ?? 0,
      mistakes: map['mistakes'] as int? ?? 0,
      stars: map['stars'] as int? ?? 0,
      completed: map['completed'] as bool? ?? false,
      startedAt: _parseDateTime(map['startedAt']),
      completedAt: _parseDateTime(map['completedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }
}
