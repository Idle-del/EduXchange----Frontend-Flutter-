import 'dart:convert';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/model/user_model.dart';
import 'package:edu_xchange/services/token_servce.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  final baseUrl = ApiConstants.baseUrl;

  Future<UserProfile> fetchUserProfile() async {
    try {
    final token = await TokenService().getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserProfile.fromJson(jsonData);
    } else {
      throw Exception('Failed to load user profile');
    }
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }
}
