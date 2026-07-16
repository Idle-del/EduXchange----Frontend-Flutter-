import 'dart:convert';
import 'dart:io';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/model/resource_model.dart';
import 'package:edu_xchange/services/api_service.dart';
import 'package:http/http.dart' as http;

class ResourceService {
  final baseUrl = ApiConstants.baseUrl;

  Future<void> createResource({
    required String title,
    required String description,
    required int category,
    required String type,
    int? semester,
    File? file,
    File? image,
    int? price,
    List<File>? uploadedImages,
  }) async {
    final url = Uri.parse('$baseUrl/resources/');

    print(
      'Creating resource with title: $title, description: $description, category: $category, type: $type, semester: $semester, price: $price',
    );

    final response = await ApiService().multipartRequest(
      method: 'POST',
      url: url,
      buildRequest: (token) async {
        final request = http.MultipartRequest('POST', url);

        request.headers['Authorization'] = 'Bearer $token';

        request.fields['title'] = title;
        request.fields['description'] = description;
        request.fields['category'] = category.toString();
        request.fields['type'] = type;

        if (semester != null) {
          request.fields['semester'] = semester.toString();
        }

        if (price != null) {
          request.fields['price'] = price.toString();
        }

        if (file != null) {
          request.files.add(
            await http.MultipartFile.fromPath("file", file.path),
          );
        }

        if (image != null) {
          request.files.add(
            await http.MultipartFile.fromPath("image", image.path),
          );
        }

        if (uploadedImages != null && uploadedImages.isNotEmpty) {
          for (final img in uploadedImages) {
            request.files.add(
              await http.MultipartFile.fromPath("uploaded_images", img.path),
            );
          }
        }

        return request;
      },
    );

    print('Response status code: ${response.statusCode}');
    final responseBody = await response.stream.bytesToString();
    print('Response body: $responseBody');
    if (response.statusCode != 201) {
      final error = await response.stream.bytesToString();
      throw Exception('Failed to create resource: $error');
    }
  }

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
