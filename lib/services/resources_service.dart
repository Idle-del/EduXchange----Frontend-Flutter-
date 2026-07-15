import 'dart:convert';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/model/resource_model.dart';
import 'package:edu_xchange/services/api_service.dart';

class ResourceService {
  final baseUrl = ApiConstants.baseUrl;

  Future<List<Resource>> fetchResources() async {
    final url = Uri.parse('$baseUrl/resources/');

    try {
      final response = await ApiService().get(url);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        return (jsonData['results'] as List)
            .map((e) => Resource.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load resources');
      }
    } catch (e) {
      return [];
    }
  }

  Future<Resource> fetchResourceDetail(int resourceID) async {
    final url = Uri.parse('$baseUrl/resources/$resourceID/');

    try {
      final response = await ApiService().get(url);
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
