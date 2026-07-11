import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh");
  }

  Future<void> saveTokens(
      String access,
      String refresh,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("access", access);
    await prefs.setString("refresh", refresh);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("access");
    await prefs.remove("refresh");
  }
}