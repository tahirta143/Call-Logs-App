import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<Map<String, String>> authHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }
}
