import 'dart:convert';

import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/model/user.dart';
import 'package:edu_xchange/services/token_service.dart';
import 'package:http/http.dart' as http;

class UserService {
  final baseUrl = ApiConstants.baseUrl;

  Future<User> getUserDetails(int userId) async {
    final token = await TokenService().getAccessToken();
  final url = Uri.parse('$baseUrl/auth/user/$userId/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return User.fromJson(json);
  } else {
    throw Exception(
      'Failed to load user. Status: ${response.statusCode}\n${response.body}',
    );
  }
}
}