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
      throw Exception('Error fetching resources: $e');
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

  Future<List<Resource>> fetchUserResources() async {
    final url = Uri.parse('$baseUrl/resources/user/');
    try {
      final response = await ApiService().get(url);
      if (response.statusCode == 200) {
        final List jsonData = jsonDecode(response.body);

        return jsonData.map((e) => Resource.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load user resources');
      }
    } catch (e) {
      throw Exception('Error fetching user resources: $e');
    }
  }

  Future<bool> updateResource({
    required String resourceID,
    required String? title,
    required String? description,
    int? semester,
    int? category,
    String? status,
    String? price,
    File? image,
    File? file,
    List<File>? uploadedImages,
  }) async {
    final url = Uri.parse('$baseUrl/resources/$resourceID/');

    try {
      final response = await ApiService().multipartRequest(
        method: 'PATCH',
        url: url,
        buildRequest: (token) async {
          final request = http.MultipartRequest('PATCH', url);

          request.headers['Authorization'] = 'Bearer $token';

          request.fields['title'] = title!;
          request.fields['description'] = description!;

          if (semester != null) {
            request.fields['semester'] = semester.toString();
          }

          if (category != null) {
            request.fields['category'] = category.toString();
          }
          if (status != null) {
            request.fields['status'] = status;
          }

          if (price != null) {
            request.fields['price'] = price;
          }

          if (image != null) {
            request.files.add(
              await http.MultipartFile.fromPath("image", image.path),
            );
          }

          if (file != null) {
            request.files.add(
              await http.MultipartFile.fromPath("file", file.path),
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

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating resource: $e');
    }
  }

  Future<bool> deleteImage(int imageId) async {
    final url = Uri.parse('$baseUrl/delete-image/$imageId/');

    try {
      final response = await ApiService().delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting image: $e');
    }
  }

  Future<void> deleteResource(int resourceID) async {
    final url = Uri.parse('$baseUrl/resources/$resourceID/');

    try {
      final response = await ApiService().delete(url);

      if (response.statusCode != 204) {
        throw Exception('Failed to delete resource');
      }
    } catch (e) {
      throw Exception('Error deleting resource: $e');
    }
  }
}
