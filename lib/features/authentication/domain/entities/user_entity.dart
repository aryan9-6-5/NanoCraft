import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  final String uid;
  final String username;
  final String email;
  final String photoUrl;
  final int createdLevels;
  final int solvedLevels;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLoginAt;
  final bool isAnonymous;

  const UserEntity({
    required this.uid,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.createdLevels,
    required this.solvedLevels,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
    required this.isAnonymous,
  });

  UserEntity copyWith({
    String? uid,
    String? username,
    String? email,
    String? photoUrl,
    int? createdLevels,
    int? solvedLevels,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isAnonymous,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdLevels: createdLevels ?? this.createdLevels,
      solvedLevels: solvedLevels ?? this.solvedLevels,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'createdLevels': createdLevels,
      'solvedLevels': solvedLevels,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isAnonymous': isAnonymous,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map['uid'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      createdLevels: map['createdLevels'] as int? ?? 0,
      solvedLevels: map['solvedLevels'] as int? ?? 0,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      lastLoginAt: _parseDateTime(map['lastLoginAt']),
      isAnonymous: map['isAnonymous'] as bool? ?? false,
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
