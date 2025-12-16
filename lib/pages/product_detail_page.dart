// lib/pages/product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // WAJIB ADA

import '../models/product_model.dart';
import '../services/favorite_service.dart';
import 'checkout_page.dart';
import '../services/cart_service.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Konstanta Warna dan Formatter
  static const Color primaryGreen = Color(0xFF4CAF50);

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final res = await Supabase.instance.client
        .from("favorites")
        .select()
        .eq("user_id", user.id)
        .eq("product_id", widget.product.id)
        .maybeSingle();

    setState(() {
      _isFavorite = res != null;
    });
  }

  String _formatPrice(double price) {
    return _currencyFormatter.format(price);
  }

  // --- WIDGET BARU: LIST SPEK (Contoh Spek HP) ---
  Widget _buildSpecificationList(String productName) {
    // Anda bisa mengganti data ini dengan data yang sebenarnya dari model produk Anda

    List<String> specs;

    if (productName.toLowerCase().contains('xiaomi 13t pro')) {
      specs = [
        'Chipset: MediaTek Dimensity 9200+ (4nm) - Performa Super Flagship!',
        'Layar: 6.67" AMOLED CrystalRes 144Hz, HDR10+, Dolby Vision',
        'Kamera Utama: 50MP Wide + 12MP Ultrawide + 50MP Telefoto (Leica Lens)',
        'Baterai: 5000 mAh, mendukung HyperCharge 120W (isi penuh dalam ~19 menit)',
        'RAM/Storage: Tersedia dalam pilihan 12GB/256GB dan 12GB/512GB',
        'Fitur Lain: IP68 (Tahan debu dan air), Dual Speaker Dolby Atmos',
      ];
    } else if (productName.toLowerCase().contains('samsung galaxy s23 ultra')) {
      specs = [
        'Chipset: Snapdragon 8 Gen 2 for Galaxy (4nm)',
        'Layar: 6.8" Dynamic AMOLED 2X, 120Hz, S Pen Support',
        'Kamera Utama: 200MP Wide + 10MP Periscope Telefoto (10x Optical Zoom)',
        'Baterai: 5000 mAh, Fast Charging 45W',
        'Fitur: Integrated S Pen, IP68, Gorilla Glass Victus 2',
      ];
    } else {
      // Jika tidak ada spek spesifik, tampilkan deskripsi standar
      return Text(widget.product.description ?? "Tidak ada deskripsi spesifik.",
          style: const TextStyle(fontSize: 16, height: 1.5));
    }

    // Tampilkan List Spesifikasi dalam format bullet point
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: specs
          .map((spec) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen)),
                    Expanded(
                        child: Text(spec,
                            style: const TextStyle(fontSize: 16, height: 1.4))),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // --- MAIN UI ---

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Detail Produk'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () async {
              final fav = await FavoriteService().toggleFavorite(product.id);
              setState(() => _isFavorite = fav);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(fav
                      ? "Ditambahkan ke wishlist"
                      : "Dihapus dari wishlist"),
                ),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. Konten Scrollable
          SingleChildScrollView(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GAMBAR PRODUK
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    product.coverImage,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: const Center(
                            child: Icon(Icons.image_not_supported,
                                color: Colors.black45, size: 50))),
                  ),
                ),

                const SizedBox(height: 16),

                // NAMA PRODUK
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),

                const SizedBox(height: 8),

                // HARGA JUAL (Warna Hijau dan Format Titik)
                Row(
                  children: [
                    Text(
                      _formatPrice(product.price),
                      style: const TextStyle(
                        fontSize: 26,
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // HARGA CORET (Jika ada)
                if (product.mainPrice != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _formatPrice(product.mainPrice!),
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                const Divider(), // Garis pemisah
                const SizedBox(height: 16),

                // JUDUL DESKRIPSI (DIGANTI DARI SPESIFIKASI UTAMA)
                const Text(
                  "Deskripsi Produk",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // DESKRIPSI UMUM (Jika ada)
                if (product.description != null &&
                    product.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(product.description!,
                        style: const TextStyle(fontSize: 16, height: 1.5)),
                  ),

                // LIST SPESIFIKASI (Tampil di bawah deskripsi umum)
                _buildSpecificationList(product.name),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // 2. Tombol (Fixed Bottom Bar)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Tombol Tambah ke Keranjang (Outline)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await CartService().addToCart(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Berhasil masuk ke keranjang")),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: const BorderSide(color: primaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text("Keranjang",
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Tombol Beli Sekarang (Solid Green)
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutPage(
                              product: product,
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryGreen, // WARNA HIJAU SOLID
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Beli Sekarang",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
}
