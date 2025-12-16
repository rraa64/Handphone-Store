// lib/pages/checkout_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import '../services/transaction_service.dart';
import 'payment_method_page.dart';

class CheckoutPage extends StatefulWidget {
  final ProductModel? product;
  final List<Map<String, dynamic>>? items;

  const CheckoutPage({
    super.key,
    this.product,
    this.items,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  // Konstanta Warna dan Formatter
  List<Map<String, dynamic>> get cartItems {
    if (widget.items != null && widget.items!.isNotEmpty) {
      return widget.items!;
    } else if (widget.product != null) {
      return [
        {
          "products": {
            "id": widget.product!.id,
            "name": widget.product!.name,
            "price": widget.product!.price,
            "cover_image": widget.product!.coverImage,
          },
          "qty": qty,
        }
      ];
    }
    return [];
  }

  static const Color primaryGreen = Color(0xFF4CAF50);

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // State untuk Checkout
  int qty = 1;
  bool loading = false;

  // --- STATE KURIR ---
  String selectedCourier = 'Reguler';

  // PETA HARGA KURIR: Key adalah nama kurir, Value adalah harga (double)
  final Map<String, double> courierPrices = {
    'Reguler': 18000.0,
    'Express': 35000.0,
    'Ambil di Toko': 0.0, // Gratis
  };

  // --- STATE ALAMAT DAN EDIT MODE ---
  bool _isEditingAddress = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressDetailController;

  bool get _isAddressFilled =>
      _nameController.text.isNotEmpty &&
      _addressDetailController.text.isNotEmpty;
  // ------------------------------------

  late AnimationController _anim;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan nilai default simulasi
    _nameController = TextEditingController(text: 'Rifky Alamsyah');
    _phoneController = TextEditingController(text: '0812-3456-7890');
    _addressDetailController = TextEditingController(
        text:
            'Jl. Merdeka No. 45, Komplek Perumahan Indah Permai Blok B7, Jakarta Pusat, DKI Jakarta 10110');

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressDetailController.dispose();
    _anim.dispose();
    super.dispose();
  }

  // --- BIAYA PENGIRIMAN DINAMIS ---
  double get shippingCost => courierPrices[selectedCourier] ?? 0.0;

  double get subTotal {
    double total = 0;
    for (var item in cartItems) {
      final p = item["products"];
      final q = item["qty"];
      total += (p["price"] as num).toDouble() * q;
    }
    return total;
  }

  double get totalPrice => subTotal + shippingCost;

  String _formatPrice(double price) => _currencyFormatter.format(price);

  void _saveAddress() {
    if (_nameController.text.isEmpty || _addressDetailController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Nama dan Alamat Detail tidak boleh kosong.")),
      );
      return;
    }

    // TODO: Logika Simpan Alamat (Kirim ke Supabase)

    setState(() {
      _isEditingAddress = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Alamat berhasil diperbarui!")),
    );
  }

  Future<void> _gotoPaymentMethod() async {
    if (!_isAddressFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon isi alamat dulu.")),
      );
      return;
    }

    // Jangan stop flow setelah save
    if (_isEditingAddress) {
      _saveAddress();
    }

    setState(() => loading = true);

    try {
      final service = TransactionService();
      final first = cartItems.first["products"];

      final trxId = await service.createTransaction(
        productId: first["id"],
        qty: 1,
        price: (first["price"] as num).toDouble(),
        totalPrice: totalPrice,
      );

      if (!mounted) return;

      if (trxId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentMethodPage(
              amount: totalPrice,
              trxId: trxId,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // --- WIDGET HELPER (Tidak berubah) ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAddressTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryGreen, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // --- BAGIAN ALAMAT KONDISIONAL (Tidak berubah) ---
  Widget _buildAddressSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Alamat Pengiriman',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (!_isEditingAddress && _isAddressFilled)
                TextButton(
                  onPressed: () => setState(() => _isEditingAddress = true),
                  child: const Text('Ubah Alamat',
                      style: TextStyle(
                          color: primaryGreen, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const Divider(height: 16),
          if (_isEditingAddress || !_isAddressFilled) ...[
            _buildAddressTextField('Nama Penerima', _nameController),
            _buildAddressTextField('No. Telepon', _phoneController,
                keyboardType: TextInputType.phone),
            _buildAddressTextField(
                'Alamat Detail Lengkap', _addressDetailController,
                maxLines: 3),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveAddress,
                style: FilledButton.styleFrom(backgroundColor: primaryGreen),
                child: const Text('Simpan Alamat'),
              ),
            ),
          ] else ...[
            Text('${_nameController.text} (${_phoneController.text})',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              _addressDetailController.text,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ]
        ],
      ),
    );
  }

  // --- BAGIAN KURIR (Revisi pada DropdownButton) ---
  Widget _buildCourierSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Pilih Jasa Kirim',
              style: TextStyle(fontWeight: FontWeight.w500)),
          DropdownButton<String>(
            value: selectedCourier,
            icon: const Icon(Icons.arrow_forward_ios,
                size: 16, color: primaryGreen),
            elevation: 1,
            style: const TextStyle(color: primaryGreen, fontSize: 16),
            underline: Container(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCourier = newValue!; // <<< MEMPERBARUI STATE
              });
            },
            // Mapping dari Map courierPrices untuk membuat DropdownMenuItem
            items: courierPrices.keys.map((String key) {
              final price = courierPrices[key]!;
              final priceText = price == 0.0 ? 'Gratis' : _formatPrice(price);

              return DropdownMenuItem<String>(
                value: key,
                child: Text('$key ($priceText)',
                    style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- BAGIAN RINGKASAN HARGA (Menggunakan Getter Dinamis) ---
  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal Produk', _formatPrice(subTotal),
              isTotal: false),
          const SizedBox(height: 8),
          _buildPriceRow('Biaya Pengiriman', _formatPrice(shippingCost),
              isTotal: false), // DYNAMIC
          const Divider(height: 24),
          _buildPriceRow('Total Pembayaran', _formatPrice(totalPrice),
              isTotal: true), // DYNAMIC
        ],
      ),
    );
  }

  Widget _buildPriceRow(String title, String value, {required bool isTotal}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? primaryGreen : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? primaryGreen : Colors.black87,
          ),
        ),
      ],
    );
  }

  // --- MAIN BUILD (Tidak berubah) ---

  @override
  Widget build(BuildContext context) {
    _buildSectionTitle('Rincian Pesanan 📦');
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: cartItems.map((item) {
          final p = item["products"];
          final q = item["qty"];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    p["cover_image"] ?? "",
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p["name"],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice((p["price"] as num).toDouble()),
                        style: const TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Qty: $q"),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Checkout"),
        centerTitle: true,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Alamat Pengiriman 🗺️'),
                    _buildAddressSection(),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Rincian Pesanan 📦'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: cartItems.map((item) {
                          final p = item["products"];
                          final q = item["qty"];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    p["cover_image"] ?? "",
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p["name"],
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatPrice(
                                            (p["price"] as num).toDouble()),
                                        style: const TextStyle(
                                          color: primaryGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text("Qty: $q"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Pengiriman 🚚'),
                    _buildCourierSection(),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Ringkasan Pembayaran 💰'),
                    _buildPriceSummary(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // FOOTER: Tombol Aksi Bawah
            Container(
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
              child: SizedBox(
                width: double.infinity,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed:
                        (loading || !_isAddressFilled || _isEditingAddress)
                            ? null
                            : _gotoPaymentMethod,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Bayar Sekarang (${_formatPrice(totalPrice)})",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
