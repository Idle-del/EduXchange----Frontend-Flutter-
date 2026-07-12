import 'dart:convert';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:http/http.dart' as http;

class SemesterService {
  Future<List<dynamic>> fetchSemesters() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/semesters/');
    try {
      final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load semesters');
    }
    } catch (e) {
      return [];
    }
  }
}