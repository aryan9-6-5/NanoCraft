import 'package:cloud_firestore/cloud_firestore.dart';

class Level {
  final String levelId;
  final String creatorId;
  final String title;
  final String type; // 'image' or 'text'
  final int gridSize; // 10 or 15
  final String difficulty; // 'easy', 'medium', 'hard', 'expert'
  final double difficultyScore;
  final int likes;
  final int plays;
  final List<String> tags;
  final DateTime createdAt;

  const Level({
    required this.levelId,
    required this.creatorId,
    required this.title,
    required this.type,
    required this.gridSize,
    required this.difficulty,
    required this.difficultyScore,
    required this.likes,
    required this.plays,
    required this.tags,
    required this.createdAt,
  });

  Level copyWith({
    String? levelId,
    String? creatorId,
    String? title,
    String? type,
    int? gridSize,
    String? difficulty,
    double? difficultyScore,
    int? likes,
    int? plays,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return Level(
      levelId: levelId ?? this.levelId,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      type: type ?? this.type,
      gridSize: gridSize ?? this.gridSize,
      difficulty: difficulty ?? this.difficulty,
      difficultyScore: difficultyScore ?? this.difficultyScore,
      likes: likes ?? this.likes,
      plays: plays ?? this.plays,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'creatorId': creatorId,
      'title': title,
      'type': type,
      'gridSize': gridSize,
      'difficulty': difficulty,
      'difficultyScore': difficultyScore,
      'likes': likes,
      'plays': plays,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Level.fromMap(Map<String, dynamic> map) {
    return Level(
      levelId: map['levelId'] as String? ?? '',
      creatorId: map['creatorId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      type: map['type'] as String? ?? 'image',
      gridSize: map['gridSize'] as int? ?? 15,
      difficulty: map['difficulty'] as String? ?? 'easy',
      difficultyScore: (map['difficultyScore'] as num?)?.toDouble() ?? 0.0,
      likes: map['likes'] as int? ?? 0,
      plays: map['plays'] as int? ?? 0,
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: _parseDateTime(map['createdAt']),
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
