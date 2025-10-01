import 'package:beatwave/auth/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isSending = false;
  bool isReloading = false;

  Future<void> sendVerifyLink() async {
    setState(() {
      isSending = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      Get.snackbar(
        'Verification Link Sent',
        'Please check your email and click the verification link.',
        margin: const EdgeInsets.all(20),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey.shade800,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  Future<void> reloadUser() async {
    setState(() {
      isReloading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.reload();
      if (user.emailVerified) {
        Get.offAll(() => const Wrapper());
      } else {
        Get.snackbar(
          'Not Verified Yet',
          'Please verify your email first.',
          margin: const EdgeInsets.all(20),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blueGrey.shade800,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isReloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      appBar: AppBar(
        title: const Text("Email Verification"),
        backgroundColor: const Color(0xFF1565C0), // Classic Blue
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_read_rounded,
                size: 80,
                color: Color(0xFF1565C0), // Classic Blue
              ),
              const SizedBox(height: 20),
              const Text(
                'Please verify your email address by clicking the link sent to your email.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70, // light text on dark background
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: isSending ? null : sendVerifyLink,
                icon: const Icon(Icons.email_outlined),
                label: Text(
                  isSending ? 'Sending...' : 'Send Verification Email',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: isReloading ? null : reloadUser,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  isReloading ? 'Reloading...' : 'I have verified',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
