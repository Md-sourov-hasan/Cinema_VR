import 'package:flutter/material.dart';
import '../theme/theater_theme.dart';

class GoldDivider extends StatelessWidget {
  final double width;
  final double height;

  const GoldDivider({super.key, this.width = 60, this.height = 1.5});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: TheaterGradients.goldShimmer,
      ),
    );
  }
}

class GoldBadge extends StatelessWidget {
  final String label;
  final bool filled;

  const GoldBadge({super.key, required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? TheaterTheme.accent : Colors.transparent,
        border: Border.all(
          color: TheaterTheme.accent.withOpacity(0.6),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 10,
          letterSpacing: 1.5,
          color: filled ? TheaterTheme.background : TheaterTheme.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class VRBadge extends StatelessWidget {
  final String label;

  const VRBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TheaterTheme.crimson.withOpacity(0.8),
            TheaterTheme.crimson,
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: TheaterTheme.crimson.withOpacity(0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 10,
          letterSpacing: 1.5,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  const StarRating({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: TheaterTheme.accent, size: 14),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 12,
            color: TheaterTheme.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? color;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? TheaterTheme.surfaceGlass,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: TheaterTheme.border,
              width: 1,
            ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
