import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    return await http.get(uri, headers: _headers(token: token));
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    return await http.post(
      uri,
      headers: _headers(token: token),
      body: jsonEncode(body ?? {}),
    );
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    return await http.put(
      uri,
      headers: _headers(token: token),
      body: jsonEncode(body ?? {}),
    );
  }

  Future<http.Response> delete(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    return await http.delete(uri, headers: _headers(token: token));
  }
}
