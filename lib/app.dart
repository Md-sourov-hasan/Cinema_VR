import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'models/player_state.dart';
import 'screens/home_screen.dart';
import 'screens/player_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/theater_theme.dart';

class TheaterApp extends StatefulWidget {
  const TheaterApp({super.key});

  @override
  State<TheaterApp> createState() => _TheaterAppState();
}

class _TheaterAppState extends State<TheaterApp> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    _LibraryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TheaterTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _TheaterNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _TheaterNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TheaterNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.theaters_rounded, Icons.theaters_outlined, 'CINEMA'),
      (Icons.bookmark_rounded, Icons.bookmark_outline_rounded, 'LIBRARY'),
      (Icons.settings_rounded, Icons.settings_outlined, 'SETTINGS'),
    ];

    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: TheaterTheme.surface,
        border: const Border(
          top: BorderSide(color: TheaterTheme.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final selected = currentIndex == i;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? TheaterTheme.accentGlow
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      selected ? item.$1 : item.$2,
                      color: selected
                          ? TheaterTheme.accent
                          : TheaterTheme.textMuted,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 9,
                      letterSpacing: 1.5,
                      color: selected
                          ? TheaterTheme.accent
                          : TheaterTheme.textMuted,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                    child: Text(item.$3),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Functional Library screen
class _LibraryScreen extends StatelessWidget {
  const _LibraryScreen();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    final localVideos = state.localVideos;

    return Scaffold(
      backgroundColor: TheaterTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: TheaterTheme.surface.withOpacity(0.95),
            expandedHeight: 120,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'MY LIBRARY',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 18,
                  letterSpacing: 4,
                  color: TheaterTheme.accent,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => state.importLocalVideo(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 24),
                      decoration: BoxDecoration(
                        color: TheaterTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: TheaterTheme.borderGold, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: TheaterTheme.accentGlow,
                            blurRadius: 10,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_to_photos_rounded,
                              color: TheaterTheme.accent),
                          SizedBox(width: 12),
                          Text(
                            'IMPORT LOCAL VIDEO',
                            style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: TheaterTheme.accent,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (localVideos.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.movie_filter_rounded,
                      size: 48,
                      color: TheaterTheme.textMuted,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'NO VIDEOS IMPORTED',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 12,
                        letterSpacing: 2,
                        color: TheaterTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final video = localVideos[index];
                    return GestureDetector(
                      onTap: () {
                        state.setCurrentVideo(video);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PlayerScreen(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: TheaterTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: TheaterTheme.border, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                        'https://picsum.photos/seed/local/400/300'),
                                    fit: BoxFit.cover,
                                    opacity: 0.6,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.play_circle_fill_rounded,
                                      color: TheaterTheme.accent, size: 40),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    video.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: TheaterTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'LOCAL STORAGE',
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 10,
                                      color: TheaterTheme.accent,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: localVideos.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ).animate().fadeIn(duration: 600.ms),
    );
  }
}
