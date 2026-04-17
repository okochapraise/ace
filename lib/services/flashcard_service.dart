import 'package:dio/dio.dart';
import '../models/flashcard.dart';
import '../utils/secure_storage.dart';

class FlashcardService {
  late final Dio _dio;
  final SecureStorage _storage = SecureStorage();

  FlashcardService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://127.0.0.1:8000", 
      ),
    );

    _dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await _storage.getToken();

      print("TOKEN USED: $token");   

      if (token != null) {
        options.headers["Authorization"] = "Bearer $token";
      }

      return handler.next(options);
    },
  ),
);
  }

  Future<List<Flashcard>> generateFlashcards({
    required String text,
    required int availableMinutes,
    required String difficulty,
  }) async {
    final response = await _dio.post(
      "/flashcards",
      data: {
        "text": text,
        "available_minutes": availableMinutes,
        "difficulty": difficulty,
      },
    );

    final List data = response.data['flashcards'];
    return data.map((e) => Flashcard.fromJson(e)).toList();
  }
Future<Map<String, dynamic>> saveSessionSummary({
  required List<Flashcard> flashcards,
  required List<bool> answers,
}) async {

  final response = await _dio.post(
    "/flashcards/session-summary",
    data: {
      "flashcards": flashcards.map((f) => f.toJson()).toList(),
      "answers": answers,
    },
  );

  return response.data["session_summary"];
}

  Future<List<dynamic>> getStats() async {
    final response = await _dio.get("/flashcards/stats");
    return response.data;
  }
}

