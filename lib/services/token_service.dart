import 'dart:convert';

import 'package:edu_xchange/config/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  final baseUrl = ApiConstants.baseUrl;

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh");
  }

  Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("access", access);
    await prefs.setString("refresh", refresh);
  }

  Future<bool> refreshAccessToken() async {
  try {
    final refreshToken = await getRefreshToken();

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh/'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "refresh": refreshToken,
      }),
    );


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("access", data["access"]);

      return true;
    }

    await logout();
    return false;
  } catch (e) {
    return false;
  }
}

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("access");
    await prefs.remove("refresh");
  }
}
