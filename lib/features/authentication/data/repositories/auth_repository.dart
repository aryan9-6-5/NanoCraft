import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Future<UserEntity?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        return await syncUserProfile(firebaseUser);
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
    return null;
  }

  Future<UserEntity?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInAnonymously();
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        return await syncUserProfile(firebaseUser);
      }
    } catch (e) {
      print('Error signing in anonymously: $e');
      rethrow;
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<UserEntity?> syncUserProfile(User firebaseUser) async {
    final docRef = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnap = await docRef.get();
    final now = DateTime.now();

    if (docSnap.exists) {
      // Update lastLoginAt and updatedAt
      final data = docSnap.data()!;
      data['lastLoginAt'] = Timestamp.fromDate(now);
      data['updatedAt'] = Timestamp.fromDate(now);
      
      // Keep isAnonymous in sync with Firebase Auth just in case
      data['isAnonymous'] = firebaseUser.isAnonymous;

      await docRef.update({
        'lastLoginAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'isAnonymous': firebaseUser.isAnonymous,
      });

      return UserEntity.fromMap(data);
    } else {
      // Create new user profile document
      String username;
      if (firebaseUser.isAnonymous) {
        username = _generateGuestUsername();
      } else {
        username = firebaseUser.displayName ?? 'User_${firebaseUser.uid.substring(0, min(firebaseUser.uid.length, 6))}';
      }

      final userEntity = UserEntity(
        uid: firebaseUser.uid,
        username: username,
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL ?? '',
        createdLevels: 0,
        solvedLevels: 0,
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
        isAnonymous: firebaseUser.isAnonymous,
      );

      await docRef.set(userEntity.toMap());
      return userEntity;
    }
  }

  Stream<UserEntity?> streamUserEntity(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((docSnap) {
      if (docSnap.exists && docSnap.data() != null) {
        return UserEntity.fromMap(docSnap.data()!);
      }
      return null;
    });
  }

  String _generateGuestUsername() {
    final random = Random();
    const chars = '0123456789ABCDEF';
    final code = List.generate(4, (index) => chars[random.nextInt(16)]).join();
    return 'Guest_$code';
  }
}
