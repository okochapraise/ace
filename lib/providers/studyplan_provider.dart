import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/studyplan_model.dart';
import '../services/studyplan_service.dart';

final studyPlannerServiceProvider =
    Provider((ref) => StudyPlannerService());

final studyPlannerProvider = FutureProvider.family<
    StudyPlan,
    ({int textLength, int minutes, String mood})>((ref, params) {
  return ref.read(studyPlannerServiceProvider).generatePlan(
        textLength: params.textLength,
        availableMinutes: params.minutes,
        mood: params.mood,
      );
});