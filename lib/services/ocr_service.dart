import 'dart:io';
import 'package:ace/models/ocr_model.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';


class OcrService {
  late final Dio _dio;

  OcrService() {
  _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000",
    ),
  );
}

  Future<OcrResult> uploadFile(File file) async {
    final fileExtension = file.path.split('.').last.toLowerCase();
    final mediaType = _getMediaType(fileExtension);

    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: "upload.$fileExtension",
        contentType: mediaType,
      ),
    });

    try {
      final response = await _dio.post(
        "/ocr",
        data: formData,
      );

      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.statusCode}");
      }

      return OcrResult.fromJson(response.data);
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }

  MediaType _getMediaType(String ext) {
    switch (ext) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'jpg':
      case 'jpeg':
      case 'png':
        return MediaType('image', ext == 'jpg' ? 'jpeg' : ext);
      default:
        throw Exception("Unsupported file type: $ext");
    }
  }
}
