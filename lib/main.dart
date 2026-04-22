import 'package:flutter/material.dart';
import 'package:infinity/Provider/auth/login_provider.dart';
import 'package:infinity/Provider/auth/access_control_provider.dart';
import 'package:infinity/View/Auths/Login_screen.dart';
import 'package:infinity/View/home/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'Provider/dashboard/dashboard_provider.dart';

import 'Provider/staff/StaffProvider.dart';
import 'View/SplashScreenMain.dart';
import 'View/splashScreen.dart';
import 'Provider/theme/theme_provider.dart';
import 'Provider/stock/StockProvider.dart';
import 'compoents/app_theme.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_)=>LoginProvider()),
      ChangeNotifierProvider(create: (_)=>DashBoardProvider()),
      ChangeNotifierProvider(create: (_) => StaffProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => StockProvider()),
      ChangeNotifierProvider(create: (_) => AccessControlProvider()),
    ],
    child: const MyApp(),)
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Infinity',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: OnboardingScreen(),
        );
      },
    );
  }
}

