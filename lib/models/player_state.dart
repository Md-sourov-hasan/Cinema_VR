import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/video_item.dart';

enum PlayerMode { theater, vr, split }

enum VRMode { mono, stereoSideBySide, stereoTopBottom }

class PlayerState extends ChangeNotifier {
  VideoItem? _currentVideo;
  PlayerMode _playerMode = PlayerMode.theater;
  VRMode _vrMode = VRMode.stereoSideBySide;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isMuted = false;
  double _volume = 1.0;
  double _brightness = 0.8;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String _selectedGenre = 'All';
  bool _headTrackingEnabled = true;
  double _fov = 90.0; // Field of view for VR
  List<VideoItem> _localVideos = [];
  bool _needsSeek = false;

  VideoItem? get currentVideo => _currentVideo;
  PlayerMode get playerMode => _playerMode;
  VRMode get vrMode => _vrMode;
  bool get isPlaying => _isPlaying;
  bool get showControls => _showControls;
  bool get isMuted => _isMuted;
  double get volume => _volume;
  double get brightness => _brightness;
  double get playbackSpeed => _playbackSpeed;
  Duration get position => _position;
  Duration get duration => _duration;
  String get selectedGenre => _selectedGenre;
  bool get headTrackingEnabled => _headTrackingEnabled;
  double get fov => _fov;
  List<VideoItem> get localVideos => _localVideos;
  bool get needsSeek => _needsSeek;

  double get progress =>
      _duration.inMilliseconds > 0
          ? _position.inMilliseconds / _duration.inMilliseconds
          : 0.0;

  List<VideoItem> getFilteredVideos(List<VideoItem> all) {
    if (_selectedGenre == 'All') return all;
    if (_selectedGenre == 'VR 360°') return all.where((v) => v.isVR).toList();
    return all.where((v) => v.genre == _selectedGenre).toList();
  }

  void setCurrentVideo(VideoItem video) {
    _currentVideo = video;
    _position = Duration.zero;
    _isPlaying = false;
    // Auto-set mode based on video type
    if (video.isVR) {
      _playerMode = PlayerMode.vr;
    } else {
      _playerMode = PlayerMode.theater;
    }
    notifyListeners();
  }

  void setPlayerMode(PlayerMode mode) {
    _playerMode = mode;
    notifyListeners();
  }

  void setVRMode(VRMode mode) {
    _vrMode = mode;
    notifyListeners();
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void setPlaying(bool playing) {
    _isPlaying = playing;
    notifyListeners();
  }

  void toggleControls() {
    _showControls = !_showControls;
    notifyListeners();
  }

  void setShowControls(bool show) {
    _showControls = show;
    notifyListeners();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void setVolume(double v) {
    _volume = v.clamp(0.0, 1.0);
    _isMuted = _volume == 0;
    notifyListeners();
  }

  void setBrightness(double b) {
    _brightness = b.clamp(0.1, 1.0);
    notifyListeners();
  }

  void setPlaybackSpeed(double s) {
    _playbackSpeed = s;
    notifyListeners();
  }

  void setPosition(Duration pos) {
    _position = pos;
    notifyListeners();
  }

  void seekTo(Duration pos) {
    _position = Duration(
        milliseconds:
            pos.inMilliseconds.clamp(0, _duration.inMilliseconds));
    _needsSeek = true;
    notifyListeners();
  }

  void seek(Duration offset) {
    seekTo(_position + offset);
  }

  void consumeSeek() {
    _needsSeek = false;
  }

  Future<void> importLocalVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final video = VideoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: file.name,
        subtitle: 'Local Video',
        description: 'Imported from device storage',
        thumbnailUrl: '', // Could use a placeholder or generator
        videoUrl: file.path!,
        type: VideoType.flat,
        duration: Duration.zero, // Will be updated on play
        genre: 'Local',
        rating: 0.0,
        year: DateTime.now().year,
        isVR: false,
      );
      _localVideos.add(video);
      notifyListeners();
    }
  }

  void setDuration(Duration dur) {
    _duration = dur;
    notifyListeners();
  }

  void setGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  void toggleHeadTracking() {
    _headTrackingEnabled = !_headTrackingEnabled;
    notifyListeners();
  }

  void setFov(double fov) {
    _fov = fov.clamp(60.0, 120.0);
    notifyListeners();
  }

  String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }
}
