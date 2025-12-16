import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int?> createTransaction({
    required int productId,
    required int qty,
    required double price,
    required double totalPrice,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Buat transaksi dan ambil ID-nya
      final trx = await _client
          .from('transactions')
          .insert({
            'user_id': user.id,
            'total_price': totalPrice,
            'status': 'pending',
          })
          .select()
          .single();

      final trxId = trx['id'];

      // Insert item transaksi
      await _client.from('transaction_items').insert({
        'transaction_id': trxId,
        'product_id': productId,
        'qty': qty,
        'price': price,
      });

      return trxId; // <–– BALIKKAN ID KE HALAMAN SELANJUTNYA
    } catch (e) {
      print("TRANSACTION ERROR: $e");
      return null;
    }
  }

  // UPDATE PAYMENT METHOD KE TABEL
  Future<bool> updatePaymentMethod(int trxId, String method) async {
    try {
      await _client.from('transactions').update({
        'payment_method': method,
        'status': 'success',
      }).eq('id', trxId);
      return true;
    } catch (e) {
      print("UPDATE PAYMENT METHOD ERROR: $e");
      return false;
    }
  }

  Future<int?> createTransactionMulti({
    required List<Map<String, dynamic>> items,
    required double totalPrice,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final trx = await _client
          .from('transactions')
          .insert({
            'user_id': user.id,
            'total_price': totalPrice,
            'status': 'pending',
          })
          .select()
          .single();

      final int trxId = trx['id'];

      for (var item in items) {
        await _client.from('transaction_items').insert({
          'transaction_id': trxId,
          'product_id': item['product_id'],
          'qty': item['qty'],
          'price': item['price'],
        });
      }

      return trxId;
    } catch (e) {
      print("CREATE MULTI TRANSACTION ERROR: $e");
      return null;
    }
  }
}
