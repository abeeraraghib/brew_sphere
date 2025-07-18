import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'coffee.dart';

Future<List<Coffee>> loadCoffeeData() async {
  List<Coffee> coffeeList = [];

  // Load JSON data
  try {
    final String jsonString = await rootBundle.loadString('assets/coffee.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    coffeeList.addAll(jsonData.map((json) => Coffee.fromJson(json)));
  } catch (e) {
    print('Failed to load JSON: $e');
  }

  return coffeeList;
}
