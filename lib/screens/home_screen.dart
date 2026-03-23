import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/video_item.dart';
import '../models/player_state.dart';
import '../theme/theater_theme.dart';
import '../widgets/video_card.dart';
import '../widgets/common_widgets.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() => _isScrolled = _scrollController.offset > 80);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    final filtered = state.getFilteredVideos(demoVideos);

    return Scaffold(
      backgroundColor: TheaterTheme.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: _isScrolled
                ? TheaterTheme.surface.withOpacity(0.95)
                : Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroHeader(),
            ),
            title: _isScrolled
                ? const Text(
                    'CINEMA VR',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 18,
                      letterSpacing: 4,
                      color: TheaterTheme.accent,
                    ),
                  )
                : null,
          ),

          // Genre filter
          SliverToBoxAdapter(
            child: _GenreFilter(),
          ),

          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.selectedGenre == 'All'
                            ? 'CATALOG'
                            : state.selectedGenre.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: TheaterTheme.textPrimary,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const GoldDivider(width: 40),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${filtered.length} TITLES',
                    style: const TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 12,
                      color: TheaterTheme.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid of video cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return VideoCard(
                    video: filtered[index],
                    index: index,
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              DetailScreen(video: filtered[index]),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration:
                              const Duration(milliseconds: 400),
                        ),
                      );
                    },
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  Widget _buildHeroHeader() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF08091F),
                TheaterTheme.background,
              ],
            ),
          ),
        ),

        // Decorative film strips
        const Positioned(
          top: 20,
          left: -20,
          child: _FilmStrip(vertical: true),
        ),
        const Positioned(
          top: 20,
          right: -20,
          child: _FilmStrip(vertical: true),
        ),

        // Content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Logo
              ShaderMask(
                shaderCallback: (bounds) =>
                    TheaterGradients.goldShimmer.createShader(bounds),
                child: const Text(
                  'CINEMA VR',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                    color: Colors.white,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(
                    begin: -0.2,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 8),

              const GoldDivider(width: 120),

              const SizedBox(height: 8),

              const Text(
                'IMMERSIVE • CINEMATIC • VIRTUAL REALITY',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 11,
                  color: TheaterTheme.textMuted,
                  letterSpacing: 3,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
            ],
          ),
        ),

        // Bottom fade
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  TheaterTheme.background,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilmStrip extends StatelessWidget {
  final bool vertical;
  const _FilmStrip({this.vertical = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.06,
      child: Column(
        children: List.generate(
          12,
          (i) => Container(
            width: 40,
            height: 30,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenreFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: genres.length,
        itemBuilder: (context, i) {
          final genre = genres[i];
          final selected = state.selectedGenre == genre;
          return GestureDetector(
            onTap: () => context.read<PlayerState>().setGenre(genre),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10, top: 6, bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? TheaterTheme.accent : TheaterTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected
                      ? TheaterTheme.accent
                      : TheaterTheme.border,
                  width: 1,
                ),
                boxShadow: selected
                    ? [
                        const BoxShadow(
                          color: TheaterTheme.accentGlow,
                          blurRadius: 12,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  genre,
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? TheaterTheme.background
                        : TheaterTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ).animate(delay: (i * 50).ms).fadeIn(duration: 300.ms).slideX(
                  begin: 0.2,
                  curve: Curves.easeOutCubic,
                ),
          );
        },
      ),
    );
  }
}
