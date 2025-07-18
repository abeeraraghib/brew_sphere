import 'package:flutter/material.dart';
import 'shared_drawer.dart';
import 'explore.dart'; // ✅ Import the ExplorePage

class BrewSphereDashboardApp extends StatelessWidget {
  const BrewSphereDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Dashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const BrewSphereDrawer(),
      extendBodyBehindAppBar: true,
  appBar: AppBar(
  backgroundColor: Colors.black.withOpacity(0.7),
  centerTitle: true,
  elevation: 0,
  iconTheme: const IconThemeData(color: Colors.white70), 
  title: const Text(
    'Brew Sphere',
    style: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  ),
),

      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/dashboard.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Best coffee for your taste\n\nDiscover the art of coffee and cherish moments that linger like the perfect brew.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                  icon: const Icon(Icons.explore, color: Colors.white), 
                  label: const Text(
                    'Explore More',
                  style: TextStyle(color: Colors.white), 
            ),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade700,
                  foregroundColor: Colors.white, 
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
              ),
          ),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExplorePage()),
    );
  },
),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
