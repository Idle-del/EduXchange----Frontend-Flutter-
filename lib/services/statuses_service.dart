import 'dart:convert';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:http/http.dart' as http;

class StatusService {
  Future<List<dynamic>> fetchStatuses() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/statuses/');
    try {
      final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load statuses');
    }
    } catch (e) {
      return [];
    }
  }
}