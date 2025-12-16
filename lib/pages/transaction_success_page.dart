import 'package:flutter/material.dart';

class TransactionSuccessPage extends StatelessWidget {
  final double amount;

  const TransactionSuccessPage({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 120,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                "Transaksi Berhasil!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Total pembayaran: Rp ${amount.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/products",
                    (route) => false,
                  );
                },
                child: const Text("Kembali ke Produk"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
