import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<bool> login(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    return response.statusCode == 200;
  }

  Future<bool> register(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    return response.statusCode == 201;
  }
}
