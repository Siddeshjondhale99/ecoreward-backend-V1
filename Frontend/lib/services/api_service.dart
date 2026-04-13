import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

class ApiService {
  final String _baseUrl = AppConstants.apiBaseUrl;
  final _storage = const FlutterSecureStorage();

  String get baseUrl => _baseUrl;

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool authenticated = false}) async {
    String? token;
    if (authenticated) {
      token = await getToken();
    }

    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _getHeaders(token),
      body: jsonEncode(body),
    );

    return response;
  }

  Future<http.Response> postForm(String endpoint, Map<String, String> body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    return response;
  }

  Future<http.Response> get(String endpoint, {bool authenticated = true}) async {
    String? token;
    if (authenticated) {
      token = await getToken();
    }

    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _getHeaders(token),
    );

    return response;
  }
}
