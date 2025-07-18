import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_page.dart';
import '../shared_drawer.dart';

class CoffeeBean {
  final String name;
  final String description;
  final String imagePath;
  final double price;

  CoffeeBean({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'imagePath': imagePath,
        'price': price,
      };

  factory CoffeeBean.fromMap(Map<String, dynamic> map) => CoffeeBean(
        name: map['name'],
        description: map['description'],
        imagePath: map['imagePath'],
        price: map['price'].toDouble(),
      );
}

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String? selectedType;
  List<Map<String, dynamic>> cart = [];

  final Map<String, List<CoffeeBean>> coffeeBeans = {
    'Arabica': [
      CoffeeBean(name: 'Ethiopian Yirgacheffe', description: 'Floral aroma with bright citrus notes.', imagePath: 'assets/images/ColombianSupremo.jpg', price: 650),
      CoffeeBean(name: 'Colombian Supremo', description: 'Balanced, rich body with caramel sweetness.', imagePath: 'assets/images/EthiopianYirgacheffe.jpg', price: 700),
      CoffeeBean(name: 'Guatemalan Antigua', description: 'Spicy, smoky tones with chocolate hints.', imagePath: 'assets/images/GuatemalanAntigua.jpg', price: 680),
    ],
    'Robusta': [
      CoffeeBean(name: 'Vietnamese Robusta', description: 'Bold, strong taste with high caffeine.', imagePath: 'assets/images/VietnamRobusta.png', price: 500),
      CoffeeBean(name: 'Indian Kaapi Royale', description: 'Earthy flavor with bitter finish.', imagePath: 'assets/images/IndiaKaapiRoyale.jpg', price: 550),
      CoffeeBean(name: 'Ugandan Robusta', description: 'Smoky, intense flavor profile.', imagePath: 'assets/images/UgandanRobusta.jpg', price: 520),
    ],
    'Liberica': [
      CoffeeBean(name: 'Philippine Barako', description: 'Unique fruity aroma with woody taste.', imagePath: 'assets/images/PhilippineBarako.jpg', price: 750),
      CoffeeBean(name: 'Indonesian Liberica', description: 'Bold smoky notes with a tangy finish.', imagePath: 'assets/images/IndonesianLiberica.png', price: 720),
      CoffeeBean(name: 'Malaysian Liberica', description: 'Sweet and floral with a hint of jackfruit.', imagePath: 'assets/images/MalaysianLiberica.jpg', price: 730),
    ],
  };

  List<CoffeeBean> get _visibleBeans {
    if (selectedType == null) {
      return coffeeBeans.values.expand((list) => list).toList();
    } else {
      return coffeeBeans[selectedType]!;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cartData');
    if (jsonString != null) {
      final List decoded = json.decode(jsonString);
      setState(() {
        cart = decoded.map((item) {
          return {
            'bean': CoffeeBean.fromMap(item['bean']),
            'quantity': item['quantity'],
          };
        }).toList();
      });
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(cart.map((item) {
      return {
        'bean': (item['bean'] as CoffeeBean).toMap(),
        'quantity': item['quantity'],
      };
    }).toList());
    await prefs.setString('cartData', encoded);
  }

  void addToCart(CoffeeBean bean) {
    int quantity = 100;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Add ${bean.name} to Cart"),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (quantity > 100) {
                        setStateDialog(() => quantity -= 100);
                      }
                    },
                  ),
                  Text('$quantity g', style: const TextStyle(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setStateDialog(() => quantity += 100),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    setState(() {
                      cart.add({'bean': bean, 'quantity': quantity});
                    });
                    await _saveCart();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${bean.name} added to cart!')),
                    );
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void goToCart() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartPage(cart: cart),
      ),
    );

    // Reload cart when coming back from CartPage (if updated)
    if (result == true) {
      _loadCart();
    }
  }

  int _getTotalCartQuantity() => cart.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const BrewSphereDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Stack(
          children: [
            Container(
              height: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/order.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            AppBar(
              backgroundColor: Colors.black.withOpacity(0.6),
              elevation: 0,
              centerTitle: true,
              title: const Text('Place Order', style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: goToCart,
                    ),
                    if (_getTotalCartQuantity() > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _getTotalCartQuantity().toString(),
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/order.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Select Coffee Type:',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 10,
              children: coffeeBeans.keys.map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: selectedType == type,
                  onSelected: (_) => setState(() => selectedType = type),
                  selectedColor: Colors.brown.shade300,
                  backgroundColor: Colors.black54,
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ..._visibleBeans.map((bean) {
              return Card(
                color: Colors.black.withOpacity(0.6),
                child: ListTile(
                  leading: Image.asset(bean.imagePath, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(bean.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(bean.description, style: const TextStyle(color: Colors.white70)),
                  trailing: Text(
                    'Rs ${bean.price.toStringAsFixed(0)} / 100g',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => addToCart(bean),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
