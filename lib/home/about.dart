import 'package:flutter/material.dart';
import 'shared_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
          'About Us',
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
            'assets/images/about.jpeg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double fontSize = screenWidth < 350
                  ? 14
                  : screenWidth < 500
                      ? 16
                      : 18;

              return SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                    child: Text(
                      '''Welcome to Brew Sphere!

Brew Sphere is your personalized guide to the world of coffee. Whether you're a curious beginner or a seasoned barista, our app is designed to enhance your coffee journey.

☕ Get tailored coffee recommendations based on your flavor and roast preferences.
🛒 Browse a curated catalog of premium beans from around the world.
👥 Join a vibrant coffee community—share reviews, recipes, and recommendations.
🤖 Chat with our CoffeeBot for instant suggestions and brewing tips.
🔐 Enjoy a seamless experience with secure login and personalized dashboards.

At Brew Sphere, we believe every cup should be an experience. Explore the taste, aroma, and story behind each brew—crafted just for you.''',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
