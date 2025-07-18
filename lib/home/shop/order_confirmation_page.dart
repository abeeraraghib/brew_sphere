import 'package:flutter/material.dart';

class OrderConfirmationPage extends StatelessWidget {
  final List<Map<String, dynamic>> multipleBeans;
  final double total;

  const OrderConfirmationPage({
    super.key,
    required this.multipleBeans,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
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
                  image: AssetImage("assets/images/order.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            AppBar(
              backgroundColor: Colors.black.withOpacity(0.6),
              elevation: 0,
              title: const Text("Order Confirmed", style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight + 30),
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Thank you! Your order has been placed.',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: multipleBeans.length,
                  itemBuilder: (_, index) {
                    final item = multipleBeans[index];
                    final double price = item['price'].toDouble();
                    final int qty = item['quantity'];
                    final double itemTotal = (price / 100) * qty;

                    return Card(
                      color: Colors.black.withOpacity(0.6),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Image.asset(
                          item['imagePath'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          item['beanName'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Qty: $qty g',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          'Rs ${itemTotal.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Total: Rs ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home, color: Colors.white),
                label: const Text("Back to Shop", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
