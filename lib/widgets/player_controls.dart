import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player_state.dart';
import '../theme/theater_theme.dart';
import 'common_widgets.dart';

class PlayerControls extends StatefulWidget {
  final VoidCallback onClose;

  const PlayerControls({super.key, required this.onClose});

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        context.read<PlayerState>().setShowControls(false);
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    if (!state.showControls) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        _resetHideTimer();
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: TheaterGradients.controlBar,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
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
                    const Spacer(),
                    if (state.currentVideo != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            state.currentVideo!.title,
                            style: const TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: TheaterTheme.textPrimary,
                              letterSpacing: 2,
                            ),
                          ),
                          if (state.currentVideo!.isVR)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: VRBadge(
                                  label: state.currentVideo!.typeLabel),
                            ),
                        ],
                      ),
                    const Spacer(),
                    _ModeToggle(),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom controls
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Progress bar
                    _ProgressBar(onChanged: _resetHideTimer),
                    const SizedBox(height: 16),

                    // Main controls row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ControlButton(
                          icon: Icons.replay_10_rounded,
                          onTap: () {
                            _resetHideTimer();
                            context.read<PlayerState>().seek(const Duration(seconds: -10));
                          },
                        ),
                        const SizedBox(width: 20),
                        _PlayButton(),
                        const SizedBox(width: 20),
                        _ControlButton(
                          icon: Icons.forward_10_rounded,
                          onTap: () {
                            _resetHideTimer();
                            context.read<PlayerState>().seek(const Duration(seconds: 10));
                          },
                        ),
                        const Spacer(),
                        _VolumeControl(onChanged: _resetHideTimer),
                        const SizedBox(width: 12),
                        _SpeedControl(onChanged: _resetHideTimer),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    return GestureDetector(
      onTap: () => context.read<PlayerState>().togglePlay(),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: TheaterTheme.accent,
          boxShadow: [
            BoxShadow(
              color: TheaterTheme.accentGlow,
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(
          state.isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: TheaterTheme.background,
          size: 38,
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TheaterTheme.border, width: 1),
        ),
        child: Icon(icon, color: TheaterTheme.textPrimary, size: 24),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final VoidCallback onChanged;
  const _ProgressBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: state.progress,
            onChanged: (v) {
              onChanged();
              final pos = Duration(
                  milliseconds:
                      (v * state.duration.inMilliseconds).round());
              context.read<PlayerState>().seekTo(pos);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.formatDuration(state.position),
                style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  color: TheaterTheme.textSecondary,
                ),
              ),
              Text(
                state.formatDuration(state.duration),
                style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 12,
                  color: TheaterTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VolumeControl extends StatelessWidget {
  final VoidCallback onChanged;
  const _VolumeControl({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    return GestureDetector(
      onTap: () {
        onChanged();
        context.read<PlayerState>().toggleMute();
      },
      child: Icon(
        state.isMuted
            ? Icons.volume_off_rounded
            : state.volume > 0.5
                ? Icons.volume_up_rounded
                : Icons.volume_down_rounded,
        color: TheaterTheme.textPrimary,
        size: 22,
      ),
    );
  }
}

class _SpeedControl extends StatelessWidget {
  final VoidCallback onChanged;
  const _SpeedControl({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    return GestureDetector(
      onTap: () {
        onChanged();
        final idx = speeds.indexOf(state.playbackSpeed);
        final next = speeds[(idx + 1) % speeds.length];
        context.read<PlayerState>().setPlaybackSpeed(next);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TheaterTheme.border, width: 1),
        ),
        child: Text(
          '${state.playbackSpeed}x',
          style: const TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 12,
            color: TheaterTheme.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    return GestureDetector(
      onTap: () {
        final modes = PlayerMode.values;
        final next = modes[(modes.indexOf(state.playerMode) + 1) % modes.length];
        context.read<PlayerState>().setPlayerMode(next);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TheaterTheme.borderGold, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              state.playerMode == PlayerMode.vr
                  ? Icons.vrpano_rounded
                  : state.playerMode == PlayerMode.split
                      ? Icons.splitscreen_rounded
                      : Icons.theaters_rounded,
              color: TheaterTheme.accent,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              state.playerMode == PlayerMode.vr
                  ? 'VR'
                  : state.playerMode == PlayerMode.split
                      ? 'SPLIT'
                      : 'THEATER',
              style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 11,
                color: TheaterTheme.accent,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
