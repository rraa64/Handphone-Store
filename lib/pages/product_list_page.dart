// lib/pages/product_list_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import Pages yang akan digunakan di Bottom Bar
import '../models/product_model.dart';
import '../services/product_service.dart';
import 'product_detail_page.dart';
import 'transaction_history_page.dart';
import 'profile_page.dart';
import 'favorite_page.dart';
import 'cart_page.dart';

// ------------------------------------------------------------------
// UTAMA: PRODUCT LIST PAGE (TAB CONTAINER)
// ------------------------------------------------------------------

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // Konstanta Warna Hijau Konsisten
  static const Color primaryGreen = Color(0xFF4CAF50);

  // State untuk Bottom Bar
  int _currentIndex = 0;

  // Daftar Pages yang akan ditampilkan (halaman sebenarnya)
  final List<Widget> _children = [
    const HomeScreenContent(), // 0: Halaman utama (Product List & Search)
    const FavoritePage(), // 1: Tab Wishlist
    const TransactionHistoryPage(), // 2: Tab Riwayat Transaksi
    const CartPage(), // 3: Tab Keranjang
    const ProfilePage(), // 4: Tab Profil
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // --- MAIN UI (Scaffold dengan Bottom Bar) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // BODY: Menampilkan konten yang dipilih di Bottom Bar
      body: _children[_currentIndex],

      // BOTTOM NAVIGATION BAR (Gaya Bersih/Modern)
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// 2. CONTENT Halaman Beranda (Product List + Search BARU)
// ------------------------------------------------------------------

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  static const Color primaryGreen = Color(0xFF4CAF50);
  final ProductService _productService = ProductService();

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  late Future<List<ProductModel>> _productFuture;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.fetchProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchTerm = _searchController.text.toLowerCase().trim();
    });
  }

  List<ProductModel> _filterProducts(List<ProductModel> allProducts) {
    if (_searchTerm.isEmpty) {
      return allProducts;
    }
    return allProducts.where((product) {
      return product.name.toLowerCase().contains(_searchTerm);
    }).toList();
  }

  // Fungsi utama untuk membangun Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withAlpha(25),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: primaryGreen, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari produk di sini...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return _currencyFormatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      // HEADER: AppBar (tanpa title 'Beranda') + Search Bar
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          floating: true,
          snap: true,
          elevation: 0,
          leading: null,
          automaticallyImplyLeading: false,

          title: const Text(
            "Tech Phone",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ), // <-- HILANGKAN TULISAN "BERANDA"

          bottom: PreferredSize(
            // PreferredSize diperkecil karena Kategori dihapus
            preferredSize: const Size.fromHeight(60.0),
            child: _buildSearchBar(),
          ),
        ),
      ],

      // BODY: Product Grid
      body: FutureBuilder<List<ProductModel>>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryGreen));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada produk."));
          }

          final filteredProducts = _filterProducts(snapshot.data!);

          if (filteredProducts.isEmpty) {
            return Center(
                child: Text("Tidak ditemukan produk untuk '$_searchTerm'"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final p = filteredProducts[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: p),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                        child: p.coverImage.isNotEmpty
                            ? Image.network(
                                p.coverImage,
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                      height: 130,
                                      color: Colors.grey.shade100,
                                      child: const Center(
                                          child: CircularProgressIndicator(
                                        color: primaryGreen,
                                        strokeWidth: 2,
                                      )));
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                      height: 130,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.black45));
                                },
                              )
                            : Container(
                                height: 130,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatPrice(p.price),
                              style: const TextStyle(
                                fontSize: 14,
                                color: primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (p.mainPrice != null)
                              Text(
                                _formatPrice(p.mainPrice!),
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
