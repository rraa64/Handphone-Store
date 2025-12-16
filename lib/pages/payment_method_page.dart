import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';
import 'transaction_detail_page.dart';

class PaymentMethodPage extends StatelessWidget {
  final double amount;
  final int trxId;

  const PaymentMethodPage({
    super.key,
    required this.amount,
    required this.trxId,
  });

  // Konstanta Warna
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFF0D47A1);

  String get _formattedAmount {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }

  // --- FUNGSI NAVIGASI KE HALAMAN DETAIL TRANSAKSI ---
  void _selectPaymentMethod(BuildContext context, String methodKey) async {
    // 1. UPDATE PAYMENT METHOD ke database (Backend)
    await TransactionService().updatePaymentMethod(trxId, methodKey);

    // Pengecekan: Menghindari 'Don't use BuildContexts across async gaps'
    if (!context.mounted) return;

    // 2. Buat Map data transaksi yang dibutuhkan TransactionDetailPage
    // Data ini akan digunakan TransactionDetailPage untuk menampilkan detail pembayaran
    final Map<String, dynamic> transactionMap = {
      "id": trxId,
      "total_price": amount,
      "status": "pending",
      "payment_method": methodKey,
      // Tambahkan key lain yang dibutuhkan TransactionDetailPage (misal: user_id)
      "user_id": 1,
    };

    // 3. NAVIGASI KE HALAMAN DETAIL TRANSAKSI
    // Menggunakan parameter 'trx' bertipe Map (sesuai kebutuhan TransactionDetailPage Anda)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailPage(trx: transactionMap),
      ),
    );
  }

  // --- FUNGSI MENAMPILKAN SUB-PILIHAN (Bank/E-Wallet) ---
  void _showSubMethodSelection(
      BuildContext context, String title, List<Map<String, String>> options) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.only(top: 16),
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 20),
              Expanded(
                child: ListView(
                  children: options.map((option) {
                    return ListTile(
                      leading: Icon(
                        option['icon'] == 'bank'
                            ? Icons.account_balance
                            : Icons.wallet_travel,
                        color: primaryGreen,
                      ),
                      title: Text(option['name']!),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey),
                      onTap: () {
                        Navigator.pop(sheetContext); // Tutup sheet
                        // Panggil _selectPaymentMethod dengan metode spesifik
                        _selectPaymentMethod(context, option['key']!);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER UNTUK ITEM UTAMA METODE PEMBAYARAN ---
  Widget _buildPaymentItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String methodKey,
    List<Map<String, String>>? subOptions,
  }) {
    // Tentukan aksi berdasarkan apakah ada subOptions
    final VoidCallback onTapAction;

    if (subOptions != null && subOptions.isNotEmpty) {
      onTapAction = () {
        _showSubMethodSelection(context, 'Pilih $title', subOptions);
      };
    } else {
      onTapAction = () => _selectPaymentMethod(context, methodKey);
    }

    return InkWell(
      onTap: onTapAction,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: accentColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER UNTUK KATEGORI ---
  Widget _buildCategorySection({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8, left: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: items,
            ),
          ),
        ),
      ],
    );
  }

  // --- MAIN BUILD ---

  @override
  Widget build(BuildContext context) {
    // Data Sub-Metode Pembayaran
    final bankSubOptions = [
      {"name": "Transfer Bank BCA", "key": "BCA", "icon": "bank"},
      {"name": "Transfer Bank Mandiri", "key": "Mandiri", "icon": "bank"},
      {"name": "Transfer Bank BNI", "key": "BNI", "icon": "bank"},
    ];

    // FIX: Menghilangkan key yang duplikat
    final ewalletSubOptions = [
      {"name": "Dana", "key": "DANA", "icon": "ewallet"},
      {"name": "OVO", "key": "OVO", "icon": "ewallet"},
      {"name": "ShopeePay", "key": "ShopeePay", "icon": "ewallet"},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Metode Pembayaran"),
        centerTitle: true,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Ringkasan Pembayaran
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total yang Harus Dibayar',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  _formattedAmount,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KATEGORI 1: Transfer Bank
                  _buildCategorySection(
                    context: context,
                    title: "Transfer Bank",
                    items: [
                      _buildPaymentItem(
                        context: context,
                        title: "Pilih Bank Tujuan",
                        icon: Icons.account_balance,
                        methodKey: "Bank_Selection",
                        subOptions: bankSubOptions,
                      ),
                    ],
                  ),

                  // KATEGORI 2: E-Wallet & QRIS
                  _buildCategorySection(
                    context: context,
                    title: "E-Wallet & QRIS",
                    items: [
                      _buildPaymentItem(
                        context: context,
                        title: "QRIS (Scan Semua E-Wallet/Bank)",
                        icon: Icons.qr_code_2,
                        methodKey: "QRIS",
                      ),
                      _buildPaymentItem(
                        context: context,
                        title: "E-Wallet (Dana/OVO/ShopeePay)",
                        icon: Icons.wallet,
                        methodKey: "EWallet_Selection",
                        subOptions: ewalletSubOptions,
                      ),
                    ],
                  ),

                  // KATEGORI 3: Metode Lain
                  _buildCategorySection(
                    context: context,
                    title: "Metode Lain",
                    items: [
                      _buildPaymentItem(
                        context: context,
                        title: "Bayar di Tempat (COD)",
                        icon: Icons.delivery_dining,
                        methodKey: "COD",
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
