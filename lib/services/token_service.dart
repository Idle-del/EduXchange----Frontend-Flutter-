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

  Future<void> saveUserData(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('user_id', json['id']);
    await prefs.setString('user_email', json['email']);
    await prefs.setString('first_name', json['first_name']);
    await prefs.setString('last_name', json['last_name']);
    await prefs.setString('bio', json['bio'] ?? '');
    await prefs.setString('department', json['department'] ?? '');
    await prefs.setInt('semester', json['semester'] ?? 0);

    if (json['profile_picture'] != null) {
      await prefs.setString('profile_picture', json['profile_picture']);
    }
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('first_name');
  }

  Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_name');
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<String?> getProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_picture');
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh": refreshToken}),
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

    await prefs.remove("user_id");
    await prefs.remove("user_email");
    await prefs.remove("first_name");
    await prefs.remove("last_name");
    await prefs.remove("bio");
    await prefs.remove("department");
    await prefs.remove("semester");
    await prefs.remove("profile_picture");
  }
}
