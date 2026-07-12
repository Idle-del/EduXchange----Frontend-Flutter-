import 'dart:convert';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/model/user_model.dart';
import 'package:edu_xchange/services/api_service.dart';

class ProfileService {
  final baseUrl = ApiConstants.baseUrl;

  Future<UserProfile> fetchUserProfile() async {
    final url = Uri.parse('$baseUrl/auth/profile/');
    try {
    final response = await ApiService().get(url);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserProfile.fromJson(jsonData);
    } else {
      throw Exception('Failed to load user profile');
    }
    } catch (e) {
      rethrow;
    }
  }
}
