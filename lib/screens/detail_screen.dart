import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/video_item.dart';
import '../models/player_state.dart';
import '../theme/theater_theme.dart';
import '../widgets/common_widgets.dart';
import 'player_screen.dart';

class DetailScreen extends StatelessWidget {
  final VideoItem video;

  const DetailScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TheaterTheme.background,
      body: CustomScrollView(
        slivers: [
          // Hero image sliver
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: TheaterTheme.surface,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: TheaterTheme.border, width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: TheaterTheme.textPrimary,
                  size: 18,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHero(context),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      if (video.isVR) VRBadge(label: video.typeLabel),
                      if (!video.isVR) GoldBadge(label: video.typeLabel),
                      const SizedBox(width: 10),
                      GoldBadge(label: video.genre),
                      const SizedBox(width: 10),
                      GoldBadge(label: video.year.toString()),
                    ],
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: TheaterTheme.textPrimary,
                      letterSpacing: 4,
                      height: 1.1,
                    ),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),

                  const SizedBox(height: 8),

                  ShaderMask(
                    shaderCallback: (bounds) =>
                        TheaterGradients.goldShimmer.createShader(bounds),
                    child: Text(
                      video.subtitle.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 14,
                        letterSpacing: 3,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 20),

                  // Meta row
                  Row(
                    children: [
                      StarRating(rating: video.rating),
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: TheaterTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        video.durationFormatted,
                        style: const TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 13,
                          color: TheaterTheme.textMuted,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: 24),
                  const GoldDivider(width: 80),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    video.description,
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 15,
                      color: TheaterTheme.textSecondary,
                      height: 1.8,
                      letterSpacing: 0.3,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 32),

                  // Watch buttons
                  _WatchButtons(video: video),

                  const SizedBox(height: 32),

                  // VR info card
                  if (video.isVR) _VRInfoCard(video: video),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          video.thumbnailUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: TheaterTheme.surfaceElevated,
            child: const Icon(
              Icons.movie_outlined,
              color: TheaterTheme.textMuted,
              size: 60,
            ),
          ),
        ),

        // Gradient
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x40000000),
                TheaterTheme.background,
              ],
              stops: [0.4, 1.0],
            ),
          ),
        ),

        // Gold frame lines (theater aesthetic)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: TheaterGradients.goldShimmer,
            ),
          ),
        ),
      ],
    );
  }
}

class _WatchButtons extends StatelessWidget {
  final VideoItem video;
  const _WatchButtons({required this.video});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary: Watch
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: () {
              context.read<PlayerState>().setCurrentVideo(video);
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const PlayerScreen(),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TheaterTheme.accent,
              foregroundColor: TheaterTheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, size: 28),
                SizedBox(width: 8),
                Text(
                  'WATCH NOW',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
        ),

        if (video.isVR) ...[
          const SizedBox(height: 12),

          // VR mode button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                final state = context.read<PlayerState>();
                state.setCurrentVideo(video);
                state.setPlayerMode(PlayerMode.vr);
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const PlayerScreen(),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: TheaterTheme.accent,
                side: const BorderSide(
                    color: TheaterTheme.borderGold, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.vrpano_rounded, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'WATCH IN VR',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
          ),
        ],
      ],
    );
  }
}

class _VRInfoCard extends StatelessWidget {
  final VideoItem video;
  const _VRInfoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      border: Border.all(color: TheaterTheme.borderGold, width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.vrpano_rounded,
                  color: TheaterTheme.accent, size: 20),
              SizedBox(width: 10),
              Text(
                'VR EXPERIENCE',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 13,
                  letterSpacing: 2,
                  color: TheaterTheme.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const GoldDivider(width: 40),
          const SizedBox(height: 12),
          _VRInfoRow(icon: Icons.view_in_ar_rounded, label: 'FORMAT', value: video.typeLabel),
          const SizedBox(height: 8),
          const _VRInfoRow(icon: Icons.headset_rounded, label: 'COMPATIBLE', value: 'All VR Headsets'),
          const SizedBox(height: 8),
          const _VRInfoRow(icon: Icons.rotate_90_degrees_cw_rounded, label: 'HEAD TRACKING', value: 'Gyroscope + Accelerometer'),
          const SizedBox(height: 8),
          const _VRInfoRow(icon: Icons.spatial_audio_rounded, label: 'AUDIO', value: 'Spatial 360°'),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1);
  }
}

class _VRInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _VRInfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: TheaterTheme.textMuted, size: 16),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 11,
              color: TheaterTheme.textMuted,
              letterSpacing: 1,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Raleway',
            fontSize: 12,
            color: TheaterTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
