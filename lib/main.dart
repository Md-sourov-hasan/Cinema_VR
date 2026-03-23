import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/player_state.dart';
import 'theme/theater_theme.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: TheaterTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CinemaVRApp());
}

class CinemaVRApp extends StatelessWidget {
  const CinemaVRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerState(),
      child: MaterialApp(
        title: 'Cinema VR',
        theme: TheaterTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const TheaterApp(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TheaterTheme.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Spotlight background
              Center(
                child: Opacity(
                  opacity: _glowAnim.value * 0.3,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: TheaterGradients.spotlightGold,
                    ),
                  ),
                ),
              ),

              // Film strip decoration (top)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.05,
                  child: _buildFilmStrip(horizontal: true),
                ),
              ),

              // Film strip decoration (bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.05,
                  child: _buildFilmStrip(horizontal: true),
                ),
              ),

              // Center content
              Center(
                child: Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: TheaterTheme.accent.withOpacity(0.6),
                              width: 1.5,
                            ),
                            color: TheaterTheme.accentGlow,
                            boxShadow: [
                              BoxShadow(
                                color: TheaterTheme.accentGlow,
                                blurRadius: 40 * _glowAnim.value,
                                spreadRadius: 10 * _glowAnim.value,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.vrpano_rounded,
                            color: TheaterTheme.accent,
                            size: 48,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              TheaterGradients.goldShimmer.createShader(bounds),
                          child: const Text(
                            'CINEMA VR',
                            style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: 120,
                          height: 1.5,
                          decoration: const BoxDecoration(
                            gradient: TheaterGradients.goldShimmer,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'THE IMMERSIVE THEATER EXPERIENCE',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 10,
                            letterSpacing: 3,
                            color: TheaterTheme.textMuted,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilmStrip({required bool horizontal}) {
    return SizedBox(
      height: 36,
      child: Row(
        children: List.generate(
          30,
          (i) => Container(
            width: 40,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
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
