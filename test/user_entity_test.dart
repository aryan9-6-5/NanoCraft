import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanocraft/features/authentication/domain/entities/user_entity.dart';

void main() {
  group('UserEntity Serialization Tests', () {
    final now = DateTime.now();

    final testMap = {
      'uid': 'test_uid_123',
      'username': 'Test User',
      'email': 'test@nanocraft.app',
      'photoUrl': 'https://example.com/photo.png',
      'createdLevels': 5,
      'solvedLevels': 12,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'lastLoginAt': Timestamp.fromDate(now),
      'isAnonymous': false,
    };

    test('fromMap parses successfully', () {
      final user = UserEntity.fromMap(testMap);

      expect(user.uid, 'test_uid_123');
      expect(user.username, 'Test User');
      expect(user.email, 'test@nanocraft.app');
      expect(user.photoUrl, 'https://example.com/photo.png');
      expect(user.createdLevels, 5);
      expect(user.solvedLevels, 12);
      expect(user.isAnonymous, false);
      expect(user.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(user.updatedAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(user.lastLoginAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('toMap converts successfully', () {
      final user = UserEntity(
        uid: 'test_uid_123',
        username: 'Test User',
        email: 'test@nanocraft.app',
        photoUrl: 'https://example.com/photo.png',
        createdLevels: 5,
        solvedLevels: 12,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
        isAnonymous: false,
      );

      final map = user.toMap();

      expect(map['uid'], 'test_uid_123');
      expect(map['username'], 'Test User');
      expect(map['email'], 'test@nanocraft.app');
      expect(map['photoUrl'], 'https://example.com/photo.png');
      expect(map['createdLevels'], 5);
      expect(map['solvedLevels'], 12);
      expect(map['isAnonymous'], false);
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate().millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('copyWith works correctly', () {
      final user = UserEntity(
        uid: 'test_uid_123',
        username: 'Test User',
        email: 'test@nanocraft.app',
        photoUrl: 'https://example.com/photo.png',
        createdLevels: 5,
        solvedLevels: 12,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
        isAnonymous: false,
      );

      final updatedUser = user.copyWith(username: 'Updated Username', solvedLevels: 15);

      expect(updatedUser.uid, 'test_uid_123');
      expect(updatedUser.username, 'Updated Username');
      expect(updatedUser.solvedLevels, 15);
      expect(updatedUser.createdLevels, 5);
    });
  });
}
