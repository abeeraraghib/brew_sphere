import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';
import 'about.dart';
import 'chatbot/chatbot.dart';
import 'community.dart';
import 'shop/order_page.dart';
import 'preferences_page.dart';
import 'package:firebase_p1/login/login_screen.dart'; 

class BrewSphereDrawer extends StatelessWidget {
  const BrewSphereDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFD7B899),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF6F4E37)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/logo.jpg'),
                ),
                SizedBox(height: 10),
                Text(
                  'Brew Sphere',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(context, Icons.home, 'Home', const BrewSphereDashboardApp()),
          _drawerItem(context, Icons.info, 'About', const AboutPage()),
          _drawerItem(context, Icons.shopping_cart, 'Order', OrderPage()),
          _drawerItem(context, Icons.settings, 'Preferences', const PreferencesPage()),
          _drawerItem(context, Icons.group, 'Community', const CommunityPage()),
          _drawerItem(context, Icons.chat, 'ChatBot', const CoffeeBot()),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.brown.shade900),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Color.fromARGB(255, 255, 252, 252), fontSize: 16),
            ),
            onTap: () async {
              Navigator.of(context).pop(); // Close drawer

              bool? confirmLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFFF3E5AB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      'Confirm Sign Out',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.brown.shade800,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to sign out?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown.shade700,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.brown.shade700),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.brown.shade800,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  );
                },
              );

              if (confirmLogout == true) {
                try {
                  await FirebaseAuth.instance.signOut();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();

                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sign out failed: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown.shade900),
      title: Text(
        title,
        style: const TextStyle(color: Color.fromARGB(255, 255, 252, 252), fontSize: 16),
      ),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}
