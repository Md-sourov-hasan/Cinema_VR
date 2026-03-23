enum VideoType { flat, vr360, vr180, spatial }

class VideoItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final VideoType type;
  final Duration duration;
  final String genre;
  final double rating;
  final int year;
  final bool isVR;
  final String? trailer;

  const VideoItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.type,
    required this.duration,
    required this.genre,
    required this.rating,
    required this.year,
    required this.isVR,
    this.trailer,
  });

  String get typeLabel {
    switch (type) {
      case VideoType.vr360:
        return '360° VR';
      case VideoType.vr180:
        return '180° VR';
      case VideoType.spatial:
        return 'Spatial';
      case VideoType.flat:
        return 'HD';
    }
  }

  String get durationFormatted {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}

// Sample catalog — demo data
final List<VideoItem> demoVideos = [
  const VideoItem(
    id: '1',
    title: 'INTERSTELLAR',
    subtitle: 'A Journey Beyond Time',
    description:
        'Experience the cosmos in breathtaking 360° VR. Float through wormholes, witness black holes, and transcend the boundaries of space and time.',
    thumbnailUrl: 'https://picsum.photos/seed/space1/800/450',
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    type: VideoType.vr360,
    duration: Duration(hours: 2, minutes: 49),
    genre: 'Sci-Fi',
    rating: 9.2,
    year: 2024,
    isVR: true,
  ),
  const VideoItem(
    id: '2',
    title: 'DEPTHS',
    subtitle: 'Ocean Exploration',
    description:
        'Dive into the abyss of the deep ocean. An immersive 360° journey through bioluminescent creatures and ancient underwater landscapes.',
    thumbnailUrl: 'https://picsum.photos/seed/ocean2/800/450',
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    type: VideoType.vr360,
    duration: Duration(hours: 1, minutes: 42),
    genre: 'Documentary',
    rating: 8.7,
    year: 2024,
    isVR: true,
  ),
  const VideoItem(
    id: '3',
    title: 'SUMMIT',
    subtitle: 'Above the World',
    description:
        'Stand on the peak of Everest in spatial VR. Experience what only a handful of humans have ever seen — the world from the top.',
    thumbnailUrl: 'https://picsum.photos/seed/mountain3/800/450',
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    type: VideoType.spatial,
    duration: Duration(hours: 1, minutes: 15),
    genre: 'Adventure',
    rating: 9.0,
    year: 2025,
    isVR: true,
  ),
  const VideoItem(
    id: '4',
    title: 'NEON CITY',
    subtitle: 'The Cyberpunk Opera',
    description:
        'A dystopian cinematic masterpiece. Neon-drenched streets, electric storytelling, and a score that pulses with the heartbeat of the future.',
    thumbnailUrl: 'https://picsum.photos/seed/neon4/800/450',
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    type: VideoType.flat,
    duration: Duration(hours: 2, minutes: 12),
    genre: 'Thriller',
    rating: 8.5,
    year: 2025,
    isVR: false,
  ),
  const VideoItem(
    id: '5',
    title: 'AURORA',
    subtitle: 'Northern Lights VR',
    description:
        'Lie under the dancing northern lights in total immersion. A 360° meditation experience filmed in Iceland at the peak of solar maximum.',
    thumbnailUrl: 'https://picsum.photos/seed/aurora5/800/450',
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    type: VideoType.vr360,
    duration: Duration(minutes: 45),
    genre: 'Meditation',
    rating: 9.5,
    year: 2025,
    isVR: true,
  ),
  const VideoItem(
    id: '6',
    title: 'COLOSSEUM',
    subtitle: 'Ancient Rome Reborn',
    description:
        'Walk the sands of the ancient Colosseum in 180° VR. Watch gladiatorial combat unfold around you in historically-accurate reconstruction.',
    thumbnailUrl: 'https://picsum.photos/seed/rome6/800/450',
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    type: VideoType.vr180,
    duration: Duration(hours: 1, minutes: 58),
    genre: 'History',
    rating: 8.9,
    year: 2024,
    isVR: true,
  ),
];

final List<String> genres = [
  'All',
  'VR 360°',
  'Sci-Fi',
  'Documentary',
  'Adventure',
  'Thriller',
  'History',
  'Meditation',
];
