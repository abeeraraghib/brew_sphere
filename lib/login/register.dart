import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCred.user!;
      await user.sendEmailVerification();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'name': name, 'email': email});

      Fluttertoast.showToast(
        msg:
            "Registration successful! Verification email sent to $email. Please verify before logging in.",
        toastLength: Toast.LENGTH_LONG,
      );

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: "Registration failed: ${e.message}",
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Unexpected error: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: 'YOUR_WEB_CLIENT_ID_HERE.apps.googleusercontent.com', // 🔁 Replace this!
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

      final user = userCred.user!;
      final uid = user.uid;

      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      if (!(await userDoc.get()).exists) {
        await userDoc.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
        });
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', uid);

      final prefDoc = await FirebaseFirestore.instance
          .collection('preferences')
          .doc(uid)
          .get();

      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          prefDoc.exists ? '/dashboard' : '/preferences',
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Google Sign-Up failed: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
      );
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
                ),
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
                      "Create Account",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: _inputDecoration("Name"),
                      onSaved: (val) => name = val!.trim(),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputDecoration("Email"),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (val) => email = val!.trim(),
                      validator: (val) => val == null || !val.contains('@')
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputDecoration("Password"),
                      obscureText: true,
                      onSaved: (val) => password = val!,
                      validator: (val) => val == null || val.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6F4E37),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 14),
                            ),
                            child: const Text("Register"),
                          ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _signUpWithGoogle,
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
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: Text(
                        "Already have an account?",
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
