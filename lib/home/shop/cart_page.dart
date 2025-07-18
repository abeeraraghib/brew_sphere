import 'package:flutter/material.dart';
import 'order_details_page.dart'; 

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;

  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<Map<String, dynamic>> _cart;

  @override
  void initState() {
    super.initState();
    _cart = List.from(widget.cart);
  }

  void _removeItem(int index) {
    setState(() => _cart.removeAt(index));
  }

  void _changeQuantity(int index, bool increase) {
    setState(() {
      if (increase) {
        _cart[index]['quantity'] += 50;
      } else {
        if (_cart[index]['quantity'] > 50) {
          _cart[index]['quantity'] -= 50;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = _cart.fold(
      0,
      (sum, item) => sum + ((item['bean'].price / 100) * item['quantity']),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Stack(
          children: [
            Container(
              height: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/order.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            AppBar(
              backgroundColor: Colors.black.withOpacity(0.6),
              elevation: 0,
              title: const Text("Your Cart", style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
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
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 10),
            Expanded(
              child: _cart.isEmpty
                  ? const Center(
                      child: Text(
                        "Your cart is empty.",
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (_, index) {
                        final item = _cart[index];
                        final bean = item['bean'];
                        final qty = item['quantity'];

                        final itemTotal = (bean.price / 100) * qty;

                        return Dismissible(
                          key: Key(bean.name + index.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete_forever, color: Colors.white),
                          ),
                          onDismissed: (_) => _removeItem(index),
                          child: Card(
                            color: Colors.black.withOpacity(0.6),
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: ListTile(
                              leading: Image.asset(
                                bean.imagePath,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(bean.name,
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline,
                                            color: Colors.white),
                                        onPressed: () => _changeQuantity(index, false),
                                      ),
                                      Text('$qty g',
                                          style: const TextStyle(color: Colors.white)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline,
                                            color: Colors.white),
                                        onPressed: () => _changeQuantity(index, true),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Total: Rs ${itemTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_forever,
                                    color: Colors.redAccent),
                                onPressed: () => _removeItem(index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (_cart.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: Text(
                    'Proceed to Checkout (Rs ${total.toStringAsFixed(0)})',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailsPage(
                          cart: _cart,
                          total: total,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
