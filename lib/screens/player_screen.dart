import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:vr_player/vr_player.dart';
import '../models/player_state.dart';
import '../models/video_item.dart';
import '../theme/theater_theme.dart';
import '../widgets/player_controls.dart';
import '../widgets/common_widgets.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  VrPlayerController? _vrPlayerController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _initialized = false;
  bool _isUsingVrPlayer = false;
  bool _isVrModeActive = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPlayer();
      context.read<PlayerState>().addListener(_syncController);
      context.read<PlayerState>().addListener(_syncPlayPause);
      context.read<PlayerState>().addListener(_syncVRMode);
    });
  }

  void _syncController() {
    if (!mounted) return;
    final state = context.read<PlayerState>();

    // Sync seek
    if (state.needsSeek) {
      if (_isUsingVrPlayer) {
        if (_vrPlayerController != null) {
          _vrPlayerController!.seekTo(state.position.inMilliseconds);
          state.consumeSeek();
        }
      } else {
        if (_controller != null && _controller!.value.isInitialized) {
          _controller!.seekTo(state.position);
          state.consumeSeek();
        }
      }
    }
  }

  void _syncPlayPause() {
    if (!mounted) return;
    final state = context.read<PlayerState>();

    if (_isUsingVrPlayer) {
      if (state.isPlaying) {
        _vrPlayerController?.play();
      } else {
        _vrPlayerController?.pause();
      }
    } else if (_controller != null) {
      if (state.isPlaying && !_controller!.value.isPlaying) {
        _controller!.play();
      } else if (!state.isPlaying && _controller!.value.isPlaying) {
        _controller!.pause();
      }
    }
  }

  void _syncVRMode() {
    if (!mounted || !_isUsingVrPlayer || _vrPlayerController == null) return;
    final state = context.read<PlayerState>();
    bool wantVR = state.playerMode == PlayerMode.vr || state.playerMode == PlayerMode.split;
    
    if (_isVrModeActive != wantVR) {
      _isVrModeActive = wantVR;
      _vrPlayerController!.toggleVRMode();
    }
  }

  Future<void> _initPlayer() async {    final state = context.read<PlayerState>();
    if (state.currentVideo == null) return;

    final url = state.currentVideo!.videoUrl;
    
    if (state.currentVideo!.type == VideoType.vr360) {
      _isUsingVrPlayer = true;
      setState(() => _initialized = true);
      _fadeController.forward();
      // Ensure the UI knows we want to play initially
      state.setPlaying(true);
      return;
    }

    _isUsingVrPlayer = false;
    if (url.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
      );
    } else {
      _controller = VideoPlayerController.file(
        File(url),
      );
    }

    await _controller!.initialize();
    _controller!.addListener(_onVideoUpdate);

    state.setDuration(_controller!.value.duration);

    setState(() => _initialized = true);
    _fadeController.forward();
    _controller!.play();
    state.setPlaying(true);
  }

  void _onVideoUpdate() {
    if (_controller == null || !mounted) return;
    final state = context.read<PlayerState>();
    // Only update position IF we are playing (to avoid fight with seek)
    if (_controller!.value.isPlaying) {
      state.setPosition(_controller!.value.position);
    }

    if (state.isPlaying != _controller!.value.isPlaying) {
      state.setPlaying(_controller!.value.isPlaying);
    }
  }

  @override
  void dispose() {
    context.read<PlayerState>().removeListener(_syncController);
    context.read<PlayerState>().removeListener(_syncPlayPause);
    context.read<PlayerState>().removeListener(_syncVRMode);
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    _vrPlayerController?.dispose();
    _fadeController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          state.setShowControls(!state.showControls);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video / VR Content
            _buildVideoContent(state),

            // Controls overlay
            PlayerControls(
              onClose: () => Navigator.of(context).pop(),
            ),

            // Loading indicator
            if (!_initialized)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(TheaterTheme.accent),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'LOADING',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 14,
                        letterSpacing: 4,
                        color: TheaterTheme.accent,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent(PlayerState state) {
    if (!_initialized || (_controller == null && !_isUsingVrPlayer)) {
      return Container(color: Colors.black);
    }

    if (state.currentVideo?.type == VideoType.vr360) {
      return _build360View(state);
    }

    switch (state.playerMode) {
      case PlayerMode.vr:
        return _buildVRView(state);
      case PlayerMode.split:
        return _buildSplitView(state);
      case PlayerMode.theater:
        return _buildTheaterView(state);
    }
  }

  Widget _build360View(PlayerState state) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        fit: StackFit.expand,
        children: [
          VrPlayer(
            x: 0,
            y: 0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            onCreated: (VrPlayerController controller, VrPlayerObserver observer) {
              _vrPlayerController = controller;
              observer
                ..onDurationChange = (int duration) {
                  if (mounted) context.read<PlayerState>().setDuration(Duration(milliseconds: duration));
                }
                ..onPositionChange = (int position) {
                  if (mounted) context.read<PlayerState>().setPosition(Duration(milliseconds: position));
                }
                ..onFinishedChange = (bool isFinished) {
                  if (mounted && isFinished) {
                    context.read<PlayerState>().setPlaying(false);
                    context.read<PlayerState>().seekTo(Duration.zero);
                  }
                }
                ..onStateChange = (VrState vrState) {
                  if (mounted && vrState == VrState.ready) {
                    // Sync everything once the player is ready
                    _syncVRMode();
                    _syncPlayPause();
                    _syncController();
                  }
                };
              
              _vrPlayerController?.loadVideo(videoUrl: state.currentVideo!.videoUrl);
            },
          ),
          
          // VR label overlay
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isVrModeActive ? '◉  VR CARDBOARD MODE' : '◉  360° IMMERSIVE VIEW',
                  style: const TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 10,
                    letterSpacing: 2,
                    color: TheaterTheme.accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTheaterView(PlayerState state) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dark film grain background
          Container(color: Colors.black),

          // Theater curtain effect (decorative)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 24,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TheaterTheme.crimson.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 24,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    TheaterTheme.crimson.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),

          // Video player centered
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),

          // Brightness overlay
          IgnorePointer(
            child: Container(
              color: Colors.black
                  .withOpacity(1.0 - state.brightness),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVRView(PlayerState state) {
    // Simulated VR split view
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Row(
            children: [
              // Left eye
              Expanded(
                child: ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildEyeView(isLeft: true),
                      // VR barrel distortion simulation
                      _buildVROverlay(isLeft: true),
                    ],
                  ),
                ),
              ),

              // Center divider
              Container(
                width: 2,
                color: Colors.black,
              ),

              // Right eye
              Expanded(
                child: ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildEyeView(isLeft: false),
                      _buildVROverlay(isLeft: false),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // VR label overlay
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '◉  VR STEREOSCOPIC MODE',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 10,
                    letterSpacing: 2,
                    color: TheaterTheme.accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEyeView({required bool isLeft}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
      ],
    );
  }

  Widget _buildVROverlay({required bool isLeft}) {
    return IgnorePointer(
      child: CustomPaint(
        painter: VRLensPainter(isLeft: isLeft),
      ),
    );
  }

  Widget _buildSplitView(PlayerState state) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          // Left: Video
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.black),
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
                // Label
                Positioned(
                  top: 16,
                  left: 16,
                  child: GoldBadge(label: 'VIDEO'),
                ),
              ],
            ),
          ),

          // Divider
          Container(width: 1, color: TheaterTheme.border),

          // Right: Info panel
          Expanded(
            flex: 2,
            child: _buildInfoPanel(state),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(PlayerState state) {
    final video = state.currentVideo!;
    return Container(
      color: TheaterTheme.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            video.title,
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: TheaterTheme.textPrimary,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.subtitle,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 14,
              color: TheaterTheme.accent,
            ),
          ),
          const SizedBox(height: 16),
          const GoldDivider(),
          const SizedBox(height: 16),
          Text(
            video.description,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 13,
              color: TheaterTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          _InfoRow(label: 'GENRE', value: video.genre),
          const SizedBox(height: 8),
          _InfoRow(label: 'YEAR', value: video.year.toString()),
          _InfoRow(label: 'TYPE', value: video.typeLabel),
          _InfoRow(label: 'RATING', value: '★ ${video.rating}'),
          const Spacer(),
          // VR Settings
          if (video.isVR) ...[
            const Text(
              'VR SETTINGS',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 11,
                letterSpacing: 2,
                color: TheaterTheme.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            _VRSettings(),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
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
      ),
    );
  }
}

class _VRSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'HEAD TRACKING',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 11,
                color: TheaterTheme.textSecondary,
              ),
            ),
            const Spacer(),
            Switch(
              value: state.headTrackingEnabled,
              onChanged: (v) {
                state.toggleHeadTracking();
                // video_360 usually handles sensors automatically or via native code, 
                // but we sync the state just in case future updates allow control.
              },
              activeColor: TheaterTheme.accent,
              inactiveTrackColor: TheaterTheme.border,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'FIELD OF VIEW',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: 11,
            color: TheaterTheme.textSecondary,
          ),
        ),
        Slider(
          value: state.fov,
          min: 60,
          max: 120,
          onChanged: (v) => context.read<PlayerState>().setFov(v),
          label: '${state.fov.round()}°',
        ),
      ],
    );
  }
}

// Custom VR lens effect painter
class VRLensPainter extends CustomPainter {
  final bool isLeft;

  VRLensPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle vignette for lens effect
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.7;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.6),
        ],
        stops: const [0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
