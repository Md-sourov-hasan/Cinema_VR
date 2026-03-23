import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/video_item.dart';
import '../models/player_state.dart';
import '../theme/theater_theme.dart';
import 'common_widgets.dart';

class VideoCard extends StatefulWidget {
  final VideoItem video;
  final int index;
  final VoidCallback? onTap;

  const VideoCard({
    super.key,
    required this.video,
    required this.index,
    this.onTap,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          context.read<PlayerState>().setCurrentVideo(widget.video);
          if (widget.onTap != null) widget.onTap!();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _hovered ? -6.0 : 0.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hovered
                    ? TheaterTheme.borderGold
                    : TheaterTheme.border,
                width: 1,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: TheaterTheme.accentGlow,
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 12,
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Expanded(
                    flex: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Thumbnail Image
                        Image.network(
                          widget.video.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  TheaterTheme.surfaceElevated,
                                  TheaterTheme.surface,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.movie_outlined,
                              color: TheaterTheme.textMuted,
                              size: 40,
                            ),
                          ),
                        ),

                        // Gradient overlay
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xCC050810),
                              ],
                            ),
                          ),
                        ),

                        // Top badges
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Row(
                            children: [
                              if (widget.video.isVR)
                                VRBadge(label: widget.video.typeLabel),
                              if (!widget.video.isVR)
                                GoldBadge(label: widget.video.typeLabel),
                            ],
                          ),
                        ),

                        // Duration badge
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.video.durationFormatted,
                              style: const TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 11,
                                color: TheaterTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // Play button on hover
                        if (_hovered)
                          Center(
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: TheaterTheme.accent.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: TheaterTheme.accentGlow,
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: TheaterTheme.background,
                                size: 32,
                              ),
                            ).animate().scale(
                                  duration: 200.ms,
                                  curve: Curves.elasticOut,
                                ),
                          ),
                      ],
                    ),
                  ),

                  // Info
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: TheaterTheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.video.title,
                                style: const TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: TheaterTheme.textPrimary,
                                  letterSpacing: 1.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.video.subtitle,
                                style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 11,
                                  color: TheaterTheme.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StarRating(rating: widget.video.rating),
                              Text(
                                widget.video.genre,
                                style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 10,
                                  color: TheaterTheme.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate(delay: (widget.index * 80).ms).fadeIn(duration: 400.ms).slideY(
              begin: 0.2,
              end: 0,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }
}
