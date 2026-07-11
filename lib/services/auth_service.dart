// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final baseUrl = ApiConstants.baseUrl;

  Future<bool> register(
    String email,
    String password,
    String firstName,
    String lastName, {
    String? bio,
    String? department,
    int? semester,
    File? imageFile,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register/');

      var request = http.MultipartRequest('POST', url);

      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;

      if (bio != null && bio.isNotEmpty) {
        request.fields['bio'] = bio;
      }

      if (department != null && department.isNotEmpty) {
        request.fields['department'] = department;
      }

      if (semester != null) {
        request.fields['semester'] = semester.toString();
      }

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_picture', // Django ImageField name
            imageFile.path,
          ),
        );
      }

      var response = await request.send();

      String responseBody = await response.stream.bytesToString();

      print(
        'Registration response: ${response.statusCode}\n$responseBody',
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['access'] != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('jwt_token', json['access']);
        await prefs.setString('refresh_token', json['refresh']);
        await prefs.setInt('user_id', json['id']);
        await prefs.setString('user_email', json['email']);
        await prefs.setString('first_name', json['first_name']);
        await prefs.setString('last_name', json['last_name']);
        await prefs.setString('bio', json['bio'] ?? '');
        await prefs.setString('department', json['department'] ?? '');
        await prefs.setInt('semester', json['semester'] ?? 0);

        return true;
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
}