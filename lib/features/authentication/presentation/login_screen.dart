import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_spacing.dart';
import '../../../config/app_animations.dart';
import '../../../shared/widgets/nano_button.dart';
import 'providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.emphasizedCurve,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(_fadeAnimation);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to sign in with Google. Please try again.';
      });
    }
  }

  Future<void> _handleGuestSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).signInAnonymously();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to continue as Guest. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App icon
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.grid_on_rounded,
                            size: 56,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Title
                        Text(
                          'NanoCraft',
                          style: theme.textTheme.displayMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Subtitle
                        Text(
                          'Create, Share & Solve Nonogram Puzzles',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Error message
                        if (_errorMessage != null) ...[
                          Container(
                            width: double.infinity,
                            padding: AppSpacing.cardPadding,
                            decoration: BoxDecoration(
                              color: colorScheme.error.withOpacity(0.08),
                              borderRadius: AppSpacing.borderRadiusMd,
                              border: Border.all(
                                color: colorScheme.error.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        // Sign in button
                        NanoButton(
                          label: 'Sign in with Google',
                          icon: Icons.login_rounded,
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Guest button
                        NanoButton(
                          label: 'Continue as Guest',
                          variant: NanoButtonVariant.text,
                          onPressed: _isLoading ? null : _handleGuestSignIn,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
