import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coffee.dart';
import 'coffee_loader.dart';
import '../shared_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reply_generator.dart';

class CoffeeBot extends StatefulWidget {
  const CoffeeBot({super.key});

  @override
  State<CoffeeBot> createState() => _CoffeeBotState();
}

class _CoffeeBotState extends State<CoffeeBot> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  List<Coffee> _profiles = [];
  Map<String, List<String>> _sampleQuestions = {};
  Map<String, dynamic>? _userPreferences;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadChatHistory();
    _loadCoffeeProfiles();
    _loadSampleQuestions();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('preferences').doc(uid).get();
    if (doc.exists) {
      setState(() {
        _userPreferences = doc.data();
      });
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', json.encode(_messages));
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString('chat_history');
    if (encoded != null) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(json.decode(encoded));
      });
    }
  }

  Future<void> _loadCoffeeProfiles() async {
    final data = await loadCoffeeData();
    setState(() => _profiles = data);
  }

  Future<void> _loadSampleQuestions() async {
    final String jsonString = await rootBundle.loadString('assets/coffee_questions.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    setState(() {
      _sampleQuestions = data.map((key, value) => MapEntry(key, List<String>.from(value)));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });
    _scrollToBottom();
    _controller.clear();
    _saveChatHistory();

    Future.delayed(const Duration(milliseconds: 500), () async {
      String reply = generateBotReply(text, _profiles, _userPreferences);
      setState(() {
        _messages.add({'sender': 'bot', 'text': reply});
      });
      _scrollToBottom();
      await _saveChatHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
        centerTitle: true,
        title: const Text('CoffeeBot', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.white70),
              tooltip: 'Clear chat',
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('chat_history');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat history cleared')));
                }
                setState(() => _messages.clear());
              },
            );
          }),
        ],
      ),
      drawer: const BrewSphereDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/chatbot.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 12),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['sender'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.brown.shade100.withOpacity(0.9)
                            : Colors.grey.shade200.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_sampleQuestions.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: _sampleQuestions.values.expand((q) => q.take(1)).map((q) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () => _sendMessage(q),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade100.withOpacity(0.8),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(q, style: const TextStyle(fontSize: 13)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Ask CoffeeBot anything...",
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
