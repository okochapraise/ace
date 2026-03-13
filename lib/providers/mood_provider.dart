import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_model.dart';
import '../services/mood_service.dart';

final moodServiceProvider = Provider<MoodService>((ref) {
  return MoodService();
});

final moodProvider =
    FutureProvider.family<MoodRecommendation, String>((ref, mood) async {
  return ref.read(moodServiceProvider).getRecommendation(mood);
});