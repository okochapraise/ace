import 'package:dio/dio.dart';
import '../models/studyplan_model.dart';

class StudyPlannerService {
  late final Dio _dio;

  StudyPlannerService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://127.0.0.1:8000",
      ),
    );
  }

  Future<StudyPlan> generatePlan({
    required int textLength,
    required int availableMinutes,
    required String mood,
  }) async {
    final response = await _dio.post(
      "/study-plan/",
      data: {
        "text_length": textLength,
        "available_minutes": availableMinutes,
        "mood": mood,
      },
    );

    return StudyPlan.fromJson(response.data);
  }
}