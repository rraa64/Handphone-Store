// lib/pages/transaction_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk fungsi copy/salin
import 'package:intl/intl.dart';
import 'transaction_success_page.dart'; // Tetap impor halaman sukses untuk tombol konfirmasi

class TransactionDetailPage extends StatefulWidget {
  final Map trx;

  // Asumsi: Map trx sudah membawa data lengkap, termasuk:
  // id, total_price, status, payment_method (misal: 'BCA', 'QRIS', 'COD')

  const TransactionDetailPage({super.key, required this.trx});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF0D47A1);

  // Data dummy yang akan kita pakai untuk detail pembayaran (sesuai method)
  late Map<String, dynamic> paymentDetails;
  late String formattedPrice;
  late Color statusColor;
  late String statusText;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final status = widget.trx["status"] as String;
    final paymentMethod = widget.trx["payment_method"] as String? ?? 'Pending';
    final price = widget.trx["total_price"] is int
        ? (widget.trx["total_price"] as int).toDouble()
        : (widget.trx["total_price"] as double);

    // 1. Format Harga
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    formattedPrice = currencyFormatter.format(price);

    // 2. Tentukan Warna Status
    statusText = status;
    if (status == "pending") {
      statusColor = Colors.orange;
      statusText = "MENUNGGU PEMBAYARAN";
    } else if (status == "success") {
      statusColor = primaryGreen;
      statusText = "PEMBAYARAN BERHASIL";
    } else if (status == "cancel") {
      statusColor = Colors.red;
      statusText = "DIBATALKAN";
    }

    // 3. Tentukan Detail Pembayaran Berdasarkan Metode
    paymentDetails = _getPaymentDetails(paymentMethod);
  }

  // Fungsi Dummy untuk mendapatkan Detail Pembayaran (Logika yang dipindahkan dari PaymentDetailPage)
  Map<String, dynamic> _getPaymentDetails(String method) {
    // Harga total yang akan dicopy harus tanpa simbol
    final priceWithoutSymbol =
        widget.trx["total_price"].toString().split(".")[0];

    switch (method) {
      case 'BCA':
      case 'Mandiri':
      case 'BNI':
        return {
          'title': 'Transfer Virtual Account $method',
          'instruction':
              'Lakukan transfer ke Virtual Account di bawah sebelum batas waktu. Total harus sesuai.',
          'detail': method == 'BCA' ? '0123 4567 890' : '1380 0012 3456 7',
          'copyText': method == 'BCA' ? '01234567890' : '1380001234567',
        };
      case 'QRIS':
        return {
          'title': 'Pembayaran QRIS',
          'instruction':
              'Buka aplikasi bank/E-Wallet Anda dan Scan kode QR. Pastikan jumlahnya $formattedPrice.',
          'detail': 'QRIS CODE (Klik untuk lihat/simulasi)',
          'isQris': true,
        };
      case 'COD':
        return {
          'title': 'Bayar di Tempat (COD)',
          'instruction':
              'Bayar tunai sebesar $formattedPrice kepada kurir saat pesanan tiba.',
          'detail': 'Pesanan akan diproses setelah diverifikasi oleh penjual.',
          'isCod': true,
        };
      case 'DANA':
      case 'OVO':
      case 'ShopeePay':
        return {
          'title': 'Pembayaran via $method',
          'instruction':
              'Anda akan menerima notifikasi/SMS untuk melanjutkan pembayaran di aplikasi $method.',
          'detail': 'Nomor Telepon Akun: 0812-xxxx-xxxx',
        };
      default:
        return {
          'title': 'Metode Pembayaran Belum Dipilih',
          'instruction': 'Silakan pilih metode pembayaran untuk melanjutkan.',
          'detail': ''
        };
    }
  }

  // --- WIDGET DETAIL PEMBAYARAN KHUSUS ---
  Widget _buildPaymentInfoSection() {
    final method = widget.trx["payment_method"] as String? ?? 'Pending';
    final isPending = widget.trx["status"] == "pending";

    if (method == 'Pending' || method.isEmpty) {
      return const Text('Metode pembayaran belum dipilih.',
          style: TextStyle(color: Colors.red));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paymentDetails['title']!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 16),

          Text(
            paymentDetails['instruction']!,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),

          // Detail VA / QRIS / Info
          if (!paymentDetails.containsKey('isCod'))
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentBlue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      paymentDetails['detail']!,
                      style: TextStyle(
                          fontSize:
                              paymentDetails.containsKey('isQris') ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: accentBlue),
                    ),
                  ),
                  if (paymentDetails.containsKey('copyText'))
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: paymentDetails['copyText']!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Berhasil disalin!')),
                        );
                      },
                      icon:
                          const Icon(Icons.copy, size: 18, color: primaryGreen),
                      label: const Text('Salin',
                          style: TextStyle(color: primaryGreen)),
                    ),
                ],
              ),
            )
          else
            Text(
              paymentDetails['detail']!,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),

          // Tombol Konfirmasi Pembayaran (Hanya jika pending dan bukan COD)
          if (isPending && !paymentDetails.containsKey('isCod'))
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Panggil fungsi untuk memverifikasi pembayaran/ubah status ke 'Processing'
                    // Saat ini, kita simulasi ke halaman sukses
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionSuccessPage(
                            amount: widget.trx["total_price"] is int
                                ? (widget.trx["total_price"] as int).toDouble()
                                : (widget.trx["total_price"] as double)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Konfirmasi Pembayaran',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
        centerTitle: true,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 1: HEADER & STATUS ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Transaksi ID: #${widget.trx["id"]}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Total Pembayaran
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Pembayaran",
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade700),
                      ),
                      Text(
                        formattedPrice,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- BAGIAN 2: RINCIAN PEMBAYARAN (VA / QRIS / COD) ---
            const Text(
              "Rincian Pembayaran",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            _buildPaymentInfoSection(),

            const SizedBox(height: 20),

            // --- BAGIAN 3: DETAIL PRODUK & ALAMAT (Placeholder) ---
            const Text(
              "Detail Pesanan",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            // TODO: Ganti ini dengan data produk dan alamat dari trx['products'] dan trx['address']
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Produk: Xiaomi 13T Pro (1x)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                          'Alamat Kirim: Rifky Alamsyah, Jl. Merdeka No. 45...',
                          style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      Text('Metode Pembayaran: ${widget.trx["payment_method"]}',
                          style: TextStyle(color: Colors.grey.shade700)),
                    ])),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
