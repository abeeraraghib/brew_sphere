import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_screen.dart';

Future<void> signOutUser(BuildContext context) async {
  print("Sign out triggered");

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFFBE9E7),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.brown)),
            onPressed: () {
              print("Sign out cancelled");
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Sign Out', style: TextStyle(color: Colors.brown)),
            onPressed: () {
              print("Sign out confirmed");
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    print("Signing out...");

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      try {
        await googleSignIn.disconnect();
        print("Google disconnected");
      } catch (e) {
        print("Google disconnect failed (might not be signed in): $e");
      }

      await googleSignIn.signOut();
      print("Google sign out complete");

      // Firebase sign out
      await FirebaseAuth.instance.signOut();
      print("Firebase sign out complete");

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print("Shared preferences cleared");

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("Sign out error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error signing out: $e")),
        );
      }
    }
  }
}
