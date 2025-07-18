import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dashboard.dart'; // <-- Make sure this import is correct for your Dashboard widget

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final _auth = FirebaseAuth.instance;
  bool _loading = true;

  final List<String> flavors = [
    'Chocolatey', 'Fruity', 'Nutty', 'Floral', 'Earthy', 'Citrusy', 'Bold', 'Sweet'
  ];
  final List<String> types = ['Arabica', 'Robusta', 'Liberica'];
  final List<String> roasts = ['Light', 'Medium', 'Dark'];
  final List<String> origins = ['Ethiopia', 'Colombia', 'Brazil', 'Kenya', 'India'];

  String selectedType = 'Arabica';
  String selectedRoast = 'Medium';
  List<String> selectedFlavors = [];
  List<String> selectedOrigins = [];

  @override
  void initState() {
    super.initState();
    _loadExistingPreferences();
  }

  Future<void> _loadExistingPreferences() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('preferences').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        selectedType = data['type'] ?? 'Arabica';
        selectedRoast = data['roast'] ?? 'Medium';
        selectedFlavors = List<String>.from(data['flavors'] ?? []);
        selectedOrigins = List<String>.from(data['origins'] ?? []);
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _savePreferences() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('preferences').doc(uid).set({
      'type': selectedType,
      'roast': selectedRoast,
      'flavors': selectedFlavors,
      'origins': selectedOrigins,
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard()),
      );
    }
  }

  void _resetPreferences() {
    setState(() {
      selectedType = 'Arabica';
      selectedRoast = 'Medium';
      selectedFlavors.clear();
      selectedOrigins.clear();
    });
  }

  List<String> _getSuggestions() {
    List<String> results = [];
    if (selectedFlavors.isNotEmpty) results.add("• Something ${selectedFlavors.first.toLowerCase()}");
    if (selectedOrigins.isNotEmpty) results.add("• From ${selectedOrigins.first}");
    if (selectedRoast.isNotEmpty) results.add("• Roast: $selectedRoast");
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Dashboard()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Dashboard()),
              );
            },
          ),
          title: const Text("Coffee Preferences"),
          backgroundColor: const Color(0xFF6F4E37),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset Preferences',
              onPressed: _resetPreferences,
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/preferences.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Colors.white.withOpacity(0.4),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListView(
                            children: [
                              const Text(
                                "☕ Let's personalize your coffee experience",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              _sectionTitle("Coffee Type", Icons.coffee),
                              _dropdownField(types, selectedType, (val) => selectedType = val),
                              const SizedBox(height: 20),

                              _sectionTitle("Roast Level", Icons.fireplace),
                              _dropdownField(roasts, selectedRoast, (val) => selectedRoast = val),
                              const SizedBox(height: 20),

                              _sectionTitle("Flavor Notes", Icons.palette),
                              _chipWrap(flavors, selectedFlavors),
                              const SizedBox(height: 24),

                              _sectionTitle("Preferred Origins", Icons.public),
                              _chipWrap(origins, selectedOrigins),
                              const SizedBox(height: 30),

                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB17E5E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _savePreferences,
                                icon: const Icon(Icons.save),
                                label: const Text(
                                  "Save Preferences",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 30),

                              if (_getSuggestions().isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Based on your selections, we recommend:",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    ..._getSuggestions().map((s) => Text(s)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.brown.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _dropdownField(List<String> items, String currentValue, Function(String) onChanged) {
    return DropdownButtonFormField(
      value: currentValue,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.brown.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
      onChanged: (val) => setState(() => onChanged(val!)),
    );
  }

  Widget _chipWrap(List<String> options, List<String> selectedList) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: options.map((item) {
        final selected = selectedList.contains(item);
        return FilterChip(
          label: Text(item),
          selected: selected,
          backgroundColor: Colors.brown.shade100,
          selectedColor: Colors.brown.shade300,
          onSelected: (value) {
            setState(() {
              if (value) {
                selectedList.add(item);
              } else {
                selectedList.remove(item);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
