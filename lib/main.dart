import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login/auth_gate.dart'; 
import 'login/login_screen.dart';
import 'login/register.dart';
import 'home/dashboard.dart';
import 'home/about.dart';
import 'home/explore.dart';
import 'home/shop/order_page.dart';
import 'home/community.dart';
import 'home/chatbot/chatbot.dart';
import 'home/preferences_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase already initialized: $e");
  }

  runApp(const BrewSphereApp());
}

class BrewSphereApp extends StatelessWidget {
  const BrewSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brew Sphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => BrewSphereDashboardApp(),
        '/about': (context) => const AboutPage(),
        '/explore': (context) => const ExplorePage(),
        '/order_page': (context) => const OrderPage(),
        '/community': (context) => const CommunityPage(),
        '/chatbot': (context) => const CoffeeBot(),
        '/preferences': (context) => const PreferencesPage(),
      },
    );
  }
}
