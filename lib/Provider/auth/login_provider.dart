import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinity/View/splashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/api_config.dart';
import '../../helpers/permission_helper.dart';

class LoginProvider with ChangeNotifier {
  bool isLoading = false;
  String message = "";

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      message = "Please enter username and password";
      notifyListeners();
      return;
    }

    isLoading = true;
    message = "";
    notifyListeners();

    try {
      debugPrint("📡 [LOGIN REQUEST] $username");
      final response = await http.post(
          Uri.parse(ApiConfig.loginUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({'username': username, 'password': password}));

      final responseData = jsonDecode(response.body);
      debugPrint("📡 [LOGIN RESPONSE] Status: ${response.statusCode}");
      debugPrint("📡 [LOGIN RESPONSE] Body: ${response.body}");

      if (response.statusCode == 200) {
        // Handle both flat and nested response structures
        final data = responseData['data'] ?? responseData;
        final token = data['token'];
        final user = data['user'];

        if (token != null) {
          message = "Login successful!";
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          await prefs.setString('token', token);
          if (user != null) {
            await prefs.setString('username', user['username'] ?? username);
            await prefs.setString('role', user['role'] ?? 'admin'); // Defaulting to admin if missing
            await prefs.setString('user', jsonEncode(user));

            // Extract permissions dynamically
            final permissions = PermissionHelper.extractPermissionsFromUser(user);
            await PermissionHelper.savePermissions(permissions);
          }

          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Splashscreen()),
            );
          }
        } else {
          message = responseData['message'] ?? "Token not found in response";
        }
      } else {
        message = responseData['message'] ?? "Invalid credentials";
      }
    } catch (e) {
      debugPrint("❌ [LOGIN ERROR] $e");
      message = "Something went wrong: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
