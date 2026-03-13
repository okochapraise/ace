import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000";
  final SecureStorage _storage = SecureStorage();

  Future<bool> login(String email, String password) async {
  final response = await http.post(
    Uri.parse("$baseUrl/auth/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    await _storage.saveToken(data["access_token"]);
    return true;
  } else {
    print("LOGIN ERROR: ${response.statusCode} ${response.body}");
    return false;
  }
}
  Future<String?> getToken() async {
  return await _storage.getToken();
}

  Future<void> logout() async {
    await _storage.deleteToken();
  }

  Future<bool> register(String email, String password) async {
  final response = await http.post(
    Uri.parse("$baseUrl/auth/register"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  return response.statusCode == 200 || response.statusCode == 201;
}
}
