import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/player_state.dart';
import '../theme/theater_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();

    return Scaffold(
      backgroundColor: TheaterTheme.background,
      appBar: AppBar(
        backgroundColor: TheaterTheme.surface,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 18,
            letterSpacing: 4,
            color: TheaterTheme.accent,
          ),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: TheaterTheme.textPrimary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: TheaterGradients.goldShimmer,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SectionHeader(title: 'VR EXPERIENCE'),

          _SettingCard(
            child: Column(
              children: [
                _SliderRow(
                  icon: Icons.view_in_ar_rounded,
                  label: 'Field of View',
                  value: state.fov,
                  min: 60,
                  max: 120,
                  unit: '°',
                  onChanged: (v) => context.read<PlayerState>().setFov(v),
                ),
                _Divider(),
                _SwitchRow(
                  icon: Icons.screen_rotation_rounded,
                  label: 'Head Tracking',
                  value: state.headTrackingEnabled,
                  onChanged: (_) =>
                      context.read<PlayerState>().toggleHeadTracking(),
                ),
                _Divider(),
                _VRModeSelector(),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const _SectionHeader(title: 'PLAYBACK'),

          _SettingCard(
            child: Column(
              children: [
                _SliderRow(
                  icon: Icons.brightness_6_rounded,
                  label: 'Brightness',
                  value: state.brightness,
                  min: 0.1,
                  max: 1.0,
                  unit: '%',
                  onChanged: (v) => context.read<PlayerState>().setBrightness(v),
                  displayValue: '${(state.brightness * 100).round()}',
                ),
                _Divider(),
                _SliderRow(
                  icon: Icons.volume_up_rounded,
                  label: 'Volume',
                  value: state.volume,
                  min: 0.0,
                  max: 1.0,
                  unit: '%',
                  onChanged: (v) => context.read<PlayerState>().setVolume(v),
                  displayValue: '${(state.volume * 100).round()}',
                ),
                _Divider(),
                _SpeedSelector(),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const _SectionHeader(title: 'DISPLAY'),

          _SettingCard(
            child: Column(
              children: [
                _PlayerModeSelector(),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // About
          Center(
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (b) =>
                      TheaterGradients.goldShimmer.createShader(b),
                  child: const Text(
                    'CINEMA VR',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Version 1.0.0  •  Flutter Edition',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 12,
                    color: TheaterTheme.textMuted,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 11,
              letterSpacing: 3,
              color: TheaterTheme.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Divider(color: TheaterTheme.border, height: 1),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;
  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TheaterTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TheaterTheme.border, width: 1),
      ),
      child: child,
    );
  }
}

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final String? displayValue;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
    this.displayValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: TheaterTheme.accent, size: 18),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  color: TheaterTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${displayValue ?? value.toStringAsFixed(0)}$unit',
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 12,
                  color: TheaterTheme.accent,
                ),
              ),
            ],
          ),
          Slider(value: value, min: min, max: max, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: TheaterTheme.accent, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 14,
              color: TheaterTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: TheaterTheme.accent,
            inactiveTrackColor: TheaterTheme.border,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: TheaterTheme.border,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}

class _VRModeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    final modes = [
      (VRMode.mono, 'Mono', Icons.crop_square_rounded),
      (VRMode.stereoSideBySide, 'Side by Side', Icons.splitscreen_rounded),
      (VRMode.stereoTopBottom, 'Top/Bottom', Icons.table_rows_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.vrpano_rounded, color: TheaterTheme.accent, size: 18),
              SizedBox(width: 12),
              Text(
                'VR Stereo Mode',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  color: TheaterTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: modes.map((m) {
              final selected = state.vrMode == m.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      context.read<PlayerState>().setVRMode(m.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? TheaterTheme.accent.withOpacity(0.15)
                          : TheaterTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? TheaterTheme.accent
                            : TheaterTheme.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          m.$3,
                          color: selected
                              ? TheaterTheme.accent
                              : TheaterTheme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.$2,
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 10,
                            color: selected
                                ? TheaterTheme.accent
                                : TheaterTheme.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SpeedSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed_rounded, color: TheaterTheme.accent, size: 18),
              SizedBox(width: 12),
              Text(
                'Playback Speed',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  color: TheaterTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: speeds.map((s) {
              final selected = state.playbackSpeed == s;
              return GestureDetector(
                onTap: () =>
                    context.read<PlayerState>().setPlaybackSpeed(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? TheaterTheme.accent : TheaterTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          selected ? TheaterTheme.accent : TheaterTheme.border,
                    ),
                  ),
                  child: Text(
                    '${s}x',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 12,
                      color: selected
                          ? TheaterTheme.background
                          : TheaterTheme.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PlayerModeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerState>();
    final modes = [
      (PlayerMode.theater, 'Theater', Icons.theaters_rounded),
      (PlayerMode.vr, 'VR Mode', Icons.vrpano_rounded),
      (PlayerMode.split, 'Split', Icons.splitscreen_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.display_settings_rounded, color: TheaterTheme.accent, size: 18),
              SizedBox(width: 12),
              Text(
                'Default Player Mode',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  color: TheaterTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: modes.map((m) {
              final selected = state.playerMode == m.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      context.read<PlayerState>().setPlayerMode(m.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? TheaterTheme.accent.withOpacity(0.15)
                          : TheaterTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? TheaterTheme.accent
                            : TheaterTheme.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          m.$3,
                          color: selected
                              ? TheaterTheme.accent
                              : TheaterTheme.textMuted,
                          size: 22,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          m.$2,
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 11,
                            color: selected
                                ? TheaterTheme.accent
                                : TheaterTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
