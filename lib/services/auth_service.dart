// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final baseUrl = ApiConstants.baseUrl;

  Future<bool> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['access'] != null) {
        // Save JWT token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', json['access']);
        await prefs.setString('refresh_token', json['refresh']);
        await prefs.setString('user_id', json['id'].toString());
        await prefs.setString('user_email', json['email']);
        await prefs.setString('first_name', json['first_name']);
        await prefs.setString('last_name', json['last_name']);
        await prefs.setString('bio', json['bio'] ?? '');
        await prefs.setString('department', json['department'] ?? '');
        await prefs.setInt('semester', json['semester'] ?? 0);

        return true;
      } else {
        // throw Exception(json['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      // print('Login error: ${e.toString()}');
      return false;
    }
  }
}