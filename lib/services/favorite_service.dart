import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteService {
  final _client = Supabase.instance.client;

  Future<bool> toggleFavorite(int productId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    // cek apakah sudah ada
    final existing = await _client
        .from('favorites')
        .select()
        .eq('user_id', user.id)
        .eq('product_id', productId)
        .maybeSingle();

    // jika ada → hapus
    if (existing != null) {
      await _client.from('favorites').delete().eq('id', existing['id']);
      return false; // false = sekarang sudah tidak favorit
    }

    // jika tidak ada → tambahkan
    await _client.from('favorites').insert({
      'user_id': user.id,
      'product_id': productId,
    });

    return true; // true = menjadi favorit
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final data = await _client
        .from('favorites')
        .select('product_id, products(*)')
        .eq('user_id', user.id);

    return List<Map<String, dynamic>>.from(data);
  }
}
