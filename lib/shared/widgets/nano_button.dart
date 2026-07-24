import 'package:flutter/material.dart';
import '../../config/app_spacing.dart';
import '../../config/app_animations.dart';

/// Primary action button with optional loading state, icon, and subtle press animation.
/// Replaces all ad-hoc ElevatedButton.styleFrom(...) patterns across the app.
class NanoButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final NanoButtonVariant variant;
  final double? width;

  const NanoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = NanoButtonVariant.primary,
    this.width,
  });

  @override
  State<NanoButton> createState() => _NanoButtonState();
}

enum NanoButtonVariant { primary, outlined, text }

class _NanoButtonState extends State<NanoButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    Widget buttonChild = widget.isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.variant == NanoButtonVariant.primary
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(widget.label),
            ],
          );

    Widget button;
    switch (widget.variant) {
      case NanoButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : widget.onPressed,
          child: buttonChild,
        );
        break;
      case NanoButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isDisabled ? null : widget.onPressed,
          child: buttonChild,
        );
        break;
      case NanoButtonVariant.text:
        button = TextButton(
          onPressed: isDisabled ? null : widget.onPressed,
          child: buttonChild,
        );
        break;
    }

    if (widget.width != null) {
      button = SizedBox(width: widget.width, child: button);
    }

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _scaleController.forward(),
      onTapUp: isDisabled ? null : (_) => _scaleController.reverse(),
      onTapCancel: isDisabled ? null : () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: button,
      ),
    );
  }
}
