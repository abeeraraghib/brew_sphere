import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chatbot/coffee.dart';
import 'chatbot/coffee_loader.dart';
import 'shared_drawer.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<Coffee> allCoffee = [];
  List<Coffee> filteredCoffee = [];
  String _query = '';

  final synonyms = {
    'strong': ['bold', 'intense'],
    'light': ['mild', 'smooth'],
    'bitter': ['sharp', 'harsh'],
    'sweet': ['sugary', 'dessert-like'],
    'fruity': ['berry', 'citrus', 'fruit'],
    'nutty': ['hazelnut', 'almond', 'nut'],
    'chocolate': ['cocoa', 'mocha'],
    'ethiopia': ['ethiopian'],
    'colombia': ['colombian']
  };

  final commonCorrections = {
    'strng': 'strong',
    'ltte': 'latte',
    'capuchino': 'cappuccino',
    'esspresso': 'espresso',
    'amricano': 'americano',
    'mokha': 'mocha',
    'columbian': 'colombian',
    'ethopian': 'ethiopian'
  };

  @override
void initState() {
  super.initState();
  loadCoffeeData().then((list) {
    setState(() {
      allCoffee = list;
      filteredCoffee = []; 
    });
  });
}


  String _correctSpelling(String word) {
    return commonCorrections[word] ?? word;
  }

  List<String> _expandSynonyms(String word) {
    return [word, ...?synonyms[word]];
  }

  void _searchAndFilter() {
  if (_query.trim().isEmpty) {
    setState(() => filteredCoffee = []);
    return;
  }

  final terms = _query
      .toLowerCase()
      .split(RegExp(r'[ ,.\n]+'))
      .where((t) => t.isNotEmpty)
      .map(_correctSpelling)
      .expand(_expandSynonyms)
      .toSet()
      .toList();

  setState(() {
    filteredCoffee = allCoffee.where((c) {
      final fields = [
        c.name,
        c.origin,
        c.roast,
        c.notes,
        c.description,
        ...c.sentiments,
        ...c.seasons
      ].map((s) => s.toLowerCase()).toList();

      return terms.every((t) => fields.any((f) => f.contains(t)));
    }).toList();
  });
}


  List<String> get _suggestions {
    final q = _query.toLowerCase();
    final s = <String>{};
    if (q.length >= 2) {
      for (var c in allCoffee) {
        if (c.name.toLowerCase().contains(q)) s.add(c.name);
        if (c.origin.toLowerCase().contains(q)) s.add(c.origin);
        for (var t in c.notes
            .toLowerCase()
            .split(RegExp(r'[ ,.\n]+'))
            .where((w) => w.contains(q))) {
          s.add(t);
        }
      }
    }
    return s.take(5).toList();
  }

  Widget _highlightMatch(String text) {
    if (_query.isEmpty) return Text(text);
    final lc = text.toLowerCase();
    final q = _query.toLowerCase();
    final parts = lc.split(q);
    final spans = <TextSpan>[];
    int index = 0;
    for (var part in parts) {
      final start = lc.indexOf(part, index);
      spans.add(TextSpan(text: text.substring(index, start + part.length)));
      index = start + part.length;
      if (index < text.length) {
        spans.add(TextSpan(
          text: text.substring(index, index + q.length),
          style: const TextStyle(backgroundColor: Colors.yellow),
        ));
        index += q.length;
      }
    }
    if (index < text.length) spans.add(TextSpan(text: text.substring(index)));
    return RichText(text: TextSpan(style: const TextStyle(color: Colors.black), children: spans));
  }

  Widget _buildSearchBar() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25)),
        child: Row(children: [
          const Icon(Icons.search, color: Colors.brown),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search brews, blends...'
              ),
              onChanged: (v) {
                _query = v;
                _searchAndFilter();
              },
            ),
          ),
        ]),
      ),
      if (_suggestions.isNotEmpty)
        Container(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            shrinkWrap: true,
            children: _suggestions.map((s) {
              return ListTile(
                dense: true,
                title: Text(s),
                onTap: () {
                  _query = s;
                  _searchAndFilter();
                },
              );
            }).toList(),
          ),
        ),
    ]);
  }

  Widget _buildRatingStars(double rating) {
    int full = rating.floor();
    bool half = (rating - full) >= 0.5;
    int empty = 5 - full - (half ? 1 : 0);
    return Row(children: [
      for (int i = 0; i < full; i++) const Icon(Icons.star, color: Colors.amber, size: 20),
      if (half) const Icon(Icons.star_half, color: Colors.amber, size: 20),
      for (int i = 0; i < empty; i++) const Icon(Icons.star_border, color: Colors.amber, size: 20),
    ]);
  }

  Widget _buildResultsList() {
    return filteredCoffee.isEmpty
        ? const Center(child: Text("No results found."))
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: filteredCoffee.length,
            itemBuilder: (context, index) {
              final c = filteredCoffee[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: ListTile(
                  leading: c.imageUrl.isNotEmpty
                      ? Image.network(c.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.local_cafe, size: 40, color: Colors.brown),
                  title: _highlightMatch(c.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${c.origin} • ${c.roast}'),
                      _buildRatingStars(c.rating),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 40,
                        child: _highlightMatch(
                          c.description.isNotEmpty
                              ? (c.description.length > 80 ? '${c.description.substring(0, 80)}…' : c.description)
                              : (c.notes.length > 80 ? '${c.notes.substring(0, 80)}…' : c.notes),
                        ),
                      )
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () => _showCoffeeDetails(c),
                ),
              );
            },
          );
  }

  void _showCoffeeDetails(Coffee coffee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(coffee.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (coffee.imageUrl.isNotEmpty)
                Center(
                  child: Image.network(coffee.imageUrl, height: 150, fit: BoxFit.cover),
                ),
              const SizedBox(height: 10),
              _buildRatingStars(coffee.rating),
              const SizedBox(height: 10),
              Text("🌍 Origin: ${coffee.origin}"),
              Text("🔥 Roast: ${coffee.roast}"),
              const SizedBox(height: 10),
              const Text("☕ Description:"),
              Text(coffee.description.isNotEmpty ? coffee.description : coffee.notes),
              const SizedBox(height: 10),
              if (coffee.sentiments.isNotEmpty)
                Text("💡 Sentiments: ${coffee.sentiments.join(', ')}"),
              if (coffee.seasons.isNotEmpty)
                Text("🌦️ Seasons: ${coffee.seasons.join(', ')}"),
              const SizedBox(height: 10),
              if (coffee.url.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(coffee.url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open URL')),
                      );
                    }
                  },
                  child: Text(
                    coffee.url,
                    style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

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
          'Explore Coffee',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/explore.jpeg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 8),
                Expanded(child: _buildResultsList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
