import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'order_confirmation_page.dart';

class OrderDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final double total;

  const OrderDetailsPage({super.key, required this.cart, required this.total});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phone = '';
  String address = '';
  String paymentMethod = 'Cash on Delivery';

  bool _loading = false;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final orderData = {
        'uid': user.uid,
        'name': name,
        'phone': phone,
        'address': address,
        'paymentMethod': paymentMethod,
        'total': widget.total,
        'timestamp': Timestamp.now(),
        'items': widget.cart.map((item) {
          final bean = item['bean'];
          return {
            'beanName': bean.name,
            'imagePath': bean.imagePath,
            'price': bean.price,
            'quantity': item['quantity'],
          };
        }).toList(),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationPage(
            multipleBeans: List<Map<String, dynamic>>.from(orderData['items'] as List),
            total: widget.total,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text("Order Details", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    ],
  ),
),

      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/order.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "Enter Your Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Full Name"),
                    validator: (value) => value!.isEmpty ? "Please enter your name" : null,
                    onSaved: (value) => name = value!.trim(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("City"),
                    validator: (value) => value!.isEmpty ? "Enter City" : null,
                    onSaved: (value) => name = value!.trim(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Country "),
                    validator: (value) => value!.isEmpty ? "Enter your country" : null,
                    onSaved: (value) => name = value!.trim(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Phone Number"),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? "Enter a phone number" : null,
                    onSaved: (value) => phone = value!.trim(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Delivery Address"),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? "Enter delivery address" : null,
                    onSaved: (value) => address = value!.trim(),
                  ),
                  const SizedBox(height: 20),
                  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Select Payment Method:",
      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 8),
    ...['Cash on Delivery', 'Easypaisa', 'JazzCash'].map((method) {
      return RadioListTile<String>(
        value: method,
        groupValue: paymentMethod,
        onChanged: (value) => setState(() => paymentMethod = value!),
        title: Text(method, style: const TextStyle(color: Colors.white)),
        activeColor: Colors.brown,
        tileColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
    }).toList(),
  ],
),

                  const SizedBox(height: 20),
                  Text(
                    "Total: Rs ${widget.total.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _submitOrder,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text("Confirm Order", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.black.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
