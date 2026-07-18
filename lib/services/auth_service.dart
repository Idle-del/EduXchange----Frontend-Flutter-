import 'dart:convert';
import 'dart:io';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/services/token_service.dart';
import 'package:http/http.dart' as http;

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

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['access'] != null) {
        final tokenService = TokenService();

        await tokenService.saveTokens(json['access'], json['refresh']);

        await tokenService.saveUserData(json);

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? bio,
    String? department,
    int? semester,
    File? imageFile,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/profile/');
      final tokenService = TokenService();
      final accessToken = await tokenService.getAccessToken();

      var request = http.MultipartRequest('PATCH', url);

      request.headers['Authorization'] = 'Bearer $accessToken';

      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      // request.fields['email'] = email;

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

      final responseBody = await response.stream.bytesToString();

      print(response.statusCode);
      print(responseBody);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
