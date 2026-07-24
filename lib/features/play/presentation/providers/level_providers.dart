import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/puzzle.dart';

/// Streams the list of all published levels from Firestore sorted by creation date.
final levelsStreamProvider = StreamProvider<List<Level>>((ref) {
  return FirebaseFirestore.instance
      .collection('levels')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => Level.fromMap(doc.data())).toList());
});

/// Fetches metadata for a single level.
final levelDetailsProvider = FutureProvider.family<Level?, String>((ref, levelId) async {
  final doc = await FirebaseFirestore.instance.collection('levels').doc(levelId).get();
  if (!doc.exists || doc.data() == null) return null;
  return Level.fromMap(doc.data()!);
});

/// Fetches puzzle solution and clues for a single level.
final puzzleDetailsProvider = FutureProvider.family<Puzzle?, String>((ref, levelId) async {
  final doc = await FirebaseFirestore.instance.collection('puzzles').doc(levelId).get();
  if (!doc.exists || doc.data() == null) return null;
  return Puzzle.fromMap(doc.data()!);
});
