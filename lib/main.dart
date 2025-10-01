import 'package:beatwave/auth/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Trackify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF121212), // Dark Charcoal
        cardColor: const Color(0xFF1E1E1E), // Lighter Charcoal for cards/panels
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1565C0), // Classic Blue (AppBar & Primary Buttons)
          onPrimary: Colors.white,
          secondary: Color(0xFF64B5F6), // Soft Blue (Accents)
          onSecondary: Colors.white,
          background: Color(0xFF121212), // Dark Charcoal
          onBackground: Color(0xFFE0E0E0), // Light Gray text
          surface: Color(0xFF1E1E1E), // Lighter Charcoal for surfaces
          onSurface: Color(0xFFE0E0E0),
          error: Color(0xFFEF5350), // Expense/Negative
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0), // Classic Blue
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1565C0), // Classic Blue
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE0E0E0)), // Primary Text
          bodyMedium: TextStyle(color: Color(0xFFB0B0B0)), // Secondary Text
          headlineMedium: TextStyle(
            color: Colors.white, // Header Text
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0), // Classic Blue
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const Wrapper(),
    );
  }
}
