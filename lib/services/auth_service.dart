import 'dart:convert';
import 'dart:io';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/services/token_service.dart';
import 'package:http/http.dart' as http;

/// Simple result wrapper so callers can show the real backend message
/// instead of a generic "failed" string.
class AuthResult {
  final bool success;
  final String message;

  AuthResult(this.success, this.message);
}

class AuthService {
  final baseUrl = ApiConstants.baseUrl;

  /// Extracts a human-readable message from a Django REST Framework
  /// error response body, e.g. {"email": ["user with this email already exists."]}
  /// or {"detail": "..."} or {"non_field_errors": [...]}.
  String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        if (decoded['detail'] != null) {
          return decoded['detail'].toString();
        }

        // Collect all field errors into one readable string.
        final messages = <String>[];
        decoded.forEach((key, value) {
          if (value is List) {
            for (final item in value) {
              messages.add(item.toString());
            }
          } else if (value is String) {
            messages.add(value);
          }
        });

        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }
    } catch (_) {
      // Fall through to generic message below.
    }
    return 'Registration failed';
  }

  Future<AuthResult> register(
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
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AuthResult(true, 'Registration successful');
      }

      return AuthResult(false, _extractErrorMessage(responseBody));
    } catch (e) {
      return AuthResult(false, 'Something went wrong. Please check your connection and try again.');
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