import 'package:beatwave/screens/dashboard_screen.dart';
import 'package:beatwave/auth/login.dart';
import 'package:beatwave/auth/verifyEmail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:beatwave/bottom_navigation.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      body: Center(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF1565C0), // Classic Blue accent
                ),
              );
            }

            if (snapshot.hasData) {
              final user = snapshot.data!;
              if (user.emailVerified) {
                return const BottomNavigation();
              } else {
                return const VerifyEmail();
              }
            } else {
              return const Login();
            }
          },
        ),
      ),
    );
  }
}
