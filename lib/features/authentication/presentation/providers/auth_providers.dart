import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

final currentUserProvider = StreamProvider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) {
    return Stream.value(null);
  }
  
  final repository = ref.watch(authRepositoryProvider);
  // Ensure profile is synced on first stream initialization if needed
  // (In practice, repository sign-in calls syncUserProfile. But if the app restarts,
  // streamUserEntity retrieves the existing profile, and we trigger a background sync of lastLoginAt).
  _backgroundSyncLogin(repository, authState);
  
  return repository.streamUserEntity(authState.uid);
});

final isGuestProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return true;
  return user.isAnonymous;
});

// Sync last login in the background when the app restarts with an active session
void _backgroundSyncLogin(AuthRepository repository, User firebaseUser) async {
  try {
    await repository.syncUserProfile(firebaseUser);
  } catch (e) {
    print('Background login sync failed: $e');
  }
}
