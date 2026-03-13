import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000"; // Android emulator
  final SecureStorage _storage = SecureStorage();

  Future<Map<String, dynamic>?> getMe() async {
    final token = await _storage.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/auth/me"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}