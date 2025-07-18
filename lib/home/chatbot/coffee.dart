class Coffee {
  final String name;
  final String origin;
  final String roast;
  final String notes;
  final double rating;
  final String url;
  final String imageUrl;
  final List<String> sentiments;
  final List<String> seasons;
  final double price;
  final String description;

  Coffee({
    required this.name,
    required this.origin,
    required this.roast,
    required this.notes,
    required this.rating,
    required this.url,
    required this.imageUrl,
    required this.sentiments,
    required this.seasons,
    required this.price,
    required this.description,
  });

  factory Coffee.fromJson(Map<String, dynamic> json) {
    return Coffee(
      name: json['name'] ?? '',
      origin: json['origin'] ?? '',
      roast: json['roast'] ?? '',
      notes: json['notes'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      sentiments: List<String>.from(json['sentiments'] ?? []),
      seasons: List<String>.from(json['seasons'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '', // ✅ Included here
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'origin': origin,
      'roast': roast,
      'notes': notes,
      'rating': rating,
      'url': url,
      'imageUrl': imageUrl,
      'sentiments': sentiments,
      'seasons': seasons,
      'price': price,
      'description': description, // ✅ Included in export
    };
  }

  /// Used with CSV input where values are provided as a Map<String, dynamic>
  /// Assumes `sentiments` and `seasons` fields are pipe-separated (e.g., "happy|sad")
  factory Coffee.fromCsvMap(Map<String, dynamic> map) {
    return Coffee(
      name: map['name']?.toString() ?? '',
      origin: map['origin']?.toString() ?? '',
      roast: map['roast']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      rating: double.tryParse(map['rating']?.toString() ?? '') ?? 0.0,
      url: map['url']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      sentiments: (map['sentiments']?.toString() ?? '')
          .split('|')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      seasons: (map['seasons']?.toString() ?? '')
          .split('|')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      price: double.tryParse(map['price']?.toString() ?? '') ?? 0.0,
      description: map['description']?.toString() ?? '', // ✅ Added here too
    );
  }
}
