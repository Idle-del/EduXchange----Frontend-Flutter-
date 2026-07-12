import 'package:edu_xchange/services/token_servce.dart';
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
}