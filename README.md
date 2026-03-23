# 🎭 Cinema VR — Flutter Theater Video Player

A luxurious, immersive **VR Theater Video Player** app built with Flutter. Features a deep cinema noir aesthetic with gold accents, support for 360°/180° VR video, stereoscopic side-by-side playback, gyroscope head tracking, and a full-featured playback controller.

---

## ✨ Features

### 🎬 Player Modes
| Mode | Description |
|------|-------------|
| **Theater** | Classic cinematic view with red curtain edges |
| **VR Stereo** | Side-by-side stereoscopic split for VR headsets |
| **Split View** | Video left + info panel right |

### 📺 Video Format Support
- **360° VR** — Full spherical panoramic video
- **180° VR** — Front hemisphere VR
- **Spatial** — Apple Vision Pro-style spatial content
- **Flat HD** — Standard cinema video

### 🕹️ Playback Controls
- Play / Pause with gold-glow button
- Seek bar with position tracking
- Skip ±10s / +30s
- Playback speed (0.5× – 2.0×)
- Volume with mute toggle
- Brightness overlay control
- Persistent auto-hide overlay

### 🥽 VR Features
- Stereoscopic side-by-side rendering
- Gyroscope + accelerometer head tracking
- Adjustable field of view (60°–120°)
- VR lens vignette effect (barrel distortion simulation)
- Mono / Side-by-Side / Top-Bottom stereo modes
- Landscape lock in VR mode, immersive system UI

### 🎨 Design
- Deep cinema noir aesthetic: `#050810` background
- Gold shimmer title typography (`Cinzel` + `Raleway`)
- Animated entrance transitions (staggered, spring physics)
- Hover lift effects on cards (desktop/tablet)
- Genre filter pill bar
- ShaderMask gold gradient logo
- Film strip decorative motifs on splash screen
- VR lens vignette `CustomPainter`

---

## 🚀 Getting Started

### Prerequisites
- Flutter `>=3.10.0`
- Dart `>=3.0.0`
- Android SDK 21+ or iOS 13+

### Installation

```bash
# Clone or copy the project
cd theater_vr_player

# Install dependencies
flutter pub get

# Add fonts (required — see Fonts section below)
# Then run:
flutter run
```

### Required Fonts

Download and place these in `assets/fonts/`:
- **Cinzel** — https://fonts.google.com/specimen/Cinzel
  - `Cinzel-Regular.ttf`
  - `Cinzel-Bold.ttf`
- **Raleway** — https://fonts.google.com/specimen/Raleway
  - `Raleway-Light.ttf`
  - `Raleway-Regular.ttf`
  - `Raleway-SemiBold.ttf`

Or use the `google_fonts` package as an alternative:
```bash
flutter pub add google_fonts
```
Then replace font references in `TheaterTheme` with `GoogleFonts.cinzel()` etc.

---

## 📁 Project Structure

```
lib/
├── main.dart               # Entry + Splash screen
├── app.dart                # Shell + bottom nav
├── theme/
│   └── theater_theme.dart  # Colors, gradients, ThemeData
├── models/
│   ├── video_item.dart     # VideoItem model + demo catalog
│   └── player_state.dart   # ChangeNotifier state
├── screens/
│   ├── home_screen.dart    # Catalog grid + genre filter
│   ├── detail_screen.dart  # Video detail + watch buttons
│   ├── player_screen.dart  # Full-screen player (Theater/VR/Split)
│   └── settings_screen.dart # VR calibration + prefs
└── widgets/
    ├── video_card.dart      # Animated catalog card
    ├── player_controls.dart # Controls overlay
    └── common_widgets.dart  # GoldDivider, VRBadge, GlassContainer…
```

---

## 🔧 Key Dependencies

| Package | Purpose |
|---------|---------|
| `video_player` | Core video playback engine |
| `chewie` | Player UI scaffold |
| `panorama_viewer` | 360° spherical video rendering |
| `flutter_animate` | Entrance animations (stagger, spring) |
| `provider` | State management |
| `sensors_plus` | Gyroscope for head tracking |
| `wakelock_plus` | Keep screen on during playback |
| `glass_kit` | Frosted glass UI elements |

---

## 🥽 VR Headset Usage

1. Open a VR-tagged video and tap **"Watch in VR"**
2. The app enters **landscape + immersive mode** automatically
3. A center divider creates the stereoscopic split
4. Insert your phone into a **Google Cardboard** or compatible headset
5. Enable **Head Tracking** in Settings for gyroscope look-around
6. Adjust **Field of View** slider (default 90°) to match your headset lens

---

## 🎞️ Adding Your Own Videos

Edit `lib/models/video_item.dart` — add entries to `demoVideos`:

```dart
VideoItem(
  id: '7',
  title: 'MY FILM',
  subtitle: 'Custom Content',
  description: 'Your description here.',
  thumbnailUrl: 'https://your-cdn.com/thumb.jpg',
  videoUrl: 'https://your-cdn.com/video.mp4',  // or local asset path
  type: VideoType.vr360,
  duration: Duration(hours: 1, minutes: 30),
  genre: 'Custom',
  rating: 8.0,
  year: 2025,
  isVR: true,
),
```

For **local files**, use `VideoPlayerController.file(File(path))` in `player_screen.dart`.

---

## 📱 Platform Notes

### Android
- Minimum SDK: 21 (Android 5.0)
- Hardware acceleration enabled in `AndroidManifest.xml`
- Cleartext traffic allowed for demo streams

### iOS
- Minimum iOS 13
- All orientations enabled for VR landscape lock
- Motion usage description for head tracking
- App Transport Security set to allow arbitrary loads (for demo streams — restrict in production)

---

## 🔮 Roadmap

- [ ] Real panorama_viewer integration for true spherical rendering
- [ ] Local file picker
- [ ] Download for offline playback
- [ ] Cast to Chromecast / AirPlay
- [ ] Subtitle support (SRT/VTT)
- [ ] Spatial audio (binaural)
- [ ] Watch party sync
- [ ] Apple Vision Pro visionOS support

---

## 📄 License

MIT © 2025 Cinema VR
