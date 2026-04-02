import 'package:flutter/material.dart';
import 'package:infinity/View/Auths/Login_screen.dart';
import 'package:infinity/View/home/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../compoents/responsive_helper.dart';

import 'bottombar/BottomBar.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print("🔑 Token from prefs: $token");

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>BottombarScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: context.sw(0.4),
              width: context.sw(0.4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
              ),
              child: Image.asset('assets/images/logo.png'),
            ),
            const SizedBox(height: 20),
            Text(
              "Call Logs\nAdmin App",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: context.sw(0.08),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
