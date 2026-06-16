import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? code;
  ApiException(this.statusCode, this.message, [this.code]);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://attendance-backend-nds0.onrender.com/api');
  static const String _tokenKey = 'auth_token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> _requireConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final hasInternet = results.any((r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet);
      if (!hasInternet) {
        throw ApiException(0, 'No internet connection. Please check your network and try again.');
      }
    } catch (_) {
      // On web, connectivity_plus may not be reliable; skip check
    }
  }

  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body,
      {bool requiresAuth = false}) async {
    await _requireConnectivity();
    final headers = requiresAuth ? await _headers() : {'Content-Type': 'application/json'};
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      final msg = data['message'] ?? 'Request failed';
      final status = response.statusCode;
      final code = data['code'] as String?;
      if (data['debug'] != null) {
        throw ApiException(status, '$msg (debug: ${jsonEncode(data['debug'])})', code);
      }
      throw ApiException(status, msg, code);
    }
    return data;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    await _requireConnectivity();
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, data['message'] ?? 'Request failed');
    }
    return data;
  }

  Future<String> downloadCsv(String endpoint) async {
    await _requireConnectivity();
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 60));
    if (response.statusCode >= 400) {
      final data = jsonDecode(response.body);
      throw ApiException(response.statusCode, data['message'] ?? 'Download failed');
    }
    return response.body;
  }

  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> body) async {
    await _requireConnectivity();
    final headers = await _headers();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, data['message'] ?? 'Request failed');
    }
    return data;
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    await _requireConnectivity();
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, data['message'] ?? 'Request failed');
    }
    return data;
  }
}