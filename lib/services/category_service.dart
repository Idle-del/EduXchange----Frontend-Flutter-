import 'dart:convert';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  final baseUrl = ApiConstants.baseUrl;

  Future<List<dynamic>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/categories/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      return [];
    }
  }
}