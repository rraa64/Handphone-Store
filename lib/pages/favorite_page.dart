import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../models/product_model.dart';
import 'product_detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  bool loading = true;
  List<ProductModel> items = [];

  @override
  void initState() {
    super.initState();
    loadFav();
  }

  Future<void> loadFav() async {
    final raw = await FavoriteService().getFavorites();

    // raw structure:
    // [
    //   { "product_id": 1, "products": {...} },
    //   { ... }
    // ]
    final list = raw.map<ProductModel>((item) {
      final p = item["products"];

      return ProductModel(
        id: p["id"],
        name: p["name"] ?? "",
        price: (p["price"] as num).toDouble(),
        mainPrice: p["main_price"] == null
            ? null
            : (p["main_price"] as num).toDouble(),
        stock: p["stock"] ?? 0,
        coverImage: p["cover_image"] ?? "",
        weight: p["weight"],
        description: p["description"],
      );
    }).toList();

    setState(() {
      items = list;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist Saya"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text("Belum ada wishlist"))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final p = items[i];

                    return ListTile(
                      leading: p.coverImage.isNotEmpty
                          ? Image.network(
                              p.coverImage,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image),
                      title: Text(p.name),
                      subtitle: Text("Rp ${p.price.toInt()}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(product: p),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
