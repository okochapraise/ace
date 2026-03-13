class MusicRecommendation {
  final String query;
  final String spotifyUrl;

  MusicRecommendation({
    required this.query,
    required this.spotifyUrl,
  });

  factory MusicRecommendation.fromJson(Map<String, dynamic> json) {
    return MusicRecommendation(
      query: json['query'] ?? '',
      spotifyUrl: json['spotify_url'] ?? '',
    );
  }
}

class MoodRecommendation {
  final String mood;
  final String activity;
  final String reason;
  final String encouragement;
  final MusicRecommendation music;

  MoodRecommendation({
    required this.mood,
    required this.activity,
    required this.reason,
    required this.encouragement,
    required this.music,
  });

  factory MoodRecommendation.fromJson(Map<String, dynamic> json) {
    return MoodRecommendation(
      mood: json['mood'] ?? '',
      activity: json['activity'] ?? '',
      reason: json['reason'] ?? '',
      encouragement: json['encouragement'] ?? '',
      music: MusicRecommendation.fromJson(json['music']),
    );
  }
}