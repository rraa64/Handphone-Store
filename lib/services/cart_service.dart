import 'package:supabase_flutter/supabase_flutter.dart';

class CartService {
  final SupabaseClient _db = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCart() async {
    final user = _db.auth.currentUser;
    if (user == null) return [];

    return await _db
        .from("cart")
        .select("id, qty, products(*)")
        .eq("user_id", user.id);
  }

  Future<void> addToCart(int productId) async {
    final user = _db.auth.currentUser;
    if (user == null) return;

    // cek sudah ada
    final existing = await _db
        .from("cart")
        .select()
        .eq("user_id", user.id)
        .eq("product_id", productId);

    if (existing.isEmpty) {
      // baru
      await _db.from("cart").insert({
        "user_id": user.id,
        "product_id": productId,
        "qty": 1,
      });
    } else {
      // update qty
      final id = existing.first["id"];
      final oldQty = existing.first["qty"];
      await _db.from("cart").update({"qty": oldQty + 1}).eq("id", id);
    }
  }

  Future<void> removeItem(int cartId) async {
    await _db.from("cart").delete().eq("id", cartId);
  }

  Future<void> updateQty(int cartId, int qty) async {
    await _db.from("cart").update({"qty": qty}).eq("id", cartId);
  }
}
