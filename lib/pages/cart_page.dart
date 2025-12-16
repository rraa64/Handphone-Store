import 'package:flutter/material.dart';
import 'package:storehp/models/product_model.dart';
import 'package:storehp/pages/checkout_page.dart';
import '../services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool loading = true;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    final data = await CartService().getCart();

    setState(() {
      items = data;
      loading = false;
    });
  }

  double get total {
    double sum = 0;
    for (var item in items) {
      final p = item["products"];
      final price = (p["price"] as num).toDouble();
      sum += price * item["qty"];
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text("Keranjang kosong"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final cart = items[i];
                          final p = cart["products"];
                          final qty = cart["qty"];

                          return ListTile(
                            leading: Image.network(
                              p["cover_image"] ?? "",
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                            title: Text(p["name"]),
                            subtitle: Text("Rp ${p["price"]}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: qty > 1
                                      ? () async {
                                          await CartService()
                                              .updateQty(cart["id"], qty - 1);
                                          loadCart();
                                        }
                                      : null,
                                ),
                                Text(qty.toString()),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                    await CartService()
                                        .updateQty(cart["id"], qty + 1);
                                    loadCart();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // FOOTER TOTAL + CHECKOUT
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Total: Rp ${total.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                if (items.isEmpty) return;

                                // Pastikan items dikonversi ke tipe yang benar
                                final List<Map<String, dynamic>> itemsToSend =
                                    items
                                        .map(
                                            (e) => Map<String, dynamic>.from(e))
                                        .toList();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CheckoutPage(
                                      items: itemsToSend,
                                    ),
                                  ),
                                );
                              },
                              child: const Text("Checkout"),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
