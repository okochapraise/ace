//import 'dart:io';
import 'package:ace/models/summarizer_model.dart';
import 'package:dio/dio.dart';

class SummarizerService {
  late final Dio _dio;
  SummarizerService() {
  _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000",
    ),
  );
}
  Future<SummarizedText> summarizeText(String text) async {
    try {
      final response = await _dio.post(
        '/summarize',
        data: {'text': text.trim()},
      );
      return SummarizedText.fromJson(response.data);
    } catch (e) {
      throw Exception('Summarization failed: $e');
    }
  }
}
