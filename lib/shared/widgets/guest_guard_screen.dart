import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_spacing.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';
import 'nano_button.dart';

/// Blocks guest users with a sign-in prompt.
/// Uses the app's theme system for all styling.
class GuestGuardScreen extends ConsumerStatefulWidget {
  final String message;

  const GuestGuardScreen({
    super.key,
    this.message = 'You must be signed in to create and publish puzzles.',
  });

  @override
  ConsumerState<GuestGuardScreen> createState() => _GuestGuardScreenState();
}

class _GuestGuardScreenState extends ConsumerState<GuestGuardScreen> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to redirect to login: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Sign In Required',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            NanoButton(
              label: 'Sign in with Google',
              icon: Icons.login_rounded,
              onPressed: _isLoading ? null : _handleSignIn,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
