import 'dart:convert';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/model/resource_model.dart';
import 'package:edu_xchange/services/token_servce.dart';
import 'package:http/http.dart' as http;

class ResourceService {
  final baseUrl = ApiConstants.baseUrl;

  Future<List<Resource>> fetchResources() async {
    final url = Uri.parse('$baseUrl/resources/');
    final token = await TokenService().getAccessToken();

    print('Fetching resources with token: $token');
    print({"Authorization": "Bearer $token"});

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // print('Resources fetched successfully: ${response.body}');
        final jsonData = jsonDecode(response.body);

        return (jsonData['results'] as List)
            .map((e) => Resource.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load resources');
      }
    } catch (e) {
      // print('Error fetching resources: ${e.toString()}');
      return [];
    }
  }

  Future<Resource> fetchResourceDetail(int resourceID) async {
    final url = Uri.parse('$baseUrl/resources/$resourceID/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return Resource.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load resource detail');
      }
    } catch (e) {
      throw Exception('Error fetching resource detail: $e');
    }
  }
}
