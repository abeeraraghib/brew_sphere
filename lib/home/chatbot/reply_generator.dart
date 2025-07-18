import 'dart:math';
import 'coffee.dart';

final greetings = [
  "Hi there! ☕ What coffee magic can I help with today?",
  "Hello! Ready to discover your next favorite brew? 😊",
  "Hey! I'm CoffeeBot—your virtual barista. What can I do for you today?",
  "Hi! Got a craving for something rich and roasty? Let's find it! ☕",
  "Welcome! Need a cozy coffee or a bold boost? I'm here for it! 💬",
  "Hey there! ☕ Looking for a recommendation or a recipe?",
  "Good to see you! Let’s talk coffee—flavors, moods, and all things beans! 🌱",
  "Hola! Ready to brew up some good vibes and better coffee? 😄",
  "Yo! I’ve got beans and brains—ask away! 🤓☕",
  "Hi! Curious about something coffee-related? Shoot your shot! 🎯"
];

String generateBotReply(String message, List<Coffee> profiles, Map<String, dynamic>? preferences) {
  message = message.toLowerCase();

  final List<String> coffeeJokes = [
    "Why don’t coffee beans ever get into arguments? Because they already know how to espresso themselves! 😄",
    "Why did the espresso keep checking his watch? Because he was pressed for time! ⏱️",
    "What’s a coffee’s favorite spell? Es-presso Patronum! 🧙‍♂️☕",
    "Why don’t coffee secrets last long? Because they always spill the beans! 😂",
    "What did the coffee say to its date? You mocha me crazy! ❤️",
    "Why was the coffee always invited to parties? Because it was brewed to perfection! 🎉"
  ];
  
  if (message.contains("recipe") || message.contains("how to make") || message.contains("brew")) {
    if (message.contains("latte")) {
      return "Latte Recipe:\n• 1 shot espresso\n• 200ml steamed milk\n• Top with a thin layer of foam ☕";
    } else if (message.contains("cappuccino")) {
      return "Cappuccino Recipe:\n• 1 shot espresso\n• 100ml steamed milk\n• 100ml milk foam\n• Sprinkle cocoa 🍫";
    } else if (message.contains("mocha")) {
      return "Mocha:\n• 1 shot espresso\n• Cocoa + milk\n• Top with whipped cream 🍫☕";
    } else if (message.contains("iced")) {
      return "Iced Coffee:\n• Brew strong coffee\n• Pour over ice\n• Add milk/syrup 🧊";
    } else {
      return "Try a basic brew:\n• 1 shot espresso\n• 200ml steamed milk\n• Customize with cocoa or vanilla ☕";
    }
  }

  if (message.contains("joke") || message.contains("fun") || message.contains("laugh") || message.contains("pun")) {
    return coffeeJokes[Random().nextInt(coffeeJokes.length)];
  }

  if (message.contains("hello") || message.contains("hi") || message.contains("hey") || message.contains("yo") || message.contains("Good morning") ) {
  return greetings[Random().nextInt(greetings.length)];
}


  if (message.contains("information") || message.contains("tell me about") || message.contains("description")) {
    for (var coffee in profiles) {
      if (message.contains(coffee.name.toLowerCase())) {
        return "📝 Here's info on *${coffee.name}*:\n${coffee.description}";
      }
    }
  }

  if (message.contains("rating") || message.contains("top rated") || message.contains("highly rated")) {
    profiles.sort((a, b) => b.rating.compareTo(a.rating));
    return "🌟 Top Rated Coffees:\n${profiles.take(3).map((c) => "- ${c.name} (${c.rating}/5)").join("\n")}";
  }

  if (message.contains("cheap") || message.contains("low price") || message.contains("affordable") || message.contains("budget")) {
    profiles.sort((a, b) => a.price.compareTo(b.price));
    return "💸 Budget-Friendly Coffees:\n${profiles.take(3).map((c) => "- ${c.name} (Rs. ${(c.price * 280).round()})").join("\n")}";
  }

  final seasons = ['spring', 'summer', 'autumn', 'winter', 'monsoon', 'rainy'];
  for (var season in seasons) {
    if (message.contains(season)) {
      final matching = profiles.where((c) => c.seasons.any((s) => s.toLowerCase().contains(season))).toList();
      if (matching.isNotEmpty) {
        return "☕ Perfect for *$season*:\n${matching.take(3).map((c) => "- ${c.name} (${c.description})").join("\n")}";
      }
    }
  }

  for (var coffee in profiles) {
    for (var note in coffee.notes.toLowerCase().split(RegExp(r'[,\s]+'))) {
      if (note.isNotEmpty && message.contains(note)) {
        return "Based on your taste for *$note* flavors, try:\n"
               "- ${coffee.name}\nDescription: ${coffee.description}\nRating: ${coffee.rating}/5\nPrice: Rs. ${(coffee.price * 280).round()}";
      }
    }
  }

  final sadTriggers = ["not good", "not feeling well", "not happy", "sad", "tired", "stressed"];
  final happyTriggers = ["happy", "joyful", "uplifting"];
  final romanticTriggers = ["romantic"];
  final boldTriggers = ["bold", "strong"];
  final refreshingTriggers = ["refreshing"];
  final mysteriousTriggers = ["mysterious", "reflective"];
  final neutralTriggers = ["neutral", "comforting"];

  if (sadTriggers.any((w) => message.contains(w))) {
    final moodCoffee = profiles.firstWhere(
      (c) => c.sentiments.any((s) => s.toLowerCase().contains("comfort") || s.contains("relax")),
      orElse: () => profiles[0],
    );
    return "☁️ Feeling down? A comforting cup of *${moodCoffee.name}* might cheer you up.\nNotes: ${moodCoffee.notes}\nPrice: Rs. ${(moodCoffee.price * 280).round()}";
  }

  if (happyTriggers.any((w) => message.contains(w))) {
    final happyCoffee = profiles.firstWhere(
      (c) => c.sentiments.any((s) => s.toLowerCase().contains("joy") || s.contains("uplift")),
      orElse: () => profiles[1],
    );
    return "😊 In a joyful mood? Celebrate with *${happyCoffee.name}*! \nNotes: ${happyCoffee.notes}\nRating: ${happyCoffee.rating}/5";
  }

  if (romanticTriggers.any((w) => message.contains(w))) {
    final romanticCoffee = profiles.firstWhere(
      (c) => c.sentiments.any((s) => s.toLowerCase().contains("romantic") || s.contains("elegant")),
      orElse: () => profiles[2],
    );
    return "💕 Planning a cozy moment? Try *${romanticCoffee.name}*, perfect for a romantic setting.\nFlavor Notes: ${romanticCoffee.notes}";
  }

  if (boldTriggers.any((w) => message.contains(w))) {
    final boldCoffee = profiles.firstWhere(
      (c) => c.notes.toLowerCase().contains("bold") || c.roast.toLowerCase().contains("dark"),
      orElse: () => profiles[3],
    );
    return "🔥 Need something bold? *${boldCoffee.name}* packs a punch.\nRoast: ${boldCoffee.roast}\nNotes: ${boldCoffee.notes}";
  }

  if (refreshingTriggers.any((w) => message.contains(w))) {
    final refreshingCoffee = profiles.firstWhere(
      (c) => c.notes.toLowerCase().contains("citrus") || c.notes.contains("refreshing"),
      orElse: () => profiles[4],
    );
    return "🌿 Try *${refreshingCoffee.name}* for a refreshing twist!\nFlavor: ${refreshingCoffee.notes}";
  }

  if (mysteriousTriggers.any((w) => message.contains(w))) {
    final deepCoffee = profiles.firstWhere(
      (c) => c.notes.toLowerCase().contains("spice") || c.notes.contains("complex"),
      orElse: () => profiles[5],
    );
    return "🔮 Looking for something deep and reflective? *${deepCoffee.name}* offers a rich, mysterious experience.\nNotes: ${deepCoffee.notes}";
  }

  if (neutralTriggers.any((w) => message.contains(w))) {
    final mellowCoffee = profiles.firstWhere(
      (c) => c.sentiments.any((s) => s.toLowerCase().contains("calm") || s.contains("mellow")),
      orElse: () => profiles[6],
    );
    return "☕ For a balanced and calm vibe, *${mellowCoffee.name}* is a great match.\nNotes: ${mellowCoffee.notes}\nRating: ${mellowCoffee.rating}/5";
  }

  for (var coffee in profiles) {
    final name = coffee.name.toLowerCase();
    if (message.contains(name)) {
      if (message.contains("price") || message.contains("cost") || message.contains("rate")) {
        return "💰 *${coffee.name}* costs Rs. ${(coffee.price * 280).round()} per 100g.";
      } else {
        return "☕ Here's what I found for *${coffee.name}*:\n"
               "Description: ${coffee.description}\n"
               "Notes: ${coffee.notes}\n"
               "Roast: ${coffee.roast}\n"
               "Origin: ${coffee.origin}\n"
               "Rating: ${coffee.rating}/5\n"
               "Price: Rs. ${(coffee.price * 280).round()}";
      }
    }
  }

  final genericTriggers = ["suggest", "recommend", "unique", "good", "famous", "popular", "try something"];
  if (genericTriggers.any((trigger) => message.contains(trigger))) {
    final filtered = profiles.where((c) {
      final notes = c.notes.toLowerCase();
      final origin = c.origin.toLowerCase();
      final roast = c.roast.toLowerCase();

      final prefersNote = preferences?['flavors']?.any((f) => notes.contains(f.toLowerCase())) ?? false;
      final prefersOrigin = preferences?['origins']?.any((o) => origin.contains(o.toLowerCase())) ?? false;
      final prefersRoast = preferences?['roast']?.toLowerCase() == roast;

      return prefersNote || prefersOrigin || prefersRoast;
    }).toList();

    if (filtered.isNotEmpty) {
      final c = filtered.first;
      return "☕ Based on your preferences, try:\n"
             "- ${c.name}\n"
             "Description: ${c.description}\n"
             "Origin: ${c.origin}\n"
             "Roast: ${c.roast}\n"
             "Price: Rs. ${(c.price * 280).round()}\n"
             "Rating: ${c.rating}/5\n"
             "Notes: ${c.notes}";
    }
  }

  return "I'm not sure I got that, but have you tried Brazil Santos? ☕";
}
