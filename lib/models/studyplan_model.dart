class StudySession {
  final int duration;
  final String activity;
  final String difficulty;

  StudySession({
    required this.duration,
    required this.activity,
    required this.difficulty,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      duration: json['duration'],
      activity: json['activity'],
      difficulty: json['difficulty'],
    );
  }
}

class StudyPlan {
  final List<StudySession> sessions;
  final String message;

  StudyPlan({
    required this.sessions,
    required this.message,
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      sessions: (json['sessions'] as List)
          .map((e) => StudySession.fromJson(e))
          .toList(),
      message: json['message'],
    );
  }
}