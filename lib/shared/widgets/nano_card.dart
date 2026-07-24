import 'package:flutter/material.dart';
import '../../config/app_spacing.dart';
import '../../config/app_animations.dart';

/// A themed card with subtle press-to-scale animation.
/// Used across Home, Explore, and Profile for consistent surface treatment.
class NanoCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const NanoCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  State<NanoCard> createState() => _NanoCardState();
}

class _NanoCardState extends State<NanoCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      margin: widget.margin ?? EdgeInsets.zero,
      child: Padding(
        padding: widget.padding ?? AppSpacing.cardPadding,
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: card,
      ),
    );
  }
}
