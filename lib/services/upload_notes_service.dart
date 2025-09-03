import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class OcrService {
  final Dio _dio = Dio();

  Future<String> uploadFile(File file) async {
    try {
      final fileExtension = file.path.split('.').last.toLowerCase();
      MediaType? mediaType;

      if (fileExtension == 'pdf') {
        mediaType = MediaType('application', 'pdf');
      } else if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
        mediaType = MediaType(
          'image',
          fileExtension == 'jpg' ? 'jpeg' : fileExtension,
        );
      } else {
        throw Exception("Unsupported file type");
      }

      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: "upload.$fileExtension",
          contentType: mediaType,
        ),
      });

      final response = await _dio.post(
        "http://10.0.2.2:8000/ocr",
        data: formData,
        options: Options(
          responseType: ResponseType.plain, // accept plain text or JSON
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Case 1: Try to parse as JSON
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            return decoded['text'] ?? '';
          }
        } catch (_) {
          // not JSON, fall through
        }

        // Case 2: If it's plain text, just return it
        if (data is String) {
          return data;
        }

        return '';
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }
}
