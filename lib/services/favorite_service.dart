import 'dart:convert';
import 'package:edu_xchange/config/api_constants.dart';
import 'package:edu_xchange/model/resource_model.dart';
import 'package:edu_xchange/services/api_service.dart';

class FavoriteService {
  final String baseUrl = ApiConstants.baseUrl;
  final ApiService _api = ApiService();

  /// Adds [resourceId] to the current user's favorites.
  Future<void> addFavorite(int resourceId) async {
    final url = Uri.parse('$baseUrl/resources/$resourceId/favorite/');
    final response = await _api.post(url);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add favorite');
    }
  }

  /// Removes [resourceId] from the current user's favorites.
  Future<void> removeFavorite(int resourceId) async {
    final url = Uri.parse('$baseUrl/resources/$resourceId/remove-favorite/');
    final response = await _api.delete(url);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove favorite');
    }
  }

  /// Full list of favorited resources — used by the Favorites screen.
  Future<List<Resource>> fetchFavoriteResources() async {
    final url = Uri.parse('$baseUrl/favorites/');
    final response = await _api.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData
          .map((item) => Resource.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  /// Just the ids — used on the detail screen to pre-fill the heart icon
  /// without needing a dedicated "is this favorited" endpoint.
  Future<Set<int>> fetchFavoriteIds() async {
    final resources = await fetchFavoriteResources();
    return resources.map((r) => r.id).toSet();
  }
}