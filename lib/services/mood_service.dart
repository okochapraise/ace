import 'package:dio/dio.dart';
import '../models/mood_model.dart';

class MoodService {
  late final Dio _dio;

  MoodService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://127.0.0.1:8000",
      ),
    );
  }

  Future<MoodRecommendation> getRecommendation(String mood) async {
    final response = await _dio.post(
      "/mood",
      data: {"mood": mood},
    );

    return MoodRecommendation.fromJson(response.data);
  }
}