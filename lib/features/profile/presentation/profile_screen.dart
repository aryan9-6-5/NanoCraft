import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_spacing.dart';
import '../../../shared/widgets/nano_stat_card.dart';
import '../../authentication/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () async {
              try {
                await ref.read(authRepositoryProvider).signOut();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to sign out: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Text('No active profile.', style: theme.textTheme.bodyMedium),
            );
          }

          return SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Avatar
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage: user.photoUrl.isNotEmpty
                        ? NetworkImage(user.photoUrl)
                        : null,
                    child: user.photoUrl.isEmpty
                        ? Icon(Icons.person_rounded, size: 44, color: colorScheme.onSurfaceVariant)
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Username
                Text(user.username, style: theme.textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.xs),

                // Email / Guest badge
                Text(
                  user.isAnonymous ? 'Guest Session' : user.email,
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Stat cards
                Row(
                  children: [
                    NanoStatCard(
                      icon: Icons.brush_rounded,
                      value: '${user.createdLevels}',
                      label: 'Created',
                    ),
                    const SizedBox(width: AppSpacing.md),
                    NanoStatCard(
                      icon: Icons.check_circle_outline_rounded,
                      value: '${user.solvedLevels}',
                      label: 'Solved',
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading profile: $err', style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }
}
