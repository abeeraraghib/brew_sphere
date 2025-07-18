import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splashscreen.dart';
import 'login_screen.dart';
import '../home/dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); 
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        return BrewSphereDashboardApp();
      },
    );
  }
}
