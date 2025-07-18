import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('preferences')
          .doc(uid)
          .get();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', uid);

      if (!mounted) return;

      Fluttertoast.showToast(msg: "Welcome back!");

      Navigator.pushReplacementNamed(
        context,
        doc.exists ? '/dashboard' : '/preferences',
      );
    } catch (e) {
      if (!mounted) return;

      Fluttertoast.showToast(msg: "Login failed: ${e.toString()}");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '385795818514-g60pakku8ftvuvvtoree3ie2hkad43hg.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final uid = userCred.user!.uid;

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(uid);
      if (!(await userDoc.get()).exists) {
        await userDoc.set({
          'name': userCred.user?.displayName ?? '',
          'email': userCred.user?.email ?? '',
        });
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', uid);

      final prefDoc = await FirebaseFirestore.instance
          .collection('preferences')
          .doc(uid)
          .get();

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        prefDoc.exists ? '/dashboard' : '/preferences',
      );
    } catch (e) {
      if (!mounted) return;

      Fluttertoast.showToast(msg: "Google Sign-In failed: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0x00c4a484).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 8),
                )
              ],
            ),
            width: 360,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 12),
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: _inputDecoration("Email"),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (val) => email = val!.trim(),
                      validator: (val) => val == null || !val.contains('@')
                          ? 'Enter valid email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputDecoration("Password"),
                      obscureText: true,
                      onSaved: (val) => password = val!,
                      validator: (val) => val == null || val.length < 6
                          ? 'Password too short'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F4E37),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 14),
                      ),
                      child: const Text("Login"),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: Image.asset(
                        'assets/images/google.png',
                        height: 24,
                      ),
                      label: const Text("Continue with Google"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/register'),
                      child: Text(
                        "Register an account",
                        style: TextStyle(
                          color: Colors.brown.shade700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 90,
      height: 90,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.brown, width: 3),
      ),
      child: const CircleAvatar(
        radius: 40,
        backgroundImage: AssetImage('assets/images/logo.jpg'),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.brown.shade700),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
