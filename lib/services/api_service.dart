import 'package:edu_xchange/services/token_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final TokenService _tokenService = TokenService();

  Future<http.Response> get(Uri url) async {
    String? token = await _tokenService.getAccessToken();

    http.Response response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    // Access token expired?
    if (response.statusCode == 401 || response.statusCode == 403) {
      final refreshed = await _tokenService.refreshAccessToken();

      if (refreshed) {
        token = await _tokenService.getAccessToken();

        response = await http.get(
          url,
          headers: {
            "Authorization": "Bearer $token",
          },
        );
      }
    }

    return response;
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    String? token = await _tokenService.getAccessToken();

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        ...?headers,
      },
      body: body,
    );

    // Access token expired?
    if (response.statusCode == 401 || response.statusCode == 403) {
      final refreshed = await _tokenService.refreshAccessToken();

      if (refreshed) {
        token = await _tokenService.getAccessToken();

        return await http.post(
          url,
          headers: {
            "Authorization": "Bearer $token",
            ...?headers,
          },
          body: body,
        );
      }
    }

    return response;
  }

    Future<http.StreamedResponse> multipartRequest({
    required String method,
    required Uri url,
    required Future<http.MultipartRequest> Function(String token) buildRequest,
  }) async {
    String? token = await _tokenService.getAccessToken();

    http.MultipartRequest request = await buildRequest(token!);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 401 || response.statusCode == 403) {
      final refreshed = await _tokenService.refreshAccessToken();

      if (refreshed) {
        token = await _tokenService.getAccessToken();

        request = await buildRequest(token!);

        response = await request.send();
      }
    }

    return response;
  }

  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
    String? token = await _tokenService.getAccessToken();

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        ...?headers,
      },
      body: body,
    );

    // Access token expired?
    if (response.statusCode == 401 || response.statusCode == 403) {
      final refreshed = await _tokenService.refreshAccessToken();

      if (refreshed) {
        token = await _tokenService.getAccessToken();

        return await http.put(
          url,
          headers: {
            "Authorization": "Bearer $token",
            ...?headers,
          },
          body: body,
        );
      }
    }

    return response;
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers}) async {
    String? token = await _tokenService.getAccessToken();

    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
        ...?headers,
      },
    );

    // Access token expired?
    if (response.statusCode == 401 || response.statusCode == 403) {
      final refreshed = await _tokenService.refreshAccessToken();

      if (refreshed) {
        token = await _tokenService.getAccessToken();

        return await http.delete(
          url,
          headers: {
            "Authorization": "Bearer $token",
            ...?headers,
          },
        );
      }
    }

    return response;
  }
}